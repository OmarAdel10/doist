import 'package:bloc_test/bloc_test.dart';
import 'package:doist/features/llm/llm_bloc.dart';
import 'package:doist/features/llm/llm_event.dart';
import 'package:doist/features/llm/llm_service.dart';
import 'package:doist/features/llm/llm_state.dart';
import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLlmService extends Mock implements LlmService {}

void main() {
  late LlmService llmService;
  late LlmBloc llmBloc;

  setUp(() {
    llmService = _MockLlmService();
    llmBloc = LlmBloc(llmService: llmService);
  });

  test('initial state is LlmInitial', () {
    expect(llmBloc.state, const LlmInitial());
  });

  blocTest<LlmBloc, LlmState>(
    'emits [LlmLoading, LlmParsedTask] on LlmParseTask',
    build: () => llmBloc,
    setUp: () {
      when(() => llmService.parseNaturalLanguage(any())).thenAnswer(
        (_) async => ParsedTask(
          title: 'Buy milk',
          dueDate: DateTime(2026, 10, 25),
          priority: TaskPriority.high,
        ),
      );
    },
    act: (bloc) => bloc.add(const LlmParseTask(input: 'buy milk tomorrow')),
    expect: () => [
      const LlmLoading(),
      LlmParsedTask(
        task: ParsedTask(
          title: 'Buy milk',
          dueDate: DateTime(2026, 10, 25),
          priority: TaskPriority.high,
        ),
      ),
    ],
  );

  blocTest<LlmBloc, LlmState>(
    'emits [LlmLoading, LlmBreakdown] on LlmBreakdownTask',
    build: () => llmBloc,
    setUp: () {
      when(
        () => llmService.breakdownTask(any()),
      ).thenAnswer((_) async => ['Buy milk', 'Put in fridge', 'Drink']);
    },
    act: (bloc) => bloc.add(const LlmBreakdownTask(title: 'Buy milk')),
    expect: () => [
      const LlmLoading(),
      LlmBreakdown(subtasks: ['Buy milk', 'Put in fridge', 'Drink']),
    ],
  );

  blocTest<LlmBloc, LlmState>(
    'emits [LlmLoading, LlmPrioritized] on LlmPrioritizeTasks',
    build: () => llmBloc,
    setUp: () {
      final tasks = [
        TaskModel(taskTitle: 'Task A', priority: TaskPriority.low),
        TaskModel(taskTitle: 'Task B', priority: TaskPriority.high),
      ];
      when(() => llmService.prioritizeTasks(any())).thenAnswer(
        (_) async => [
          TaskSuggestion(
            taskId: tasks[0].id,
            reason: 'Do first',
            newPriority: TaskPriority.high,
          ),
        ],
      );
      _prioritizeTasks = tasks;
    },
    act: (bloc) => bloc.add(LlmPrioritizeTasks(tasks: _prioritizeTasks)),
    expect: () => [
      const LlmLoading(),
      LlmPrioritized(
        suggestions: [
          TaskSuggestion(
            taskId: _prioritizeTasks[0].id,
            reason: 'Do first',
            newPriority: TaskPriority.high,
          ),
        ],
      ),
    ],
  );

  blocTest<LlmBloc, LlmState>(
    'emits [LlmLoading, LlmError] on LlmParseTask failure',
    build: () => llmBloc,
    setUp: () {
      when(
        () => llmService.parseNaturalLanguage(any()),
      ).thenThrow(Exception('LLM error'));
    },
    act: (bloc) => bloc.add(const LlmParseTask(input: 'buy milk tomorrow')),
    expect: () => [
      const LlmLoading(),
      isA<LlmError>().having(
        (s) => s.message,
        'message',
        contains('LLM error'),
      ),
    ],
  );
}

late List<TaskModel> _prioritizeTasks;
