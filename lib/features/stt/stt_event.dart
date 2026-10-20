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
  final String filePath;

  const SttTranscribeFile({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}
