import 'dart:developer';

import 'package:doist/core/storage/secure_storage.dart';
import 'package:doist/core/storage/secure_storage_keys.dart';
import 'package:doist/settings_tab/data/models/settings_model.dart';
import 'package:doist/settings_tab/view_model/settings_events.dart';
import 'package:doist/settings_tab/view_model/settings_states.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._secureStorage)
    : super(
        SettingsInitial(
          model: SettingsModel(
            themeMode: ThemeMode.light,
            language: 'en',
            isOnBoardingDone: false,
          ),
        ),
      ) {
    on<SettingsUpdateTheme>((event, emit) {
      emit(
        SettingsUpdateState(
          model: state.model.copyWith(
            themeMode: event.themeMode == 'light'
                ? ThemeMode.light
                : event.themeMode == 'dark'
                ? ThemeMode.dark
                : ThemeMode.system,
          ),
        ),
      );
    });

    on<SettingsUpdateLanguage>((event, emit) {
      emit(
        SettingsUpdateState(
          model: state.model.copyWith(language: event.languageCode),
        ),
      );
    });

    on<SettingsUpdateOnBoardingCompleteness>((event, emit) {
      emit(
        SettingsUpdateState(
          model: state.model.copyWith(isOnBoardingDone: true),
        ),
      );
    });

    // API keys are persisted ONLY in SecureStorage — never in the hydrated
    // settings model, which is written to disk in plaintext.
    on<SettingsSaveApiKeys>((event, emit) async {
      final groqKey = event.groqApiKey.trim();
      if (groqKey.isNotEmpty && !_isValidGroqKey(groqKey)) {
        emit(
          SettingsError(
            message: 'Invalid Groq API key format',
            model: state.model,
          ),
        );
        return;
      }
      if (groqKey.isEmpty) {
        await _secureStorage.delete(SecureStorageKeys.groqApiKey);
      } else {
        await _secureStorage.write(SecureStorageKeys.groqApiKey, groqKey);
      }
      final googleKey = event.googleAiApiKey?.trim() ?? '';
      if (googleKey.isNotEmpty && !_isValidGoogleKey(googleKey)) {
        emit(
          SettingsError(
            message: 'Invalid Google AI API key format',
            model: state.model,
          ),
        );
        return;
      }
      if (googleKey.isEmpty) {
        await _secureStorage.delete(SecureStorageKeys.googleAiApiKey);
      } else {
        await _secureStorage.write(SecureStorageKeys.googleAiApiKey, googleKey);
      }
      emit(SettingsApiKeysSaved(model: state.model));
    });
  }

  bool _isValidGroqKey(String key) => key.startsWith('sk-') && key.length > 20;

  bool _isValidGoogleKey(String key) => key.length > 20;

  final SecureStorage _secureStorage;

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    try {
      final model = SettingsModel.fromMap(
        (json['settingsState'] as Map<String, dynamic>),
      );
      return SettingsUpdateState(model: model);
    } catch (e) {
      log('Error During Serialization: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    try {
      return {'settingsState': state.model.toMap()};
    } catch (e) {
      log('Error During Serialization: $e');
      return null;
    }
  }
}
