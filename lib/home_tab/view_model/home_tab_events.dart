import 'package:equatable/equatable.dart';

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
