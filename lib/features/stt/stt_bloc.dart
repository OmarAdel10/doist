import 'package:bloc/bloc.dart';

import 'stt_event.dart';
import 'stt_service.dart';
import 'stt_state.dart';

class SttBloc extends Bloc<SttEvent, SttState> {
  SttBloc({required this.sttService}) : super(const SttInitial()) {
    on<SttStartRecording>((event, emit) => emit(const SttRecording()));
    on<SttStopRecording>((event, emit) => emit(const SttInitial()));

    on<SttTranscribeFile>((event, emit) async {
      // Guard against concurrent transcriptions: ignore duplicate requests
      // while one is already in flight.
      if (state is SttTranscribing || state is SttRecording) {
        return;
      }
      emit(const SttTranscribing());
      try {
        final text = await sttService.recordAndTranscribe();
        emit(SttResult(text: text));
      } catch (e) {
        emit(SttError(message: _sanitizeError(e)));
      }
    });
  }

  String _sanitizeError(Object e) {
    final msg = e.toString();
    final sanitized = msg
        .replaceAll(RegExp(r'Bearer\s+\S+'), 'Bearer ***')
        .replaceAll(
          RegExp(r'api[_-]?key[=:]\s*\S+', caseSensitive: false),
          'apiKey=***',
        )
        .replaceAll(RegExp(r'https?://[^\s]+'), '<url>');
    return sanitized.isEmpty ? 'An unexpected error occurred.' : sanitized;
  }

  final SttService sttService;
}
