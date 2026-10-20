import 'package:equatable/equatable.dart';

import 'package:doist/home_tab/data/models/task_model.dart';

/// Abstract base class for all LLM-related events.
sealed class LlmEvent extends Equatable {
  const LlmEvent();

  @override
  List<Object?> get props => [];
}

/// Request to parse natural-language input into a structured task.
class LlmParseTask extends LlmEvent {
  final String input;

  const LlmParseTask({required this.input});

  @override
  List<Object?> get props => [input];
}

/// Request to break a task title into subtask titles.
class LlmBreakdownTask extends LlmEvent {
  final String title;

  const LlmBreakdownTask({required this.title});

  @override
  List<Object?> get props => [title];
}

/// Request to prioritize a list of tasks.
class LlmPrioritizeTasks extends LlmEvent {
  final List<TaskModel> tasks;

  const LlmPrioritizeTasks({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}

/// Clear the LLM state back to initial.
class LlmClear extends LlmEvent {
  const LlmClear();

  @override
  List<Object?> get props => [];
}
