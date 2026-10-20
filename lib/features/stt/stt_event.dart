import 'package:equatable/equatable.dart';

sealed class SttEvent extends Equatable {
  const SttEvent();

  @override
  List<Object?> get props => [];
}

class SttStartRecording extends SttEvent {
  const SttStartRecording();
}

class SttStopRecording extends SttEvent {
  const SttStopRecording();
}

class SttTranscribeFile extends SttEvent {
  const SttTranscribeFile();

  @override
  List<Object?> get props => [];
}
