import 'package:equatable/equatable.dart';

import 'package:doist/home_tab/data/models/task_model.dart';

/// Abstract interface for an LLM text-generation model.
/// Injected into [GeminiLlmService] so tests can mock the model without
/// depending on the final [GenerativeModel] class from package:google_generative_ai.
abstract class LlmModel {
  /// Generates text for [prompt] and returns the raw response string.
  Future<String> generateText(String prompt);
}

/// Result of parsing natural language into a structured task.
class ParsedTask extends Equatable {
  final String title;
  final DateTime? dueDate;
  final TaskPriority priority;

  const ParsedTask({required this.title, this.dueDate, required this.priority});

  @override
  List<Object?> get props => [title, dueDate, priority];
}

/// A suggestion to reprioritize an existing task.
class TaskSuggestion extends Equatable {
  final String taskId;
  final String reason;
  final TaskPriority newPriority;

  const TaskSuggestion({
    required this.taskId,
    required this.reason,
    required this.newPriority,
  });

  @override
  List<Object?> get props => [taskId, reason, newPriority];
}

/// Abstract service for LLM-powered capabilities in Doist.
abstract class LlmService {
  /// Parses a natural-language input into a structured [ParsedTask].
  Future<ParsedTask> parseNaturalLanguage(String input);

  /// Breaks a [title] down into a list of concrete subtask titles.
  Future<List<String>> breakdownTask(String title);

  /// Prioritizes a list of [tasks] and returns suggestions.
  Future<List<TaskSuggestion>> prioritizeTasks(List<TaskModel> tasks);
}
