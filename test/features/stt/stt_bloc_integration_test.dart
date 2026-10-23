import 'package:doist/core/storage/secure_storage.dart';
import 'package:doist/features/stt/groq_stt_service.dart';
import 'package:doist/features/stt/stt_bloc.dart';
import 'package:doist/features/stt/stt_event.dart';
import 'package:doist/features/stt/stt_service.dart';
import 'package:doist/features/stt/stt_state.dart';
import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/view/screens/home_tab.dart';
import 'package:doist/home_tab/view_model/home_tab_view_model.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockSttService extends Mock implements SttService {}

class _MockGroqSttService extends Mock implements GroqSttService {}

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockHydratedStorage extends Mock implements Storage {}

/// Integration tests for the STT wiring: SttBloc -> HomeTabBloc via the
/// HomeTab listeners.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockHydratedStorage hydratedStorage;
  late _MockFlutterSecureStorage flutterSecureStorage;
  late SettingsBloc settingsBloc;

  setUp(() {
    hydratedStorage = _MockHydratedStorage();
    when(
      () => hydratedStorage.write(any(), any<dynamic>()),
    ).thenAnswer((_) async {});
    HydratedBloc.storage = hydratedStorage;

    flutterSecureStorage = _MockFlutterSecureStorage();
    when(
      () => flutterSecureStorage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
    settingsBloc = SettingsBloc(SecureStorage(flutterSecureStorage));
  });

  Future<void> pumpHomeTab(
    WidgetTester tester, {
    required SttBloc sttBloc,
    required HomeTabBloc homeTabBloc,
  }) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>.value(value: settingsBloc),
          BlocProvider<HomeTabBloc>.value(value: homeTabBloc),
        ],
        child: MaterialApp(
          localizationsDelegates: [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(body: HomeTab(sttBloc: sttBloc)),
        ),
      ),
    );
    await tester.pump();
    // Lottie's looping animation keeps pumpAndSettle busy forever — pump
    // a few frames instead.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('a successful transcription adds the text as an AI task', (
    tester,
  ) async {
    final sttService = _MockGroqSttService();
    when(
      () => sttService.recordAndTranscribe(),
    ).thenAnswer((_) async => 'Buy milk tomorrow');
    final sttBloc = SttBloc(sttService: sttService);
    final homeTabBloc = HomeTabBloc();

    await pumpHomeTab(tester, sttBloc: sttBloc, homeTabBloc: homeTabBloc);

    sttBloc.add(const SttTranscribeFile());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(homeTabBloc.state.tasksList, hasLength(1));
    expect(homeTabBloc.state.tasksList.first.taskTitle, 'Buy milk tomorrow');
    expect(sttBloc.state, isA<SttInitial>());
    sttBloc.close();
    homeTabBloc.close();
  });

  testWidgets('a failed transcription shows an error snack and adds no task', (
    tester,
  ) async {
    final sttService = _MockSttService();
    when(
      () => sttService.recordAndTranscribe(),
    ).thenThrow(Exception('Groq Whisper error: 401 invalid key'));
    final sttBloc = SttBloc(sttService: sttService);
    final homeTabBloc = HomeTabBloc();

    await pumpHomeTab(tester, sttBloc: sttBloc, homeTabBloc: homeTabBloc);

    sttBloc.add(const SttTranscribeFile());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(homeTabBloc.state.tasksList, isEmpty);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Groq Whisper error'), findsOneWidget);
    sttBloc.close();
    homeTabBloc.close();
  });
}
