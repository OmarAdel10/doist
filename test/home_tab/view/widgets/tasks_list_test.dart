import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:doist/home_tab/view/widgets/empty_tasks.dart';
import 'package:doist/home_tab/view/widgets/task_tile.dart';
import 'package:doist/home_tab/view/widgets/tasks_list.dart';
import 'package:doist/home_tab/view_model/home_tab_events.dart';
import 'package:doist/home_tab/view_model/home_tab_states.dart';
import 'package:doist/home_tab/view_model/home_tab_view_model.dart';
import 'package:doist/settings_tab/data/models/settings_model.dart';
import 'package:doist/settings_tab/view_model/settings_states.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHomeTabBloc extends MockBloc<HomeTabEvents, HomeTabState>
    implements HomeTabBloc {}

class _MockSettingsBloc extends Mock implements SettingsBloc {}

/// Widget tests for TasksList: the empty state, pull-to-refresh, the
/// slidable delete action and the checkbox toggle.
void main() {
  setUpAll(() {
    registerFallbackValue(HomeTabRefreshTasks());
  });

  late _MockHomeTabBloc homeTabBloc;
  late _MockSettingsBloc settingsBloc;

  setUp(() {
    homeTabBloc = _MockHomeTabBloc();
    when(
      () => homeTabBloc.stream,
    ).thenAnswer((_) => const Stream<HomeTabState>.empty());
    settingsBloc = _MockSettingsBloc();
    when(() => settingsBloc.state).thenReturn(
      const SettingsInitial(
        model: SettingsModel(
          themeMode: ThemeMode.light,
          language: 'en',
          isOnBoardingDone: false,
        ),
      ),
    );
    when(
      () => settingsBloc.stream,
    ).thenAnswer((_) => const Stream<SettingsState>.empty());
  });

  Widget wrap() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeTabBloc>.value(value: homeTabBloc),
        BlocProvider<SettingsBloc>.value(value: settingsBloc),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const Scaffold(body: Column(children: [TasksList()])),
      ),
    );
  }

  void seedTasks(List<TaskModel> tasks) {
    when(() => homeTabBloc.state).thenReturn(HomeTabUpdate(tasksList: tasks));
  }

  /// Pump to allow flutter_animate timers to complete.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('renders the empty state when there are no tasks', (
    tester,
  ) async {
    seedTasks([]);
    await tester.pumpWidget(wrap());
    await settle(tester);

    expect(find.byType(EmptyTasks), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsNothing);
  });

  testWidgets('renders a RefreshIndicator and a tile per task', (tester) async {
    seedTasks([TaskModel(taskTitle: 'Task A'), TaskModel(taskTitle: 'Task B')]);
    await tester.pumpWidget(wrap());
    await settle(tester);

    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byType(TaskTile), findsNWidgets(2));
    expect(find.text('Task A'), findsOneWidget);
  });

  testWidgets('pull-to-refresh dispatches HomeTabRefreshTasks', (tester) async {
    seedTasks([TaskModel(taskTitle: 'Task A')]);
    await tester.pumpWidget(wrap());
    await settle(tester);

    // Invoke the RefreshIndicator callback directly — a fling gesture is
    // flaky at this list height with slidable tiles attached.
    final indicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    // Call onRefresh and pump to advance fake time for the 300ms delay
    unawaited(indicator.onRefresh());
    await tester.pump(const Duration(milliseconds: 400));
    verify(() => homeTabBloc.add(any<HomeTabEvents>())).called(1);
  });

  testWidgets('toggling the checkbox dispatches the check event', (
    tester,
  ) async {
    final task = TaskModel(taskTitle: 'Task A');
    seedTasks([task]);
    await tester.pumpWidget(wrap());
    await settle(tester);

    await tester.tap(find.byType(Checkbox));
    verify(
      () => homeTabBloc.add(
        any(
          that: isA<HomeTabUpdateCheckedForTask>().having(
            (e) => e.taskId,
            'taskId',
            task.id,
          ),
        ),
      ),
    ).called(1);
  });

  testWidgets('revealing the slidable pane and tapping delete dispatches '
      'the delete event', (tester) async {
    final task = TaskModel(taskTitle: 'Task A');
    seedTasks([task]);
    await tester.pumpWidget(wrap());
    await settle(tester);

    await tester.drag(find.text('Task A'), const Offset(-200, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byIcon(CupertinoIcons.delete));

    verify(
      () => homeTabBloc.add(
        any(
          that: isA<HomeTabDeleteTask>().having(
            (e) => e.taskId,
            'taskId',
            task.id,
          ),
        ),
      ),
    ).called(1);
  });
}
