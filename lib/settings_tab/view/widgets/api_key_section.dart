import 'package:doist/core/storage/secure_storage.dart';
import 'package:doist/core/storage/secure_storage_keys.dart';
import 'package:doist/generated/l10n.dart';
import 'package:doist/settings_tab/view_model/settings_events.dart';
import 'package:doist/settings_tab/view_model/settings_states.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:doist/shared/font_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Settings section for entering the Groq and Google AI API keys.
///
/// Keys are persisted ONLY via [SecureStorage] (dispatched through
/// [SettingsBloc]); they are never written to the hydrated settings model.
class ApiKeySection extends StatefulWidget {
  const ApiKeySection({super.key, this.storage});

  /// Injectable for tests; defaults to the real secure storage.
  final SecureStorage? storage;

  @override
  State<ApiKeySection> createState() => _ApiKeySectionState();
}

class _ApiKeySectionState extends State<ApiKeySection> {
  late final SecureStorage _storage;
  final _groqController = TextEditingController();
  final _googleController = TextEditingController();
  bool _obscureGroq = true;
  bool _obscureGoogle = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _storage = widget.storage ?? SecureStorage(const FlutterSecureStorage());
    _loadExistingKeys();
  }

  Future<void> _loadExistingKeys() async {
    final groq = await _storage.read(SecureStorageKeys.groqApiKey);
    final google = await _storage.read(SecureStorageKeys.googleAiApiKey);
    if (!mounted) return;
    setState(() {
      _groqController.text = groq ?? '';
      _googleController.text = google ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _groqController.dispose();
    _googleController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<SettingsBloc>().add(
      SettingsSaveApiKeys(
        groqApiKey: _groqController.text,
        googleAiApiKey: _googleController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final isLight =
        context.watch<SettingsBloc>().state.model.themeMode == ThemeMode.light;
    final textColor = isLight
        ? AppTheme.lightModeBlack
        : AppTheme.darkModeWhite;
    final hintColor = isLight
        ? AppTheme.lightModeTextGrey
        : AppTheme.darkModeTextGrey;

    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) =>
          current is SettingsApiKeysSaved && previous is! SettingsApiKeysSaved,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(localization.api_keys_saved)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.ai_api_keys,
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            localization.ai_api_keys_description,
            style: TextStyle(fontSize: FontManager.f12, color: hintColor),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _groqController,
            obscureText: _obscureGroq,
            autocorrect: false,
            enabled: !_loading,
            decoration: InputDecoration(
              labelText: localization.groq_api_key,
              labelStyle: TextStyle(color: hintColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureGroq ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscureGroq = !_obscureGroq),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _googleController,
            obscureText: _obscureGoogle,
            autocorrect: false,
            enabled: !_loading,
            decoration: InputDecoration(
              labelText: localization.google_ai_api_key,
              labelStyle: TextStyle(color: hintColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureGoogle ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureGoogle = !_obscureGoogle),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            child: Text(localization.save),
          ),
        ],
      ),
    );
  }
}
