import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:flutter/material.dart';

/// Colored pill showing a task priority: low = green, medium = amber,
/// high = red.
class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority, this.dense = false});

  final TaskPriority priority;

  /// Smaller paddings/font for use inside a ListTile subtitle.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final String label;
    final Color foreground;
    final Color background;
    switch (priority) {
      case TaskPriority.low:
        label = localization.priority_low;
        foreground = Colors.green.shade800;
        background = Colors.green.shade50;
      case TaskPriority.medium:
        label = localization.priority_medium;
        foreground = Colors.amber.shade900;
        background = Colors.amber.shade100;
      case TaskPriority.high:
        label = localization.priority_high;
        foreground = Colors.red.shade700;
        background = Colors.red.shade50;
    }

    return Container(
      padding: dense
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: dense ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
