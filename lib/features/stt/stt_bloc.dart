import 'package:bloc/bloc.dart';

import 'stt_event.dart';
import 'stt_service.dart';
import 'stt_state.dart';

class SttBloc extends Bloc<SttEvent, SttState> {
  SttBloc({required this.sttService}) : super(const SttInitial()) {
    on<SttStartRecording>((event, emit) => emit(const SttRecording()));
    on<SttStopRecording>((event, emit) => emit(const SttInitial()));

    on<SttTranscribeFile>((event, emit) async {
      emit(const SttTranscribing());
      try {
        final text = await sttService.recordAndTranscribe();
        emit(SttResult(text: text));
      } catch (e) {
        emit(SttError(message: e.toString()));
      }
    });
  }

  final SttService sttService;
}
