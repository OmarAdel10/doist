import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/view/widgets/empty_tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmptyTasks shows the title and the hint', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const Scaffold(body: EmptyTasks()),
      ),
    );
    // Use fixed duration pumps instead of pumpAndSettle to avoid
    // flutter_animate timer issues. Pump longer to ensure animation
    // completes and timers are cleaned up.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text(S().no_tasks_yet), findsOneWidget);
    expect(find.text(S().add_first_task), findsOneWidget);
    expect(find.byIcon(Icons.task_alt), findsOneWidget);
  });

  testWidgets('EmptyTasks renders Arabic strings under the ar locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const Scaffold(body: EmptyTasks()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('لا توجد مهام بعد'), findsOneWidget);
    expect(find.text('أضف مهمتك الأولى'), findsOneWidget);
  });
}
