import 'package:equatable/equatable.dart';

sealed class SettingsEvent extends Equatable {}

class SettingsUpdateTheme extends SettingsEvent {
  final String themeMode;

  SettingsUpdateTheme({required this.themeMode});
  @override
  List<Object?> get props => [themeMode];
}

class SettingsUpdateLanguage extends SettingsEvent {
  final String languageCode;

  SettingsUpdateLanguage({required this.languageCode});
  @override
  List<Object?> get props => [languageCode];
}

class SettingsUpdateOnBoardingCompleteness extends SettingsEvent {
  @override
  List<Object?> get props => [];
}

class SettingsSaveApiKeys extends SettingsEvent {
  final String groqApiKey;
  final String? googleAiApiKey;

  SettingsSaveApiKeys({required this.groqApiKey, this.googleAiApiKey});
  @override
  List<Object?> get props => [groqApiKey, googleAiApiKey];
}
