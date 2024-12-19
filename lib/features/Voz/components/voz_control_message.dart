import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/lola_controller.dart';
import 'package:lola_ai_app/features/Voz/components/voz_action_buttons.dart';
import 'package:lola_ai_app/features/Voz/voz_controller.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:lola_ai_app/screens/voz/user_message/user_message_screen.dart';

class UserVozControlDisplayMessage extends StatelessWidget {
  const UserVozControlDisplayMessage({
    super.key,
    required this.vozController,
    required this.scale,
    required this.lolaController,
    required this.from,
    required this.debug,
  });

  final String from;
  final VozController vozController;
  final double scale;
  final LolaController lolaController;
  final bool debug;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vozController,
      builder: (_, __) {
        return switch (vozController.messageStatus) {
          VozMessageState.empty ||
          VozMessageState.editing =>
            VozOpenMessageDisabled(scale: scale),
          VozMessageState.edited ||
          VozMessageState.loaded =>
            VozOpenMessageAction(
              scale: scale,
              onPressed: () {
                unawaited(AppEvent.userMessageDisplayed
                    .track(params: {'from': from}));

                return showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (ctx) => UserMessageScreen(
                    lolaController: lolaController,
                    controller: vozController,
                    parentContext: context,
                    scale: scale,
                    debug: debug,
                  ),
                );
              },
            ),
        };
      },
    );
  }
}
