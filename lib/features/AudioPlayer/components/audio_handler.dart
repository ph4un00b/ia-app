import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';

class LolaAudioHandler extends StatelessWidget {
  const LolaAudioHandler({
    super.key,
    required this.stream,
    required this.scale,
    required this.lolaController,
  });

  final Stream<AudioState>? stream;
  final double scale;
  final AudioPlayerHandlers lolaController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snap) {
        final ui = snap.data;
        return switch (ui) {
          null => Container(),
          NoAudioPath() => ui.build(scale: scale),
          PlayingAudio() => ui.build(
              scale: scale,
              onStop: lolaController.stopAudio,
            ),
          PlayingAudioErr() => ui.build(
              scale: scale,
              onRetry: lolaController.playAudio,
            ),
          PlayingAudioOk() => ui.build(
              from: lolaController.toString(),
              scale: scale,
              onReplay: lolaController.playAudio,
            ),
          Stopped() => ui.build(
              scale: scale,
              onPlay: lolaController.playAudio,
            ),
          StoppedErr() => ui.build(
              scale: scale,
              onPlay: lolaController.playAudio,
            ),
        };
      },
    );
  }
}
