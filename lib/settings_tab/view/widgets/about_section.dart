import 'package:doist/generated/l10n.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).about,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color:
                context.read<SettingsBloc>().state.model.themeMode ==
                    ThemeMode.light
                ? AppTheme.lightModeBlack
                : AppTheme.darkModeWhite,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).app_version,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color:
                    context.read<SettingsBloc>().state.model.themeMode ==
                        ThemeMode.light
                    ? AppTheme.lightModeBlack
                    : AppTheme.darkModeWhite,
              ),
            ),
            Text(
              '1.0.0',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color:
                    context.read<SettingsBloc>().state.model.themeMode ==
                        ThemeMode.light
                    ? AppTheme.lightModeLoadingTextGrey
                    : AppTheme.darkModeLoadingTextGrey
              ),
            ),
          ],
        ),
      ],
    );
  }
}