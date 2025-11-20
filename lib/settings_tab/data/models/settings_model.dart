// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

class SettingsModel {
  final ThemeMode themeMode;
  final String language;
  final bool enabledBioMetricLogin;

  const SettingsModel({
    required this.themeMode,
    required this.language,
    required this.enabledBioMetricLogin,
  });

  SettingsModel copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? enabledBioMetricLogin,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      enabledBioMetricLogin:
          enabledBioMetricLogin ?? this.enabledBioMetricLogin,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'themeMode': themeMode.name,
      'language': language,
      'enabledBioMetricLogin': enabledBioMetricLogin,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == map['themeMode'],
        orElse: () => ThemeMode.light,
      ),
      language: map['language'] as String,
      enabledBioMetricLogin: map['enabledBioMetricLogin'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingsModel.fromJson(String source) =>
      SettingsModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
