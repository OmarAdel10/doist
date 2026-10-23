import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/view/widgets/empty_tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmptyTasks shows the title and the hint', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: const Scaffold(body: EmptyTasks()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(S().no_tasks_yet), findsOneWidget);
    expect(find.text(S().add_first_task), findsOneWidget);
    expect(find.byIcon(Icons.task_alt), findsOneWidget);
  });
}
