import 'package:doist/core/storage/secure_storage.dart';
import 'package:doist/core/storage/secure_storage_keys.dart';
import 'package:doist/features/llm/gemini_llm_service.dart';
import 'package:doist/features/llm/llm_bloc.dart';
import 'package:doist/features/stt/groq_stt_service.dart';
import 'package:doist/features/stt/stt_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';

/// Factory for constructing [SttBloc] and [LlmBloc] instances with their
/// dependencies. Centralizes concrete service construction so [HomeTab] is
/// not coupled to specific service implementations.
class HomeTabBlocFactory {
  HomeTabBlocFactory._();

  /// Creates an [SttBloc] backed by [GroqSttService]. When [httpClient] is
  /// omitted a new [http.Client] is created; the caller owns and must close
  /// that client.
  static SttBloc createSttBloc({
    required String groqApiKey,
    http.Client? httpClient,
  }) {
    return SttBloc(
      sttService: GroqSttService(
        apiKey: groqApiKey,
        httpClient: httpClient ?? http.Client(),
        audioRecorder: AudioRecorder(),
      ),
    );
  }

  /// Creates an [LlmBloc] backed by [GeminiLlmService.real].
  static LlmBloc createLlmBloc({required String googleApiKey}) {
    return LlmBloc(
      llmService: GeminiLlmService.real(apiKey: googleApiKey),
      apiKey: googleApiKey,
    );
  }

  /// Reads API keys from [secureStorage] and returns them as a map.
  static Future<Map<String, String>> readApiKeys(
    SecureStorage secureStorage,
  ) async {
    final groqKey =
        await secureStorage.read(SecureStorageKeys.groqApiKey) ?? '';
    final googleKey =
        await secureStorage.read(SecureStorageKeys.googleAiApiKey) ?? '';
    return {'groqApiKey': groqKey, 'googleApiKey': googleKey};
  }
}
