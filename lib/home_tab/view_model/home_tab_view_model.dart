import 'dart:developer';

import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:doist/home_tab/view_model/home_tab_events.dart';
import 'package:doist/home_tab/view_model/home_tab_states.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class HomeTabBloc extends HydratedBloc<HomeTabEvents, HomeTabState> {
  HomeTabBloc() : super(HomeTabInitial(tasksList: [])) {
    on<HomeTabAddTask>((event, emit) {
      final TaskModel model = TaskModel(taskTitle: event.taskTitle);
      final updatedTasksListForNewTask = [model, ...state.tasksList];
      emit(HomeTabUpdate(tasksList: updatedTasksListForNewTask));
    });

    on<HomeTabDeleteTask>((event, emit) {
      final updatedTasksListForRemovingSpecificTask = state.tasksList
          .where((task) => task.id != event.taskId)
          .toList();
      emit(HomeTabUpdate(tasksList: updatedTasksListForRemovingSpecificTask));
    });

    on<HomeTabUpdateCheckedForTask>((event, emit) {
      final currentList = state.tasksList;
      final updatedTasksListForUpdateSpecificTask = currentList.map((task) {
        if (task.id == event.taskId) {
          return task.copyWith(isChecked: !task.isChecked);
        }
        return task;
      }).toList();
      emit(HomeTabUpdate(tasksList: updatedTasksListForUpdateSpecificTask));
    });
  }

  @override
  HomeTabState? fromJson(Map<String, dynamic> json) {
    try {
      final tasksListFromJson = (json['tasksList'] as List<dynamic>)
          .map((item) => TaskModel.fromMap(item as Map<String, dynamic>))
          .toList();
      return HomeTabUpdate(tasksList: tasksListFromJson);
    } catch (e) {
      log('Error During Serialization: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(HomeTabState state) {
    try {
      final tasksListToJson = state.tasksList
          .map((task) => task.toMap())
          .toList();
      return {'tasksList': tasksListToJson};
    } catch (e) {
      log('Error During Serialization: $e');
      return null;
    }
  }
}
