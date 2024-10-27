import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';

class AudioHandler extends StatelessWidget {
  const AudioHandler({
    super.key,
    required this.stream,
    required this.scale,
    required this.controller,
  });

  final Stream<AudioState>? stream;
  final double scale;
  final AudioPlayerHandlers controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snap) {
        final ui = snap.data;
        return switch (ui) {
          null => Container(),
          NoAudioPath() => ui.actionDisabled(scale: scale),
          PlayingAudio() => ui.stop(
              scale: scale,
              onStop: controller.stopAudio,
            ),
          PlayingAudioErr() => ui.replay(
              scale: scale,
              onRetry: controller.playAudio,
            ),
          PlayingAudioOk() => ui.replay(
              scale: scale,
              onReplay: controller.playAudio,
            ),
          Stopped() => ui.play(
              scale,
              onPlay: controller.playAudio,
            ),
          StoppedErr() => ui.play(
              scale,
              onPlay: controller.playAudio,
            ),
        };
      },
    );
  }
}
