import 'package:doist/generated/l10n.dart';
import 'package:doist/settings_tab/view_model/settings_events.dart';
import 'package:doist/settings_tab/view_model/settings_states.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.language,
          style: textTheme.labelLarge!.copyWith(
            color:
                context.read<SettingsBloc>().state.model.themeMode ==
                    ThemeMode.light
                ? AppTheme.lightModeBlack
                : AppTheme.darkModeWhite,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: MediaQuery.sizeOf(context).height * 0.07,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lightModeFormAndCheckBoxGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<SettingsBloc>().add(
                          SettingsUpdateLanguage(languageCode: 'en')
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: state.model.language == 'en'
                              ? AppTheme.lightModeSecondry
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            localization.english,
                            style: textTheme.labelMedium!.copyWith(
                              color: state.model.language == 'en'
                                  ? AppTheme.lightModePrimary
                                  : AppTheme.lightModeTextGrey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<SettingsBloc>().add(
                          SettingsUpdateLanguage(languageCode: 'ar')
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: state.model.language == 'ar'
                              ? AppTheme.lightModeSecondry
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            localization.arabic,
                            style: textTheme.labelMedium!.copyWith(
                              color: state.model.language == 'ar'
                                  ? AppTheme.lightModePrimary
                                  : AppTheme.lightModeTextGrey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
