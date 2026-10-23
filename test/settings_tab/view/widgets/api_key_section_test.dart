import 'package:doist/core/storage/secure_storage.dart';
import 'package:doist/core/storage/secure_storage_keys.dart';
import 'package:doist/generated/l10n.dart';
import 'package:doist/settings_tab/view/widgets/api_key_section.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockHydratedStorage extends Mock implements Storage {}

Widget _wrap(Widget child, {required FlutterSecureStorage mock}) {
  final hydratedStorage = _MockHydratedStorage();
  when(
    () => hydratedStorage.write(any(), any<dynamic>()),
  ).thenAnswer((_) async {});
  HydratedBloc.storage = hydratedStorage;
  return MaterialApp(
    localizationsDelegates: [S.delegate],
    supportedLocales: S.delegate.supportedLocales,
    home: BlocProvider<SettingsBloc>(
      create: (_) => SettingsBloc(SecureStorage(mock)),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterSecureStorage mock;

  setUp(() {
    mock = _MockFlutterSecureStorage();
    when(() => mock.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    when(
      () => mock.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(() => mock.delete(key: any(named: 'key'))).thenAnswer((_) async {});
  });

  testWidgets('shows two key fields and a save button', (tester) async {
    await tester.pumpWidget(
      _wrap(ApiKeySection(storage: SecureStorage(mock)), mock: mock),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text(S().save), findsOneWidget);
  });

  testWidgets('prefills existing keys from SecureStorage', (tester) async {
    when(
      () => mock.read(key: SecureStorageKeys.groqApiKey),
    ).thenAnswer((_) async => 'sk-groq');
    when(
      () => mock.read(key: SecureStorageKeys.googleAiApiKey),
    ).thenAnswer((_) async => 'sk-google');

    await tester.pumpWidget(
      _wrap(ApiKeySection(storage: SecureStorage(mock)), mock: mock),
    );
    await tester.pumpAndSettle();

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].controller!.text, 'sk-groq');
    expect(fields[1].controller!.text, 'sk-google');
  });

  testWidgets('save dispatches SettingsSaveApiKeys which writes both keys', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(ApiKeySection(storage: SecureStorage(mock)), mock: mock),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'sk-groq');
    await tester.enterText(find.byType(TextField).at(1), 'sk-google');
    await tester.tap(find.text(S().save));
    await tester.pumpAndSettle();

    verify(
      () => mock.write(key: SecureStorageKeys.groqApiKey, value: 'sk-groq'),
    ).called(1);
    verify(
      () =>
          mock.write(key: SecureStorageKeys.googleAiApiKey, value: 'sk-google'),
    ).called(1);
    expect(find.text(S().api_keys_saved), findsOneWidget);
  });
}
