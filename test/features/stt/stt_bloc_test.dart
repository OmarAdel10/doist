import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:doist/features/stt/stt_bloc.dart';
import 'package:doist/features/stt/stt_event.dart';
import 'package:doist/features/stt/stt_service.dart';
import 'package:doist/features/stt/stt_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSttService extends Mock implements SttService {}

void main() {
  late SttService sttService;
  late SttBloc sttBloc;

  setUp(() {
    sttService = _MockSttService();
    sttBloc = SttBloc(sttService: sttService);
  });

  test('initial state is SttInitial', () {
    expect(sttBloc.state, const SttInitial());
  });

  blocTest<SttBloc, SttState>(
    'emits [SttRecording] on SttStartRecording',
    build: () => sttBloc,
    act: (bloc) => bloc.add(const SttStartRecording()),
    expect: () => [const SttRecording()],
  );

  blocTest<SttBloc, SttState>(
    'emits [SttInitial] on SttStopRecording',
    build: () => sttBloc,
    seed: () => const SttRecording(),
    act: (bloc) => bloc.add(const SttStopRecording()),
    expect: () => [const SttInitial()],
  );

  blocTest<SttBloc, SttState>(
    'emits [SttTranscribing, SttResult] on SttTranscribeFile',
    build: () => sttBloc,
    setUp: () {
      when(
        () => sttService.recordAndTranscribe(),
      ).thenAnswer((_) async => 'Buy milk');
    },
    act: (bloc) => bloc.add(const SttTranscribeFile()),
    expect: () => [const SttTranscribing(), SttResult(text: 'Buy milk')],
  );

  blocTest<SttBloc, SttState>(
    'emits [SttTranscribing, SttError] on SttTranscribeFile failure',
    build: () => sttBloc,
    setUp: () {
      when(
        () => sttService.recordAndTranscribe(),
      ).thenThrow(Exception('Groq error'));
    },
    act: (bloc) => bloc.add(const SttTranscribeFile()),
    expect: () => [
      const SttTranscribing(),
      isA<SttError>().having(
        (s) => s.message,
        'message',
        contains('Groq error'),
      ),
    ],
  );

  blocTest<SttBloc, SttState>(
    'ignores duplicate SttTranscribeFile while one is in flight',
    build: () => sttBloc,
    setUp: () {
      final completer = Completer<String>();
      when(
        () => sttService.recordAndTranscribe(),
      ).thenAnswer((_) => completer.future);
      _pendingCompleter = completer;
    },
    act: (bloc) {
      bloc.add(const SttTranscribeFile());
      bloc.add(const SttTranscribeFile());
    },
    expect: () => [const SttTranscribing()],
    tearDown: () {
      if (!_pendingCompleter.isCompleted) {
        _pendingCompleter.complete('Buy milk');
      }
    },
  );
}

late Completer<String> _pendingCompleter;
