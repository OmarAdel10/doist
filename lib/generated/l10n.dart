// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Doist`
  String get appTitle {
    return Intl.message('Doist', name: 'appTitle', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Add New Task`
  String get add_new_task {
    return Intl.message(
      'Add New Task',
      name: 'add_new_task',
      desc: '',
      args: [],
    );
  }

  /// `App Preferences`
  String get app_prefrences {
    return Intl.message(
      'App Preferences',
      name: 'app_prefrences',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `Dark`
  String get dark {
    return Intl.message('Dark', name: 'dark', desc: '', args: []);
  }

  /// `System`
  String get system {
    return Intl.message('System', name: 'system', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `العربية`
  String get arabic {
    return Intl.message('العربية', name: 'arabic', desc: '', args: []);
  }

  /// `Security`
  String get security {
    return Intl.message('Security', name: 'security', desc: '', args: []);
  }

  /// `Enable Biometrics Login`
  String get enable_biometrics_login {
    return Intl.message(
      'Enable Biometrics Login',
      name: 'enable_biometrics_login',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `App Version`
  String get app_version {
    return Intl.message('App Version', name: 'app_version', desc: '', args: []);
  }

  /// `AI API Keys`
  String get ai_api_keys {
    return Intl.message('AI API Keys', name: 'ai_api_keys', desc: '', args: []);
  }

  /// `Keys are stored securely on this device only.`
  String get ai_api_keys_description {
    return Intl.message(
      'Keys are stored securely on this device only.',
      name: 'ai_api_keys_description',
      desc: '',
      args: [],
    );
  }

  /// `Groq API Key`
  String get groq_api_key {
    return Intl.message(
      'Groq API Key',
      name: 'groq_api_key',
      desc: '',
      args: [],
    );
  }

  /// `Google AI API Key`
  String get google_ai_api_key {
    return Intl.message(
      'Google AI API Key',
      name: 'google_ai_api_key',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `API keys saved`
  String get api_keys_saved {
    return Intl.message(
      'API keys saved',
      name: 'api_keys_saved',
      desc: '',
      args: [],
    );
  }

  /// `No tasks yet`
  String get no_tasks_yet {
    return Intl.message(
      'No tasks yet',
      name: 'no_tasks_yet',
      desc: '',
      args: [],
    );
  }

  /// `Add your first task`
  String get add_first_task {
    return Intl.message(
      'Add your first task',
      name: 'add_first_task',
      desc: '',
      args: [],
    );
  }

  /// `Break down task`
  String get break_down_task {
    return Intl.message(
      'Break down task',
      name: 'break_down_task',
      desc: '',
      args: [],
    );
  }

  /// `Prioritize my day`
  String get prioritize_my_day {
    return Intl.message(
      'Prioritize my day',
      name: 'prioritize_my_day',
      desc: '',
      args: [],
    );
  }

  /// `Listening…`
  String get stt_listening {
    return Intl.message(
      'Listening…',
      name: 'stt_listening',
      desc: '',
      args: [],
    );
  }

  /// `Transcribing…`
  String get stt_transcribing {
    return Intl.message(
      'Transcribing…',
      name: 'stt_transcribing',
      desc: '',
      args: [],
    );
  }

  /// `Add a task first`
  String get add_task_first {
    return Intl.message(
      'Add a task first',
      name: 'add_task_first',
      desc: '',
      args: [],
    );
  }

  /// `Add your Groq API key in Settings`
  String get missing_groq_key {
    return Intl.message(
      'Add your Groq API key in Settings',
      name: 'missing_groq_key',
      desc: '',
      args: [],
    );
  }

  /// `Add your Google AI API key in Settings`
  String get missing_google_key {
    return Intl.message(
      'Add your Google AI API key in Settings',
      name: 'missing_google_key',
      desc: '',
      args: [],
    );
  }

  /// `Low`
  String get priority_low {
    return Intl.message('Low', name: 'priority_low', desc: '', args: []);
  }

  /// `Medium`
  String get priority_medium {
    return Intl.message('Medium', name: 'priority_medium', desc: '', args: []);
  }

  /// `High`
  String get priority_high {
    return Intl.message('High', name: 'priority_high', desc: '', args: []);
  }

  /// `Parse task`
  String get parse_task {
    return Intl.message('Parse task', name: 'parse_task', desc: '', args: []);
  }

  /// `Save API Keys`
  String get save_api_keys {
    return Intl.message(
      'Save API Keys',
      name: 'save_api_keys',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
