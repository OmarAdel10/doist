import 'package:doist/core/storage/secure_storage.dart';
import 'package:doist/core/storage/secure_storage_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late SecureStorage storage;
  late FlutterSecureStorage mock;

  setUp(() {
    mock = _MockStorage();
    storage = SecureStorage(mock);
  });

  test('read returns null when key missing', () async {
    when(() => mock.read(key: SecureStorageKeys.groqApiKey))
        .thenAnswer((_) async => null);
    final result = await storage.read(SecureStorageKeys.groqApiKey);
    expect(result, isNull);
  });

  test('write calls underlying storage with key and value', () async {
    when(() => mock.write(
          key: SecureStorageKeys.googleAiApiKey,
          value: 'secret',
        ))
        .thenAnswer((_) async => {});
    await storage.write(SecureStorageKeys.googleAiApiKey, 'secret');
    verify(() => mock.write(
          key: SecureStorageKeys.googleAiApiKey,
          value: 'secret',
        )).called(1);
  });
}
