import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  const BottomNavBarItem({
    super.key,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: isSelected ? 28 : 24,
      color:
          context.read<SettingsBloc>().state.model.themeMode == ThemeMode.light
          ? isSelected
                ? AppTheme.lightModeBlack
                : AppTheme.lightModeLightGrey
          : isSelected
          ? AppTheme.darkModeWhite
          : AppTheme.darkModeFormAndCheckBoxGrey,
    );
  }
}
