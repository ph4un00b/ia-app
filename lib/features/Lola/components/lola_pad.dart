
import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/types.dart';

class LolaPad extends StatelessWidget {
  const LolaPad({
    super.key,
    required this.stream,
    required this.scale,
  });

  final Stream<LolaState$>? stream;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.purple.withAlpha(30),
        onTap: () => {},
        child: StreamBuilder(
          stream: stream,
          builder: (context, snap) {
            final ui = snap.data;
            return switch (ui) {
              null => Container(),
              Idle() => ui.empty(),
              FetchingCompletion() => ui.empty(),
              CompletionOK() => ui.withMessage(scale: scale),
              CompletionErr() => ui.empty(),
              FetchingSpeech() => ui.withMessage(scale: scale),
              SpeechOk() => ui.withMessage(scale: scale),
              SpeechErr() => ui.withMessage(scale: scale),
              SpeakingIdle() => ui.withMessage(scale: scale),
              SpeakingOK() => ui.withMessage(scale: scale),
              SpeakingErr() => ui.withMessage(scale: scale),
            };
          },
        ),
      ),
    );
  }
}
