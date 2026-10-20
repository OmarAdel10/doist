import 'package:equatable/equatable.dart';

import 'package:doist/features/llm/llm_service.dart';

/// Abstract base class for all LLM-related states.
sealed class LlmState extends Equatable {
  const LlmState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any LLM request.
class LlmInitial extends LlmState {
  const LlmInitial();
}

/// LLM request is in progress.
class LlmLoading extends LlmState {
  const LlmLoading();
}

/// LLM parsed a natural-language input into a task.
class LlmParsedTask extends LlmState {
  final ParsedTask task;

  const LlmParsedTask({required this.task});

  @override
  List<Object?> get props => [task];
}

/// LLM broke a task into subtasks.
class LlmBreakdown extends LlmState {
  final List<String> subtasks;

  const LlmBreakdown({required this.subtasks});

  @override
  List<Object?> get props => [subtasks];
}

/// LLM prioritized tasks and returned suggestions.
class LlmPrioritized extends LlmState {
  final List<TaskSuggestion> suggestions;

  const LlmPrioritized({required this.suggestions});

  @override
  List<Object?> get props => [suggestions];
}

/// LLM request failed.
class LlmError extends LlmState {
  final String message;

  const LlmError({required this.message});

  @override
  List<Object?> get props => [message];
}
