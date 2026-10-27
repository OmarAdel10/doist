import 'package:bloc_test/bloc_test.dart';
import 'package:doist/core/storage/secure_storage.dart';
import 'package:doist/core/storage/secure_storage_keys.dart';
import 'package:doist/settings_tab/data/models/settings_model.dart';
import 'package:doist/settings_tab/view_model/settings_events.dart';
import 'package:doist/settings_tab/view_model/settings_states.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockHydratedStorage extends Mock implements Storage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterSecureStorage flutterSecureStorage;
  late SecureStorage secureStorage;

  setUp(() {
    flutterSecureStorage = _MockFlutterSecureStorage();
    when(
      () => flutterSecureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => flutterSecureStorage.delete(key: any(named: 'key')),
    ).thenAnswer((_) async {});
    secureStorage = SecureStorage(flutterSecureStorage);
    final hydratedStorage = _MockHydratedStorage();
    when(
      () => hydratedStorage.write(any(), any<dynamic>()),
    ).thenAnswer((_) async {});
    HydratedBloc.storage = hydratedStorage;
  });

  SettingsBloc buildBloc() => SettingsBloc(secureStorage);

  test('initial state is SettingsInitial', () {
    final bloc = buildBloc();
    expect(bloc.state, isA<SettingsInitial>());
  });

  blocTest<SettingsBloc, SettingsState>(
    'SettingsSaveApiKeys writes both keys to SecureStorage and emits SettingsApiKeysSaved',
    build: buildBloc,
    act: (bloc) => bloc.add(
      SettingsSaveApiKeys(
        groqApiKey: 'sk-test-dummy-groq-key-for-unit-testing',
        googleAiApiKey: 'test-dummy-google-key-for-unit-testing',
      ),
    ),
    expect: () => [isA<SettingsApiKeysSaved>()],
    verify: (_) {
      verify(
        () => flutterSecureStorage.write(
          key: SecureStorageKeys.groqApiKey,
          value: 'sk-test-dummy-groq-key-for-unit-testing',
        ),
      ).called(1);
      verify(
        () => flutterSecureStorage.write(
          key: SecureStorageKeys.googleAiApiKey,
          value: 'test-dummy-google-key-for-unit-testing',
        ),
      ).called(1);
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'SettingsSaveApiKeys deletes the Google key when the field is empty',
    build: buildBloc,
    act: (bloc) => bloc.add(
      SettingsSaveApiKeys(
        groqApiKey: 'sk-test-dummy-groq-key-for-unit-testing',
        googleAiApiKey: '',
      ),
    ),
    expect: () => [isA<SettingsApiKeysSaved>()],
    verify: (_) {
      verify(
        () =>
            flutterSecureStorage.delete(key: SecureStorageKeys.googleAiApiKey),
      ).called(1);
      verifyNever(
        () => flutterSecureStorage.write(
          key: SecureStorageKeys.googleAiApiKey,
          value: any(named: 'value'),
        ),
      );
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'SettingsSaveApiKeys deletes the Groq key when the field is empty',
    build: buildBloc,
    act: (bloc) => bloc.add(SettingsSaveApiKeys(groqApiKey: '')),
    expect: () => [isA<SettingsApiKeysSaved>()],
    verify: (_) {
      verify(
        () => flutterSecureStorage.delete(key: SecureStorageKeys.groqApiKey),
      ).called(1);
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'SettingsSaveApiKeys trims surrounding whitespace before storing',
    build: buildBloc,
    act: (bloc) => bloc.add(
      SettingsSaveApiKeys(
        groqApiKey: '  sk-test-dummy-groq-key-for-unit-testing  ',
        googleAiApiKey: ' test-dummy-google-key-for-unit-testing ',
      ),
    ),
    expect: () => [isA<SettingsApiKeysSaved>()],
    verify: (_) {
      verify(
        () => flutterSecureStorage.write(
          key: SecureStorageKeys.groqApiKey,
          value: 'sk-test-dummy-groq-key-for-unit-testing',
        ),
      ).called(1);
      verify(
        () => flutterSecureStorage.write(
          key: SecureStorageKeys.googleAiApiKey,
          value: 'test-dummy-google-key-for-unit-testing',
        ),
      ).called(1);
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'SettingsSaveApiKeys treats a whitespace-only key as empty and deletes it',
    build: buildBloc,
    act: (bloc) =>
        bloc.add(SettingsSaveApiKeys(groqApiKey: '   ', googleAiApiKey: null)),
    expect: () => [isA<SettingsApiKeysSaved>()],
    verify: (_) {
      verify(
        () => flutterSecureStorage.delete(key: SecureStorageKeys.groqApiKey),
      ).called(1);
    },
  );

  test('toJson never serializes API key material', () {
    final bloc = buildBloc();
    final json = bloc.toJson(
      const SettingsApiKeysSaved(
        model: SettingsModel(
          themeMode: ThemeMode.light,
          language: 'en',
          isOnBoardingDone: false,
        ),
      ),
    );

    expect(json, isNotNull);
    // The hydrated payload is written to disk in plaintext — it must carry
    // no trace of the secure-storage keys.
    final payload = json.toString();
    expect(payload, isNot(contains('sk-')));
    expect(payload, isNot(contains('api_key')));
    expect(json!.keys, ['settingsState']);
  });
}
