import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:equatable/equatable.dart';

sealed class HomeTabState extends Equatable {
  final List<TaskModel> tasksList;

  const HomeTabState({required this.tasksList});
}

class HomeTabInitial extends HomeTabState {
  const HomeTabInitial({required super.tasksList});

  @override
  List<Object?> get props => [tasksList];
}

class HomeTabUpdate extends HomeTabState {
  const HomeTabUpdate({required super.tasksList});

  @override
  List<Object?> get props => [tasksList];
}

class HomeTabError extends HomeTabState {
  final String message;

  const HomeTabError({required this.message, required super.tasksList});
  @override
  List<Object?> get props => [message, tasksList];
}
