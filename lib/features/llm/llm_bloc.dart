import 'package:bloc/bloc.dart';

import 'llm_event.dart';
import 'llm_service.dart';
import 'llm_state.dart';

/// BLoC orchestrating LLM-powered capabilities: natural-language task
/// parsing, task breakdown, and smart prioritization.
class LlmBloc extends Bloc<LlmEvent, LlmState> {
  LlmBloc({required this.llmService}) : super(const LlmInitial()) {
    on<LlmParseTask>((event, emit) async {
      emit(const LlmLoading());
      try {
        final task = await llmService.parseNaturalLanguage(event.input);
        emit(LlmParsedTask(task: task));
      } catch (e) {
        emit(LlmError(message: _sanitizeError(e)));
      }
    });

    on<LlmBreakdownTask>((event, emit) async {
      emit(const LlmLoading());
      try {
        final subtasks = await llmService.breakdownTask(event.title);
        emit(LlmBreakdown(subtasks: subtasks));
      } catch (e) {
        emit(LlmError(message: _sanitizeError(e)));
      }
    });

    on<LlmPrioritizeTasks>((event, emit) async {
      emit(const LlmLoading());
      try {
        final suggestions = await llmService.prioritizeTasks(event.tasks);
        emit(LlmPrioritized(suggestions: suggestions));
      } catch (e) {
        emit(LlmError(message: _sanitizeError(e)));
      }
    });

    on<LlmClear>((event, emit) => emit(const LlmInitial()));
  }

  final LlmService llmService;

  String _sanitizeError(Object e) {
    final msg = e.toString();
    final sanitized = msg
        .replaceAll(RegExp(r'Bearer\s+\S+'), 'Bearer ***')
        .replaceAll(
          RegExp(r'api[_-]?key[=:]\s*\S+', caseSensitive: false),
          'apiKey=***',
        )
        .replaceAll(RegExp(r'https?://[^\s]+'), '<url>');
    return sanitized.isEmpty ? 'An unexpected error occurred.' : sanitized;
  }
}
