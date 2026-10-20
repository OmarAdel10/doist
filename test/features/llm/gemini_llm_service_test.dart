import 'dart:convert';

import 'package:doist/features/llm/gemini_llm_service.dart';
import 'package:doist/features/llm/llm_service.dart';
import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLlmModel extends Mock implements LlmModel {}

void main() {
  late LlmModel model;
  late GeminiLlmService service;

  setUp(() {
    model = _MockLlmModel();
    service = GeminiLlmService(llmModel: model);
  });

  test('parseNaturalLanguage parses JSON response into ParsedTask', () async {
    when(() => model.generateText(any())).thenAnswer(
      (_) async => json.encode({
        'title': 'Buy milk',
        'dueDate': '2026-10-25',
        'priority': 'high',
      }),
    );

    final result = await service.parseNaturalLanguage('buy milk tomorrow');

    expect(result, isA<ParsedTask>());
    expect(result.title, 'Buy milk');
    expect(result.dueDate, DateTime(2026, 10, 25));
    expect(result.priority, TaskPriority.high);
  });
}
