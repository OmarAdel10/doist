import 'package:doist/features/stt/stt_bloc.dart';
import 'package:doist/features/stt/stt_event.dart';
import 'package:doist/features/stt/stt_state.dart';
import 'package:doist/generated/l10n.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Floating action button that starts the voice-to-task flow.
///
/// Default tap behaviour dispatches [SttStartRecording] followed by
/// [SttTranscribeFile]; an [onTap] override (e.g. a missing-API-key gate)
/// replaces it entirely. Shows a pulse while listening and a spinner while
/// transcribing.
class MicFab extends StatelessWidget {
  const MicFab({super.key, required this.sttBloc, this.onTap});

  final SttBloc sttBloc;

  /// Optional tap override; when null the default record flow runs.
  final VoidCallback? onTap;

  void _startFlow() {
    sttBloc
      ..add(const SttStartRecording())
      ..add(const SttTranscribeFile());
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    return BlocBuilder<SttBloc, SttState>(
      bloc: sttBloc,
      builder: (context, state) {
        final listening = state is SttRecording;
        final transcribing = state is SttTranscribing;

        Widget child = Icon(
          CupertinoIcons.mic_fill,
          color: listening ? AppTheme.lightModeSecondry : null,
        );
        if (listening) {
          child = child
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(end: 1.2, duration: 400.ms, curve: Curves.easeInOut);
        }

        return FloatingActionButton(
          onPressed: transcribing ? null : (onTap ?? _startFlow),
          tooltip: transcribing
              ? localization.stt_transcribing
              : localization.stt_listening,
          child: transcribing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : child,
        );
      },
    );
  }
}
