import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:record/record.dart';

import 'stt_service.dart';

class GroqSttService implements SttService {
  GroqSttService({
    required this.apiKey,
    required this.httpClient,
    required this.audioRecorder,
  });

  final String apiKey;
  final http.Client httpClient;
  final AudioRecorder audioRecorder;

  static const _groqUrl =
      'https://api.groq.com/openai/v1/audio/transcriptions';

  @override
  Future<String> recordAndTranscribe() async {
    await audioRecorder.start(
      const RecordConfig(),
      path: await _tempAudioPath(),
    );
    final filePath = await audioRecorder.stop();
    if (filePath == null) {
      throw Exception('Audio recording failed: no file path returned');
    }
    await audioRecorder.dispose();

    return _transcribeFile(filePath);
  }

  Future<String> _tempAudioPath() async {
    return '${Directory.systemTemp.path}/doist_stt_${DateTime.now().millisecondsSinceEpoch}.wav';
  }

  Future<String> _transcribeFile(String filePath) async {
    final file = File(filePath);
    final request = http.MultipartRequest('POST', Uri.parse(_groqUrl))
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['model'] = 'whisper-large-v3-turbo'
      ..fields['response_format'] = 'json'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Groq Whisper error: ${response.statusCode} ${response.body}');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return decoded['text'] as String;
  }
}
