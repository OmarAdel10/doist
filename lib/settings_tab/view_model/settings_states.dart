import 'package:doist/settings_tab/data/models/settings_model.dart';
import 'package:equatable/equatable.dart';

sealed class SettingsState extends Equatable {
  final SettingsModel model;

  const SettingsState({required this.model});

  @override
  List<Object?> get props => [model];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial({required super.model});

  @override
  List<Object?> get props => [model];
}

class SettingsUpdateState extends SettingsState {
  const SettingsUpdateState({required super.model});

  @override
  List<Object?> get props => [model];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError({required this.message, required super.model});

  @override
  List<Object?> get props => [message, model];
}
