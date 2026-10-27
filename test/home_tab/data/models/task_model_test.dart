import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskModel', () {
    test('creates with default values', () {
      final task = TaskModel(taskTitle: 'Buy milk');
      expect(task.taskTitle, 'Buy milk');
      expect(task.isChecked, false);
      expect(task.priority, TaskPriority.medium);
      expect(task.dueDate, isNull);
      expect(task.id, isNotEmpty);
    });

    test('copyWith creates a modified copy', () {
      final original = TaskModel(
        id: 'abc',
        taskTitle: 'Buy milk',
        priority: TaskPriority.low,
      );
      final copy = original.copyWith(
        taskTitle: 'Buy eggs',
        priority: TaskPriority.high,
        isChecked: true,
      );
      expect(copy.id, 'abc');
      expect(copy.taskTitle, 'Buy eggs');
      expect(copy.priority, TaskPriority.high);
      expect(copy.isChecked, true);
      expect(original.taskTitle, 'Buy milk'); // original unchanged
      expect(original.priority, TaskPriority.low);
    });

    test('toMap and fromMap round-trip', () {
      final task = TaskModel(
        id: 'xyz',
        taskTitle: 'Write report',
        priority: TaskPriority.high,
        dueDate: DateTime(2026, 10, 27),
      );
      final map = task.toMap();
      final restored = TaskModel.fromMap(map);
      expect(restored.id, 'xyz');
      expect(restored.taskTitle, 'Write report');
      expect(restored.priority, TaskPriority.high);
      expect(restored.dueDate, DateTime(2026, 10, 27));
    });

    test('fromMap handles missing dueDate', () {
      final map = {
        'id': 'xyz',
        'isChecked': false,
        'taskTitle': 'Write report',
        'priority': 1,
      };
      final task = TaskModel.fromMap(map);
      expect(task.dueDate, isNull);
    });

    test('fromMap handles invalid priority index', () {
      final map = {
        'id': 'xyz',
        'isChecked': false,
        'taskTitle': 'Write report',
        'priority': 99,
      };
      final task = TaskModel.fromMap(map);
      expect(task.priority, TaskPriority.medium); // defaults to medium
    });

    test('toJson and fromJson round-trip', () {
      final task = TaskModel(
        id: 'xyz',
        taskTitle: 'Write report',
        priority: TaskPriority.low,
      );
      final json = task.toJson();
      final restored = TaskModel.fromJson(json);
      expect(restored, task);
    });

    test('props are used for equality', () {
      final a = TaskModel(id: 'same', taskTitle: 'Task');
      final b = TaskModel(id: 'same', taskTitle: 'Task');
      final c = TaskModel(id: 'other', taskTitle: 'Task');
      expect(a, b);
      expect(a != c, true);
    });
  });
}
