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
          NoAudioPath() => ui.build(scale: scale * 0.8),
          PlayingAudio() => ui.build(
              scale: scale * 0.8,
              onStop: lolaController.stopAudio,
            ),
          PlayingAudioErr() => ui.build(
              scale: scale * 0.8,
              onRetry: lolaController.playAudio,
            ),
          PlayingAudioOk() => ui.build(
              from: lolaController.toString(),
              scale: scale * 0.8,
              onReplay: lolaController.playAudio,
            ),
          Stopped() => ui.build(
              scale: scale * 0.8,
              onPlay: lolaController.playAudio,
            ),
          StoppedErr() => ui.build(
              scale: scale * 0.8,
              onPlay: lolaController.playAudio,
            ),
        };
      },
    );
  }
}
