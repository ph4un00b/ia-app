import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';

class VozMessagePad extends StatelessWidget {
  const VozMessagePad({
    super.key,
    required this.voz,
    required this.context,
  });

  final Voz voz;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: voz,
      builder: (context, child) {
        debugPrint('>> ${voz.state}, ${voz.aiState}');
        switch (voz.aiState) {
          case VozAI.transcribingOk:
            // $userTalks.to($lolaTalks);
            return Center(
              child: Column(
                children: [
                  Text(
                    voz.aiState.toString(),
                    textScaler: const TextScaler.linear(1.6),
                  ),
                  Expanded(
                    child: Text(
                      voz.input,
                      textScaler: const TextScaler.linear(2.6),
                      maxLines: 4,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          default:
            return Center(
              child: Column(
                children: [
                  Text(
                    voz.aiState.toString(),
                    textScaler: const TextScaler.linear(1.6),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}
