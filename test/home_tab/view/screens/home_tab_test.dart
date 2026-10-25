import 'package:doist/core/storage/secure_storage.dart';
import 'package:doist/features/stt/stt_bloc.dart';
import 'package:doist/features/stt/stt_event.dart';
import 'package:doist/features/stt/stt_service.dart';
import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/view/screens/home_tab.dart';
import 'package:doist/home_tab/view/widgets/mic_fab.dart';
import 'package:doist/home_tab/view_model/home_tab_view_model.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockSttService extends Mock implements SttService {}

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockHydratedStorage extends Mock implements Storage {}

class _FakeSttEvent extends Fake implements SttStartRecording {}

/// Screen-level tests for HomeTab: bloc construction from secure-storage
/// keys, the loading placeholder, the missing-key mic gate and dispose
/// ownership.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(_FakeSttEvent());
  });

  late _MockHydratedStorage hydratedStorage;
  late _MockFlutterSecureStorage flutterSecureStorage;

  setUp(() {
    hydratedStorage = _MockHydratedStorage();
    when(
      () => hydratedStorage.write(any(), any<dynamic>()),
    ).thenAnswer((_) async {});
    HydratedBloc.storage = hydratedStorage;

    flutterSecureStorage = _MockFlutterSecureStorage();
    when(
      () => flutterSecureStorage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => 'sk-test');
  });

  Widget wrap(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
          create: (_) => SettingsBloc(SecureStorage(flutterSecureStorage)),
        ),
        BlocProvider<HomeTabBloc>(create: (_) => HomeTabBloc()),
      ],
      child: MaterialApp(
        localizationsDelegates: [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('shows a loading placeholder, then the tab once keys load', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(HomeTab(secureStorage: SecureStorage(flutterSecureStorage))),
    );

    // Keys are read asynchronously — the placeholder renders first.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(MicFab), findsNothing);

    await settle(tester);

    expect(find.byType(MicFab), findsOneWidget);
  });

  testWidgets('missing Groq key gates the mic FAB with a hint snack', (
    tester,
  ) async {
    when(
      () => flutterSecureStorage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(
      wrap(HomeTab(secureStorage: SecureStorage(flutterSecureStorage))),
    );
    await settle(tester);

    await tester.tap(find.byType(MicFab));
    await tester.pump();

    expect(find.text(S().missing_groq_key), findsOneWidget);
  });

  testWidgets('does not close blocs it did not create', (tester) async {
    final sttBloc = SttBloc(sttService: _MockSttService());

    await tester.pumpWidget(wrap(HomeTab(sttBloc: sttBloc)));
    await settle(tester);

    // Swap the tab out of the tree — the injected bloc must survive.
    await tester.pumpWidget(wrap(const SizedBox.shrink()));

    expect(sttBloc.isClosed, isFalse);
    await sttBloc.close();
  });
}
