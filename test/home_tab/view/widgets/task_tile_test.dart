import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:doist/home_tab/view/widgets/task_tile.dart';
import 'package:doist/settings_tab/data/models/settings_model.dart';
import 'package:doist/settings_tab/view_model/settings_states.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsBloc extends Mock implements SettingsBloc {}

/// Widget tests for TaskTile: title styling (strikethrough when done),
/// the due-date subtitle and the checkbox callback.
void main() {
  late _MockSettingsBloc settingsBloc;

  setUp(() {
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

  Widget wrap(TaskModel model, {void Function(bool?)? onChanged}) {
    return BlocProvider<SettingsBloc>.value(
      value: settingsBloc,
      child: MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: ListTileTheme(
            child: TaskTile(model: model, onChanged: onChanged),
          ),
        ),
      ),
    );
  }

  testWidgets('draws a strikethrough over completed task titles', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(TaskModel(taskTitle: 'Done task', isChecked: true)),
    );

    final style = tester.widget<Text>(find.text('Done task')).style;
    expect(style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('leaves open task titles undecorated', (tester) async {
    await tester.pumpWidget(wrap(TaskModel(taskTitle: 'Open task')));

    final style = tester.widget<Text>(find.text('Open task')).style;
    expect(style?.decoration, TextDecoration.none);
  });

  testWidgets('shows the due date as an MMMd label when set', (tester) async {
    final dueDate = DateTime(2026, 10, 23);
    await tester.pumpWidget(
      wrap(TaskModel(taskTitle: 'Task A', dueDate: dueDate)),
    );

    expect(find.text(DateFormat.MMMd().format(dueDate)), findsOneWidget);
  });

  testWidgets('shows no due-date label when unset', (tester) async {
    await tester.pumpWidget(wrap(TaskModel(taskTitle: 'Task A')));

    // Only the title and the dense priority chip should be present.
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('forwards checkbox taps to onChanged', (tester) async {
    bool? reported;
    await tester.pumpWidget(
      wrap(TaskModel(taskTitle: 'Task A'), onChanged: (val) => reported = val),
    );

    await tester.tap(find.byType(Checkbox));
    expect(reported, isTrue);
  });
}
