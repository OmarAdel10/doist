import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:doist/home_tab/data/models/task_model.dart';
import 'llm_service.dart';

/// Wraps [GenerativeModel] from package:google_generative_ai to satisfy
/// [LlmModel] for testability (GenerativeModel is final and cannot be mocked).
class GeminiLlmModel implements LlmModel {
  final GenerativeModel _model;

  GeminiLlmModel(this._model);

  @override
  Future<String> generateText(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }
}

/// Concrete [LlmService] backed by Google AI Studio's Gemini API.
class GeminiLlmService implements LlmService {
  GeminiLlmService({required this.llmModel});

  final LlmModel llmModel;

  static const _modelName = 'gemini-1.5-flash';

  /// Creates a real [GeminiLlmService] backed by the Gemini API.
  /// Use [apiKey] for authentication; the underlying [GenerativeModel] is
  /// built from [apiKey].
  GeminiLlmService.real({required String apiKey})
    : llmModel = GeminiLlmModel(
        GenerativeModel(model: _modelName, apiKey: apiKey),
      );

  @override
  Future<ParsedTask> parseNaturalLanguage(String input) async {
    final prompt =
        '''
Parse the following natural-language input into a structured task. Return ONLY valid JSON with these keys:
- "title": short task title (string, required)
- "dueDate": ISO-8601 date (string, optional, null if none mentioned)
- "priority": one of "low", "medium", "high" (string, default "medium")

Input: $input
''';
    final text = await llmModel.generateText(prompt);
    return _parseTaskJson(text);
  }

  @override
  Future<List<String>> breakdownTask(String title) async {
    final prompt =
        '''
Break the following task into 3-5 concrete, actionable subtask titles. Return ONLY valid JSON: a JSON array of strings.

Task: $title
''';
    final text = await llmModel.generateText(prompt);
    return _parseStringList(text);
  }

  @override
  Future<List<TaskSuggestion>> prioritizeTasks(List<TaskModel> tasks) async {
    final taskList = tasks
        .map((t) => '- ${t.id}: ${t.taskTitle} (priority: ${t.priority})')
        .join('\n');
    final prompt =
        '''
Prioritize the following tasks. Return ONLY valid JSON: a JSON array of objects, each with:
- "taskId": the task's id (string)
- "reason": short justification (string)
- "newPriority": one of "low", "medium", "high" (string)

Tasks:
$taskList
''';
    final text = await llmModel.generateText(prompt);
    return _parseTaskSuggestions(text);
  }

  ParsedTask _parseTaskJson(String text) {
    final cleaned = _stripCodeFences(text);
    final decoded = json.decode(cleaned) as Map<String, dynamic>;
    return ParsedTask(
      title: decoded['title'] as String? ?? '',
      dueDate: decoded['dueDate'] != null
          ? DateTime.tryParse(decoded['dueDate'] as String)
          : null,
      priority: _parsePriority(decoded['priority'] as String?),
    );
  }

  List<String> _parseStringList(String text) {
    final cleaned = _stripCodeFences(text);
    final decoded = json.decode(cleaned) as List<dynamic>;
    return decoded.cast<String>();
  }

  List<TaskSuggestion> _parseTaskSuggestions(String text) {
    final cleaned = _stripCodeFences(text);
    final decoded = json.decode(cleaned) as List<dynamic>;
    return decoded.map((item) {
      final map = item as Map<String, dynamic>;
      return TaskSuggestion(
        taskId: map['taskId'] as String? ?? '',
        reason: map['reason'] as String? ?? '',
        newPriority: _parsePriority(map['newPriority'] as String?),
      );
    }).toList();
  }

  TaskPriority _parsePriority(String? value) {
    switch (value?.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }

  String _stripCodeFences(String text) {
    final cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      final firstNewline = cleaned.indexOf('\n');
      if (firstNewline != -1) {
        return cleaned.substring(firstNewline + 1).replaceAll('```', '').trim();
      }
    }
    return cleaned.replaceAll('```', '').trim();
  }
}
