import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/data/models/task_model.dart';
import 'package:doist/home_tab/view/widgets/priority_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpChip(WidgetTester tester, TaskPriority priority) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: Center(child: PriorityChip(priority: priority)),
        ),
      ),
    );
  }

  testWidgets('shows the localized label for each priority', (tester) async {
    await pumpChip(tester, TaskPriority.high);
    expect(find.text(S().priority_high), findsOneWidget);

    await pumpChip(tester, TaskPriority.medium);
    expect(find.text(S().priority_medium), findsOneWidget);

    await pumpChip(tester, TaskPriority.low);
    expect(find.text(S().priority_low), findsOneWidget);
  });

  testWidgets('colors differ per priority', (tester) async {
    Color? containerColor(TaskPriority priority) {
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration?;
      return decoration?.color;
    }

    await pumpChip(tester, TaskPriority.high);
    final highColor = containerColor(TaskPriority.high);
    await pumpChip(tester, TaskPriority.low);
    final lowColor = containerColor(TaskPriority.low);

    expect(highColor, isNot(equals(lowColor)));
  });
}
