import 'package:equatable/equatable.dart';

sealed class SttState extends Equatable {
  const SttState();

  @override
  List<Object?> get props => [];
}

class SttInitial extends SttState {
  const SttInitial();
}

class SttRecording extends SttState {
  const SttRecording();
}

class SttTranscribing extends SttState {
  const SttTranscribing();
}

class SttResult extends SttState {
  final String text;

  const SttResult({required this.text});

  @override
  List<Object?> get props => [text];
}

class SttError extends SttState {
  final String message;

  const SttError({required this.message});

  @override
  List<Object?> get props => [message];
}
