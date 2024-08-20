import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/core/components/action_btn.dart';
import 'package:lola_ai_app/screens/voz/lola_message/lola_message_screen.dart';

class LolaControlMessage extends StatelessWidget {
  const LolaControlMessage({
    super.key,
    required this.stream,
    required this.scale,
  });

  final Stream<LolaServiceState>? stream;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snap) {
        final service = snap.data;
        return switch (service) {
          null => Container(),
          IdleService(payload: String message) => ActionButton(
              icon: const Icon(Icons.expand_less),
              text: 'Ver Mensaje',
              scale: scale,
              onPressed: () => showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (ctx) => LolaMessageScreen(
                  text: message,
                  scale: scale,
                ),
              ),
            ),
          Loading() => ActionButton(
              icon: const Icon(Icons.expand_less),
              text: 'Ver Mensaje',
              scale: scale,
              color: Colors.grey,
            ),
          Data(payload: String message) => ActionButton(
              icon: const Icon(Icons.expand_less),
              text: 'Ver Mensaje',
              scale: scale,
              onPressed: () => showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (ctx) => LolaMessageScreen(
                  text: message,
                  scale: scale,
                ),
              ),
            ),
          Error(payload: String message) => ActionButton(
              icon: const Icon(Icons.expand_less),
              text: 'Ver Mensaje',
              scale: scale,
              onPressed: () => showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (ctx) => LolaMessageScreen(
                  text: message,
                  scale: scale,
                ),
              ),
            ),
        };
      },
    );
  }
}
