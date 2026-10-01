import 'dart:developer';

import 'package:doist/settings_tab/data/models/settings_model.dart';
import 'package:doist/settings_tab/view_model/settings_events.dart';
import 'package:doist/settings_tab/view_model/settings_states.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc()
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
  }

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
