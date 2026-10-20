import 'package:doist/core/storage/secure_storage_keys.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groqApiKey constant holds the expected key name', () {
    expect(SecureStorageKeys.groqApiKey, equals('groq_api_key'));
  });
}
