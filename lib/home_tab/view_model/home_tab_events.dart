import 'package:equatable/equatable.dart';

import 'package:doist/home_tab/data/models/task_model.dart';

sealed class HomeTabEvents extends Equatable {}

class HomeTabAddTask extends HomeTabEvents {
  final String taskTitle;

  HomeTabAddTask({required this.taskTitle});
  @override
  List<Object?> get props => [taskTitle];
}

class HomeTabDeleteTask extends HomeTabEvents {
  final String taskId;

  HomeTabDeleteTask({required this.taskId});
  @override
  List<Object?> get props => [taskId];
}

class HomeTabUpdateCheckedForTask extends HomeTabEvents {
  final String taskId;

  HomeTabUpdateCheckedForTask({required this.taskId});
  @override
  List<Object?> get props => [taskId];
}

class HomeTabAddAiTask extends HomeTabEvents {
  final String taskTitle;

  HomeTabAddAiTask({required this.taskTitle});
  @override
  List<Object?> get props => [taskTitle];
}

class HomeTabReplaceTasks extends HomeTabEvents {
  final List<TaskModel> tasks;

  HomeTabReplaceTasks({required this.tasks});
  @override
  List<Object?> get props => [tasks];
}

class HomeTabRefreshTasks extends HomeTabEvents {
  @override
  List<Object?> get props => [];
}
