
import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/lola_stream.dart';
import 'package:lola_ai_app/features/Voz/components/voz_action_buttons.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';
import 'package:lola_ai_app/screens/voz/user_message/user_message_screen.dart';

class VozControlDisplayMessage extends StatelessWidget {
  const VozControlDisplayMessage({
    super.key,
    required this.user,
    required this.scale,
    required this.lola,
  });

  final Voz user;
  final double scale;
  final Lola$ lola;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: user,
      builder: (_, __) {
        return switch (user.messageState) {
          VozMessageState.empty => VozOpenMessageDisabled(
              scale: scale,
            ),
          VozMessageState.editing => VozOpenMessageDisabled(
              scale: scale,
            ),
          VozMessageState.edited => VozOpenMessageAction(
              scale: scale,
              onPressed: () => showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (ctx) => UserMessageScreen(
                  lolaController: lola,
                  controller: user,
                  parentContext: context,
                  scale: scale,
                ),
              ),
            ),
          VozMessageState.loaded => VozOpenMessageAction(
              scale: scale,
              onPressed: () => showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (ctx) => UserMessageScreen(
                  lolaController: lola,
                  controller: user,
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