import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/lola_stream.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/screens/voz/lola_message/lola_message_screen.dart';

class LolaControlMessage extends StatelessWidget {
  const LolaControlMessage({
    super.key,
    required this.stream,
    required this.scale,
    required this.lola,
  });

  final Stream<LolaReplyState$>? stream;
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
          LolaEmpty() => ui.actionDisabled(scale: scale),
          LolaMessage() => ui.actionEnabled(
              scale: scale,
              action: () => showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (ctx) => LolaMessageScreen(
                  controller: lola,
                  parentContext: context,
                  scale: scale,
                ),
              ),
            ),
        };
      },
    );
  }
}
