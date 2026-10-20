import 'dart:convert';
import 'dart:io';

import 'package:doist/features/stt/groq_stt_service.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
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
  test('transcribes audio via Groq Whisper with model whisper-large-v3-turbo', () async {
    final client = _MockClient();
    when(() => client.send(any())).thenAnswer((_) async =>
        http.StreamedResponse(
          Stream.value(utf8.encode('{"text":"Buy milk"}')), 200,
        ));
    final recorder = _MockAudioRecorder();
    when(() => recorder.start(any(), path: any(named: 'path'))).thenAnswer((_) async {});
    final tempFile = File('${Directory.systemTemp.path}/doist_test_stt_${DateTime.now().millisecondsSinceEpoch}.wav');
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
  });
}
