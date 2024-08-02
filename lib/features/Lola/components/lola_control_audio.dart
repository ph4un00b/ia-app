import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/lola_stream.dart';
import 'package:lola_ai_app/features/Lola/types.dart';

class LolaControlAudio extends StatelessWidget {
  const LolaControlAudio({
    super.key,
    required this.stream,
    required this.scale,
    required this.lola,
  });

  final Stream<LolaAudioState$>? stream;
  final double scale;
  final Lola$ lola;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snap) {
        final ui = snap.data;
        return switch (ui) {
          null => Container(),
          NonePath() => ui.actionDisabled(scale: scale),
          Playing() => ui.stop(
              scale: scale,
              action: () => lola.stopSpeech(),
            ),
          PlayingErr() => ui.replay(
              scale: scale,
              action: () => lola.playSpeech(),
            ),
          PlayingCompleted() => ui.replay(
              scale: scale,
              action: () => lola.playSpeech(),
            ),
          Stopped() => ui.play(
              scale,
              action: () => lola.playSpeech(),
            ),
          StoppedErr() => ui.play(
              scale,
              action: () => lola.playSpeech(),
            ),
        };
      },
    );
  }
}
