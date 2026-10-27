import 'package:doist/generated/l10n.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:doist/shared/font_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Empty-state shown when the task list has no tasks.
class EmptyTasks extends StatelessWidget {
  const EmptyTasks({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 64, color: AppTheme.lightModeLightGrey),
          const SizedBox(height: 12),
          Text(
            localization.no_tasks_yet,
            style: TextStyle(
              fontSize: FontManager.f16,
              fontWeight: FontManager.semiBold,
              color: AppTheme.lightModeBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            localization.add_first_task,
            style: TextStyle(
              fontSize: FontManager.f14,
              color: AppTheme.lightModeTextGrey,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms, curve: Curves.easeIn),
    );
  }
}
