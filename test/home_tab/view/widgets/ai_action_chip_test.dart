import 'package:doist/home_tab/view/widgets/ai_action_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AiActionChip shows label and icon and calls onTap', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiActionChip(
            label: 'Break down task',
            icon: Icons.auto_awesome,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Break down task'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);

    await tester.tap(find.byType(AiActionChip));
    expect(tapped, isTrue);
  });

  testWidgets('AiActionChip with null onTap is not pressable', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiActionChip(
            label: 'Break down task',
            icon: Icons.auto_awesome,
            onTap: null,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AiActionChip), warnIfMissed: false);
    expect(tapped, isFalse);
  });
}
