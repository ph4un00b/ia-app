import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/components/lola_message.dart';
import 'package:lola_ai_app/features/Lola/lola.dart';
import 'package:lola_ai_app/features/core/components/action_btn.dart';

class LolaShowFullMessagePad extends StatelessWidget {
  const LolaShowFullMessagePad({
    super.key,
    required this.$lola,
    // required this.parentContext,
  });

  final Lola $lola;
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
                  scale: 1.0,
                  handleAction: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (ctx) {
                        return LolaMessage($lola: $lola, context: context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
