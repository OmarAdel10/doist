import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:doist/home_tab/view/widgets/priority_chip.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:doist/shared/font_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  final TaskModel model;
  final void Function(bool?)? onChanged;

  const TaskTile({super.key, required this.model, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final dueDateLabel = model.dueDate == null
        ? null
        : DateFormat.MMMd().format(model.dueDate!);
    return ListTile(
      title: Text(
        model.taskTitle,
        style: TextStyle(
          fontSize: FontManager.f16,
          fontWeight: FontManager.medium,
          color:
              context.read<SettingsBloc>().state.model.themeMode ==
                  ThemeMode.light
              ? AppTheme.lightModeBlack
              : AppTheme.darkModeWhite,
          decoration: model.isChecked
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
      subtitle: Row(
        children: [
          PriorityChip(priority: model.priority, dense: true),
          if (dueDateLabel != null) ...[
            const SizedBox(width: 8),
            Text(
              dueDateLabel,
              style: TextStyle(
                fontSize: FontManager.f12,
                color: AppTheme.lightModeTextGrey,
              ),
            ),
          ],
        ],
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
        onChanged: (val) {
          HapticFeedback.lightImpact();
          onChanged?.call(val);
        },
      ),
    );
  }
}
