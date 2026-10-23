import 'package:doist/core/storage/secure_storage.dart';
import 'package:doist/features/llm/llm_bloc.dart';
import 'package:doist/features/llm/llm_service.dart';
import 'package:doist/features/llm/llm_state.dart';
import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:doist/home_tab/view/screens/home_tab.dart';
import 'package:doist/home_tab/view_model/home_tab_events.dart';
import 'package:doist/home_tab/view_model/home_tab_view_model.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockLlmService extends Mock implements LlmService {}

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockHydratedStorage extends Mock implements Storage {}

/// Integration tests for the LLM wiring: LlmBloc -> HomeTabBloc via the
/// HomeTab listeners and the AI action chips.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockHydratedStorage hydratedStorage;
  late _MockFlutterSecureStorage flutterSecureStorage;
  late SettingsBloc settingsBloc;

  setUp(() {
    hydratedStorage = _MockHydratedStorage();
    when(
      () => hydratedStorage.write(any(), any<dynamic>()),
    ).thenAnswer((_) async {});
    HydratedBloc.storage = hydratedStorage;

    flutterSecureStorage = _MockFlutterSecureStorage();
    when(
      () => flutterSecureStorage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => 'sk-test');
    settingsBloc = SettingsBloc(SecureStorage(flutterSecureStorage));
  });

  Future<(LlmBloc, HomeTabBloc)> pumpHomeTab(
    WidgetTester tester, {
    required LlmBloc llmBloc,
    _MockFlutterSecureStorage? storageMock,
  }) async {
    final homeTabBloc = HomeTabBloc();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>.value(value: settingsBloc),
          BlocProvider<HomeTabBloc>.value(value: homeTabBloc),
        ],
        child: MaterialApp(
          localizationsDelegates: [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: HomeTab(
              llmBloc: llmBloc,
              secureStorage: SecureStorage(storageMock ?? flutterSecureStorage),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    return (llmBloc, homeTabBloc);
  }

  testWidgets('breakdown chip adds each subtask as an AI task', (tester) async {
    final llmService = _MockLlmService();
    when(
      () => llmService.breakdownTask(any()),
    ).thenAnswer((_) async => ['Subtask A', 'Subtask B']);
    final (_, homeTabBloc) = await pumpHomeTab(
      tester,
      llmBloc: LlmBloc(llmService: llmService),
    );
    homeTabBloc.add(HomeTabAddTask(taskTitle: 'Plan the trip'));
    await tester.pump();

    await tester.tap(find.text(S().break_down_task));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final titles = homeTabBloc.state.tasksList.map((t) => t.taskTitle);
    expect(titles, containsAll(['Subtask A', 'Subtask B']));
    // Sanity: the prioritize chip is still rendered.
    expect(find.text(S().prioritize_my_day), findsOneWidget);
    homeTabBloc.close();
  });

  testWidgets('prioritize chip applies suggestions to the task list', (
    tester,
  ) async {
    final llmService = _MockLlmService();
    final (_, homeTabBloc) = await pumpHomeTab(
      tester,
      llmBloc: LlmBloc(llmService: llmService),
    );
    homeTabBloc.add(HomeTabAddTask(taskTitle: 'Task A'));
    homeTabBloc.add(HomeTabAddTask(taskTitle: 'Task B'));
    await tester.pump();

    final firstTask = homeTabBloc.state.tasksList.last;
    when(() => llmService.prioritizeTasks(any())).thenAnswer(
      (_) async => [
        TaskSuggestion(
          taskId: firstTask.id,
          reason: 'Deadline soon',
          newPriority: TaskPriority.high,
        ),
      ],
    );

    await tester.tap(find.text(S().prioritize_my_day));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final updated = homeTabBloc.state.tasksList.firstWhere(
      (t) => t.id == firstTask.id,
    );
    expect(updated.priority, TaskPriority.high);
    expect(find.text(S().break_down_task), findsOneWidget);
    homeTabBloc.close();
  });

  testWidgets('LLM failure shows an error snack and clears the state', (
    tester,
  ) async {
    final llmService = _MockLlmService();
    when(
      () => llmService.prioritizeTasks(any()),
    ).thenThrow(Exception('Gemini error: 429 rate limited'));
    final llmBloc = LlmBloc(llmService: llmService);
    final (_, homeTabBloc) = await pumpHomeTab(tester, llmBloc: llmBloc);
    homeTabBloc.add(HomeTabAddTask(taskTitle: 'Task A'));
    await tester.pump();

    await tester.tap(find.text(S().prioritize_my_day));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('rate limited'), findsOneWidget);
    expect(llmBloc.state, isA<LlmInitial>());
    expect(find.text(S().break_down_task), findsOneWidget);
    homeTabBloc.close();
  });

  testWidgets('missing Google key gates the chips with a hint snack', (
    tester,
  ) async {
    final storageMock = _MockFlutterSecureStorage();
    when(
      () => storageMock.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
    final llmService = _MockLlmService();
    final (_, homeTabBloc) = await pumpHomeTab(
      tester,
      llmBloc: LlmBloc(llmService: llmService),
      storageMock: storageMock,
    );
    homeTabBloc.add(HomeTabAddTask(taskTitle: 'Task A'));
    await tester.pump();

    await tester.tap(find.text(S().break_down_task));
    await tester.pump();

    expect(find.text(S().missing_google_key), findsOneWidget);
    verifyNever(() => llmService.breakdownTask(any()));
    homeTabBloc.close();
  });

  testWidgets('chips ask for a task first when the list is empty', (
    tester,
  ) async {
    final llmService = _MockLlmService();
    final (_, homeTabBloc) = await pumpHomeTab(
      tester,
      llmBloc: LlmBloc(llmService: llmService),
    );

    await tester.tap(find.text(S().break_down_task));
    await tester.pump();

    expect(find.text(S().add_task_first), findsOneWidget);
    verifyNever(() => llmService.breakdownTask(any()));
    homeTabBloc.close();
  });
}
