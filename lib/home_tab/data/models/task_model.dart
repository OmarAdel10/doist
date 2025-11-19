import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class TaskModel extends Equatable {
  final String id;
  final bool isChecked;
  final String taskTitle;

  TaskModel({String? id, this.isChecked = false, required this.taskTitle})
      : id = id ?? const Uuid().v4();

  TaskModel copyWith({String? id, bool? isChecked, String? taskTitle}) {
    return TaskModel(
      id: id ?? this.id,
      isChecked: isChecked ?? this.isChecked,
      taskTitle: taskTitle ?? this.taskTitle,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'isChecked': isChecked,
      'taskTitle': taskTitle
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      isChecked: map['isChecked'] as bool,
      taskTitle: map['taskTitle'] as String,
    );
  }

  String toJson() => json.encode(toMap()); 

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [id, isChecked, taskTitle];
}
