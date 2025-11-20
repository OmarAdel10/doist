import 'package:doist/generated/l10n.dart';
import 'package:doist/settings_tab/view/widgets/about_section.dart';
import 'package:doist/settings_tab/view/widgets/language_section.dart';
import 'package:doist/settings_tab/view/widgets/security_section.dart';
import 'package:doist/settings_tab/view/widgets/theme_section.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.app_prefrences,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: context.read<SettingsBloc>().state.model.themeMode ==
                  ThemeMode.light
              ? AppTheme.lightModeBlack : AppTheme.darkModeWhite
              ),
          ),
          const SizedBox(height: 16,),
          const ThemeSection(),
          const SizedBox(height: 16,),
          const Divider(indent: 32,endIndent: 32,),
          const SizedBox(height: 16,),
          const LanguageSection(),
          const SizedBox(height: 16,),
          const Divider(indent: 32,endIndent: 32,),
          const SizedBox(height: 16,),
          const SecuritySection(),
          const SizedBox(height: 16,),
          const Divider(indent: 32,endIndent: 32,),
          const SizedBox(height: 16,),
          const AboutSection(),
        ],
      ),
    );
  }
}
