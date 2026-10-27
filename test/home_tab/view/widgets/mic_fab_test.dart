import 'package:doist/features/stt/stt_bloc.dart';
import 'package:doist/features/stt/stt_event.dart';
import 'package:doist/features/stt/stt_state.dart';
import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/view/widgets/mic_fab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSttBloc extends Mock implements SttBloc {}

class _FakeSttEvent extends Fake implements SttStartRecording {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeSttEvent());
  });

  testWidgets('MicFab shows mic icon and starts the record flow on tap', (
    tester,
  ) async {
    final bloc = _MockSttBloc();
    when(() => bloc.state).thenReturn(const SttInitial());
    when(() => bloc.stream).thenAnswer((_) => const Stream<SttState>.empty());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(floatingActionButton: MicFab(sttBloc: bloc)),
      ),
    );

    expect(find.byIcon(CupertinoIcons.mic_fill), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    verify(() => bloc.add(const SttStartRecording())).called(1);
    verify(() => bloc.add(const SttTranscribeFile())).called(1);
  });

  testWidgets('MicFab uses the provided onTap override when given', (
    tester,
  ) async {
    final bloc = _MockSttBloc();
    when(() => bloc.state).thenReturn(const SttInitial());
    when(() => bloc.stream).thenAnswer((_) => const Stream<SttState>.empty());
    var overrideCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          floatingActionButton: MicFab(
            sttBloc: bloc,
            onTap: () => overrideCalled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    expect(overrideCalled, isTrue);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('MicFab shows a spinner and disables taps while transcribing', (
    tester,
  ) async {
    final bloc = _MockSttBloc();
    when(() => bloc.state).thenReturn(const SttTranscribing());
    when(() => bloc.stream).thenAnswer((_) => const Stream<SttState>.empty());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(floatingActionButton: MicFab(sttBloc: bloc)),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton), warnIfMissed: false);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('MicFab pulses while listening', (tester) async {
    final bloc = _MockSttBloc();
    when(() => bloc.state).thenReturn(const SttRecording());
    when(() => bloc.stream).thenAnswer((_) => const Stream<SttState>.empty());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(floatingActionButton: MicFab(sttBloc: bloc)),
      ),
    );
    // Start the animation — no pumpAndSettle, the pulse loops forever.
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Animate), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.mic_fill), findsOneWidget);
  });
}
