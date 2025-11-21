import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:doist/shared/font_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskTile extends StatelessWidget {
  final TaskModel model;
  final void Function(bool?)? onChanged;

  const TaskTile({super.key, required this.model, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        model.taskTitle,
        style: TextStyle(
          fontSize: FontManager.f16,
          fontWeight: FontManager.medium,
          color: context.read<SettingsBloc>().state.model.themeMode ==
                  ThemeMode.light
              ? AppTheme.lightModeBlack : AppTheme.darkModeWhite,
          decoration: model.isChecked
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
      leading: Checkbox(
        activeColor: AppTheme.darkModeLightGrey,
        side: BorderSide(
          color:
              context.read<SettingsBloc>().state.model.themeMode ==
                  ThemeMode.light
              ? AppTheme.lightModeFormAndCheckBoxGrey
              : AppTheme.darkModeFormAndCheckBoxGrey,
          width: 2,
        ),
        value: model.isChecked,
        onChanged: onChanged,
      ),
    );
  }
}
