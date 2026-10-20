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

  static const _groqUrl = 'https://api.groq.com/openai/v1/audio/transcriptions';

  static const _requestTimeout = Duration(seconds: 30);

  @override
  Future<String> recordAndTranscribe() async {
    String? filePath;
    try {
      await audioRecorder.start(
        const RecordConfig(),
        path: await _tempAudioPath(),
      );
      filePath = await audioRecorder.stop();
      if (filePath == null) {
        throw Exception('Audio recording failed: no file path returned');
      }
      return await _transcribeFile(filePath);
    } finally {
      await audioRecorder.dispose();
      if (filePath != null) {
        await _deleteTempFile(filePath);
      }
    }
  }

  Future<void> _deleteTempFile(String filePath) async {
    try {
      await File(filePath).delete();
    } on FileSystemException {
      // Best-effort cleanup; ignore if already deleted or missing.
    }
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

    final streamedResponse = await httpClient
        .send(request)
        .timeout(_requestTimeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(
        'Groq Whisper error: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return decoded['text'] as String;
  }
}
