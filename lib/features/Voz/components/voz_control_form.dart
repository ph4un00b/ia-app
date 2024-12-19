import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Voz/components/voz_action_buttons.dart';
import 'package:lola_ai_app/features/Voz/voz_controller.dart';
import 'package:lola_ai_app/features/core/types.dart';

class UserVozControlFormMessage extends StatelessWidget {
  const UserVozControlFormMessage({
    super.key,
    required this.vozController,
    required this.scale,
    required this.formKey,
    required this.setState,
  });

  final VozController vozController;
  final double scale;
  final GlobalKey<FormState> formKey;
  final void Function(void Function()) setState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vozController,
      builder: (_, __) {
        return switch (vozController.messageStatus) {
          VozMessageState.empty ||
          VozMessageState.edited ||
          VozMessageState.loaded =>
            VozEditAction(
              scale: scale,
              onPressed: () =>
                  setState(() => vozController.messageStatus = VozMessageState.editing),
            ),
          VozMessageState.editing => VozRequestAction(
              scale: scale,
              onPressed: () {
                unawaited(AppEvent.questionByTyping.track());
                setState(() {
                  vozController.messageStatus = VozMessageState.edited;
                });
                formKey.currentState?.save();
              },
            ),
        };
      },
    );
  }
}
