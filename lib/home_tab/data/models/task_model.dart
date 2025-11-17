import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class TaskModel {
  final bool isChecked;
  final String taskTitle;

  const TaskModel({this.isChecked = false, required this.taskTitle});

  TaskModel copyWith({
    bool? isChecked,
    String? taskTitle,
  }) {
    return TaskModel(
      isChecked: isChecked ?? this.isChecked,
      taskTitle: taskTitle ?? this.taskTitle,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isChecked': isChecked,
      'taskTitle': taskTitle,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      isChecked: map['isChecked'] as bool,
      taskTitle: map['taskTitle'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) => TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
