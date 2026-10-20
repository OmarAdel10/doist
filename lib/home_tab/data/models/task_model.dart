import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
enum TaskPriority { low, medium, high }

class TaskModel extends Equatable {
  final String id;
  final bool isChecked;
  final String taskTitle;
  final TaskPriority priority;
  final DateTime? dueDate;

  TaskModel({
    String? id,
    this.isChecked = false,
    required this.taskTitle,
    this.priority = TaskPriority.medium,
    this.dueDate,
  }) : id = id ?? const Uuid().v4();

  TaskModel copyWith({
    String? id,
    bool? isChecked,
    String? taskTitle,
    TaskPriority? priority,
    DateTime? dueDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      isChecked: isChecked ?? this.isChecked,
      taskTitle: taskTitle ?? this.taskTitle,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'isChecked': isChecked,
      'taskTitle': taskTitle,
      'priority': priority.index,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String?,
      isChecked: map['isChecked'] as bool,
      taskTitle: map['taskTitle'] as String,
      priority: TaskPriority.values[map['priority'] as int? ?? 1],
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [id, isChecked, taskTitle, priority, dueDate];
}
