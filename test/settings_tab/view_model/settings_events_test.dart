import 'package:doist/settings_tab/view_model/settings_events.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SettingsSaveApiKeys carries both keys in props', () {
    final event = SettingsSaveApiKeys(
      groqApiKey: 'sk-groq',
      googleAiApiKey: 'sk-google',
    );
    expect(event.props, ['sk-groq', 'sk-google']);
  });

  test('SettingsSaveApiKeys allows a null Google AI key', () {
    final event = SettingsSaveApiKeys(groqApiKey: 'sk-groq');
    expect(event.googleAiApiKey, isNull);
  });
}
