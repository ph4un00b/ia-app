import 'package:flutter/material.dart';
import 'package:lola_ai_app/screens/voz/lola_message/lola_message_screen.dart';
import 'package:lola_ai_app/features/Lola/lola.dart';
import 'package:lola_ai_app/features/core/components/action_btn.dart';

class LolaShowFullMessagePad extends StatelessWidget {
  const LolaShowFullMessagePad({
    super.key,
    required this.$lola,
    required this.scale,
    // required this.parentContext,
  });

  final Lola $lola;
  final double scale;
  // final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: $lola,
      builder: (context, child) {
        return Center(
          child: Column(
            children: [
              Expanded(
                child: ActionButton(
                  icon: const Icon(Icons.expand_more),
                  text: 'Ver Mensaje',
                  scale: scale,
                  handleAction: () => showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (ctx) => LolaMessageScreen(
                      message: $lola.output,
                      context: context,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
