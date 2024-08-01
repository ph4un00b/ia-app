import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/lola.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';

class LolaMessagePad extends StatelessWidget {
  const LolaMessagePad({
    super.key,
    required this.$lola,
    required this.$lolavoice,
    required this.voz,
    required this.context,
  });

  final Lola $lola;
  final VoiceLola $lolavoice;
  final Voz voz;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: $lola,
      builder: (context, child) {
        debugPrint('>> lola listener: ${$lola.state}, ${$lola.aiState}');
        switch ($lola.aiState) {
          case (LolaAI.thinkingStarted):
            return Center(
              child: Column(
                children: [
                  Text(
                    $lola.aiState.toString(),
                    textScaler: const TextScaler.linear(1.6),
                  ),
                  Text(
                    $lola.state.toString(),
                    textScaler: const TextScaler.linear(1.6),
                  ),
                  Text(
                    'fetching-count: ${$lola.fetchingCounter.toString()}',
                    textScaler: const TextScaler.linear(1.6),
                  ),
                  FutureBuilder(
                    //! cualquier setState || notifyListeners truena
                    future: $lola.reply(input: voz.content(), voice: $lolavoice),
                    builder: (context, snapshot) {
                      debugPrint(
                          '>> lola reply:done:future: ${snapshot.hasData}'); //

                      String lolaOutput;
                      lolaOutput = switch (snapshot.hasData) {
                        true => snapshot.data!,
                        false => $lola.output
                      };

                      if (snapshot.hasError) {
                        debugPrint('>> err: ${snapshot.error}');
                        $lola.error();
                      }

                      return Expanded(
                        child: Text(
                          lolaOutput,
                          textScaler: const TextScaler.linear(2.6),
                          maxLines: 4,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          default:
            return Center(
              child: Column(
                children: [
                  Text(
                    $lola.aiState.toString(),
                    textScaler: const TextScaler.linear(1.6),
                  ),
                  Text(
                    $lola.state.toString(),
                    textScaler: const TextScaler.linear(1.6),
                  ),
                  Text(
                    'fetching-count: ${$lola.fetchingCounter.toString()}',
                    textScaler: const TextScaler.linear(1.6),
                  ),
                  Expanded(
                    child: Text(
                      $lola.output,
                      textScaler: const TextScaler.linear(2.6),
                      maxLines: 4,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}
