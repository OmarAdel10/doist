import 'package:doist/generated/l10n.dart';
import 'package:doist/settings_tab/view_model/settings_events.dart';
import 'package:doist/settings_tab/view_model/settings_states.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecuritySection extends StatelessWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).security,
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
              S.of(context).enable_biometrics_login,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color:
                    context.read<SettingsBloc>().state.model.themeMode ==
                        ThemeMode.light
                    ? AppTheme.lightModeBlack
                    : AppTheme.darkModeWhite,
              ),
            ),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return Transform.scale(
                  scale: 0.85,
                  child: CupertinoSwitch(
                    activeTrackColor: AppTheme.darkModeSecondry,
                    value: state.model.enabledBioMetricLogin,
                    onChanged: (value) => context.read<SettingsBloc>().add(
                      SettingsUpdateBioMetrics(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
