import 'dart:convert';
import 'dart:io';

import 'package:doist/features/stt/groq_stt_service.dart';
import 'package:doist/features/stt/stt_service.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';

class _FakeBaseRequest extends Fake implements http.BaseRequest {}

class _FakeRecordConfig extends Fake implements RecordConfig {}

class _MockClient extends Mock implements http.Client {}

class _MockAudioRecorder extends Mock implements AudioRecorder {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeBaseRequest());
    registerFallbackValue(_FakeRecordConfig());
  });
  test(
    'transcribes audio via Groq Whisper with model whisper-large-v3-turbo',
    () async {
      final client = _MockClient();
      when(() => client.send(any())).thenAnswer(
        (_) async => http.StreamedResponse(
          Stream.value(utf8.encode('{"text":"Buy milk"}')),
          200,
        ),
      );
      final recorder = _MockAudioRecorder();
      when(
        () => recorder.start(any(), path: any(named: 'path')),
      ).thenAnswer((_) async {});
      final tempFile = File(
        '${Directory.systemTemp.path}/doist_test_stt_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      await tempFile.writeAsBytes(utf8.encode('fake audio'));
      when(() => recorder.stop()).thenAnswer((_) async => tempFile.path);
      when(() => recorder.dispose()).thenAnswer((_) async {});

      final service = GroqSttService(
        apiKey: 'k',
        httpClient: client,
        audioRecorder: recorder,
      );
      final result = await service.recordAndTranscribe();
      expect(result, 'Buy milk');

      final verification = verify(() => client.send(captureAny()));
      expect(verification.captured.length, 1);
      final req = verification.captured.single as http.MultipartRequest;
      expect(req.fields['model'], 'whisper-large-v3-turbo');
    },
  );

  test('throws when recorder returns null file path', () async {
    final client = _MockClient();
    final recorder = _MockAudioRecorder();
    when(
      () => recorder.start(any(), path: any(named: 'path')),
    ).thenAnswer((_) async {});
    when(() => recorder.stop()).thenAnswer((_) async => null);
    when(() => recorder.dispose()).thenAnswer((_) async {});

    final service = GroqSttService(
      apiKey: 'k',
      httpClient: client,
      audioRecorder: recorder,
    );

    expect(() => service.recordAndTranscribe(), throwsA(isA<Exception>()));
  });

  test('throws on non-200 Groq response', () async {
    final client = _MockClient();
    when(() => client.send(any())).thenAnswer(
      (_) async =>
          http.StreamedResponse(Stream.value(utf8.encode('Server error')), 500),
    );
    final recorder = _MockAudioRecorder();
    when(
      () => recorder.start(any(), path: any(named: 'path')),
    ).thenAnswer((_) async {});
    final tempFile = File(
      '${Directory.systemTemp.path}/doist_test_stt_${DateTime.now().millisecondsSinceEpoch}.wav',
    );
    await tempFile.writeAsBytes(utf8.encode('fake audio'));
    when(() => recorder.stop()).thenAnswer((_) async => tempFile.path);
    when(() => recorder.dispose()).thenAnswer((_) async {});

    final service = GroqSttService(
      apiKey: 'k',
      httpClient: client,
      audioRecorder: recorder,
    );

    expect(
      () => service.recordAndTranscribe(),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Groq Whisper error'),
        ),
      ),
    );
  });

  test('throws on malformed JSON response', () async {
    final client = _MockClient();
    when(() => client.send(any())).thenAnswer(
      (_) async => http.StreamedResponse(
        Stream.value(utf8.encode('not valid json')),
        200,
      ),
    );
    final recorder = _MockAudioRecorder();
    when(
      () => recorder.start(any(), path: any(named: 'path')),
    ).thenAnswer((_) async {});
    final tempFile = File(
      '${Directory.systemTemp.path}/doist_test_stt_${DateTime.now().millisecondsSinceEpoch}.wav',
    );
    await tempFile.writeAsBytes(utf8.encode('fake audio'));
    when(() => recorder.stop()).thenAnswer((_) async => tempFile.path);
    when(() => recorder.dispose()).thenAnswer((_) async {});

    final service = GroqSttService(
      apiKey: 'k',
      httpClient: client,
      audioRecorder: recorder,
    );

    expect(() => service.recordAndTranscribe(), throwsA(isA<Exception>()));
  });

  test('temp file cleaned up after successful transcription', () async {
    final client = _MockClient();
    when(() => client.send(any())).thenAnswer(
      (_) async => http.StreamedResponse(
        Stream.value(utf8.encode('{"text":"Buy milk"}')),
        200,
      ),
    );
    final recorder = _MockAudioRecorder();
    when(
      () => recorder.start(any(), path: any(named: 'path')),
    ).thenAnswer((_) async {});
    final tempFile = File(
      '${Directory.systemTemp.path}/doist_test_stt_${DateTime.now().millisecondsSinceEpoch}.wav',
    );
    await tempFile.writeAsBytes(utf8.encode('fake audio'));
    when(() => recorder.stop()).thenAnswer((_) async => tempFile.path);
    when(() => recorder.dispose()).thenAnswer((_) async {});

    final service = GroqSttService(
      apiKey: 'k',
      httpClient: client,
      audioRecorder: recorder,
    );
    await service.recordAndTranscribe();

    // Temp file should be deleted after transcription.
    expect(await tempFile.exists(), isFalse);
  });

  test('start() is called with a temp path under system temp dir', () async {
    final client = _MockClient();
    when(() => client.send(any())).thenAnswer(
      (_) async => http.StreamedResponse(
        Stream.value(utf8.encode('{"text":"Buy milk"}')),
        200,
      ),
    );
    final recorder = _MockAudioRecorder();
    when(
      () => recorder.start(any(), path: any(named: 'path')),
    ).thenAnswer((_) async {});
    final tempFile = File(
      '${Directory.systemTemp.path}/doist_test_stt_${DateTime.now().millisecondsSinceEpoch}.wav',
    );
    await tempFile.writeAsBytes(utf8.encode('fake audio'));
    when(() => recorder.stop()).thenAnswer((_) async => tempFile.path);
    when(() => recorder.dispose()).thenAnswer((_) async {});

    final service = GroqSttService(
      apiKey: 'k',
      httpClient: client,
      audioRecorder: recorder,
    );
    await service.recordAndTranscribe();

    // start() was invoked with a path argument (confirms _tempAudioPath output is used).
    verify(
      () => recorder.start(captureAny(), path: captureAny(named: 'path')),
    ).called(1);
    // The path used for recording is the temp file path, which lives under system temp.
    expect(tempFile.path, startsWith(Directory.systemTemp.path));
    expect(tempFile.path, endsWith('.wav'));
  });

  test('_transcribeFile throws when response missing text key', () async {
    final client = _MockClient();
    when(() => client.send(any())).thenAnswer(
      (_) async => http.StreamedResponse(Stream.value(utf8.encode('{}')), 200),
    );
    final recorder = _MockAudioRecorder();
    when(
      () => recorder.start(any(), path: any(named: 'path')),
    ).thenAnswer((_) async {});
    final tempFile = File(
      '${Directory.systemTemp.path}/doist_test_stt_${DateTime.now().millisecondsSinceEpoch}.wav',
    );
    await tempFile.writeAsBytes(utf8.encode('fake audio'));
    when(() => recorder.stop()).thenAnswer((_) async => tempFile.path);
    when(() => recorder.dispose()).thenAnswer((_) async {});

    final service = GroqSttService(
      apiKey: 'k',
      httpClient: client,
      audioRecorder: recorder,
    );

    expect(() => service.recordAndTranscribe(), throwsA(isA<TypeError>()));
  });

  test('_transcribeFile throws when audio file missing', () async {
    final client = _MockClient();
    when(() => client.send(any())).thenAnswer(
      (_) async => http.StreamedResponse(
        Stream.value(utf8.encode('{"text":"Buy milk"}')),
        200,
      ),
    );
    final recorder = _MockAudioRecorder();
    when(
      () => recorder.start(any(), path: any(named: 'path')),
    ).thenAnswer((_) async {});
    when(
      () => recorder.stop(),
    ).thenAnswer((_) async => '${Directory.systemTemp.path}/missing_file.wav');
    when(() => recorder.dispose()).thenAnswer((_) async {});

    final service = GroqSttService(
      apiKey: 'k',
      httpClient: client,
      audioRecorder: recorder,
    );

    expect(() => service.recordAndTranscribe(), throwsA(isA<Exception>()));
  });

  test('recordAndTranscribe propagates start() error', () async {
    final client = _MockClient();
    final recorder = _MockAudioRecorder();
    when(
      () => recorder.start(any(), path: any(named: 'path')),
    ).thenAnswer((_) async => throw Exception('mic error'));
    when(() => recorder.dispose()).thenAnswer((_) async {});

    final service = GroqSttService(
      apiKey: 'k',
      httpClient: client,
      audioRecorder: recorder,
    );

    expect(() => service.recordAndTranscribe(), throwsA(isA<Exception>()));
  });

  test('recordAndTranscribe propagates stop() error', () async {
    final client = _MockClient();
    final recorder = _MockAudioRecorder();
    when(
      () => recorder.start(any(), path: any(named: 'path')),
    ).thenAnswer((_) async {});
    when(
      () => recorder.stop(),
    ).thenAnswer((_) async => throw Exception('stop error'));
    when(() => recorder.dispose()).thenAnswer((_) async {});

    final service = GroqSttService(
      apiKey: 'k',
      httpClient: client,
      audioRecorder: recorder,
    );

    expect(() => service.recordAndTranscribe(), throwsA(isA<Exception>()));
  });

  test('GroqSttService satisfies SttService interface', () {
    final client = _MockClient();
    final recorder = _MockAudioRecorder();
    when(
      () => recorder.start(any(), path: any(named: 'path')),
    ).thenAnswer((_) async {});
    when(() => recorder.stop()).thenAnswer((_) async => '');
    when(() => recorder.dispose()).thenAnswer((_) async {});

    final service =
        GroqSttService(apiKey: 'k', httpClient: client, audioRecorder: recorder)
            as SttService;

    expect(service, isA<SttService>());
  });
}
