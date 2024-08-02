import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Voz/components/voz_action_buttons.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';

class VozControlFormMessage extends StatelessWidget {

  const VozControlFormMessage({
    super.key,
    required this.user,
    required this.scale,
    required this.formKey,
    required this.setState,
  });

  final Voz user;
  final double scale;
  final GlobalKey<FormState> formKey;
  final void Function(void Function()) setState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: user,
      builder: (_, __) {
        return switch (user.messageState) {
          VozMessageState.empty => VozEditAction(
              scale: scale,
              onPressed: () {
                setState(() {
                  user.messageState = VozMessageState.editing;
                });
              },
            ),
          VozMessageState.editing => VozRequestAction(
              scale: scale,
              onPressed: () {
                setState(() {
                  user.messageState = VozMessageState.edited;
                });

                formKey.currentState?.save();
              },
            ),
          VozMessageState.edited => VozEditAction(
              scale: scale,
              onPressed: () {
                setState(() {
                  user.messageState = VozMessageState.editing;
                });
              },
            ),
          VozMessageState.loaded => VozEditAction(
              scale: scale,
              onPressed: () {
                setState(() {
                  user.messageState = VozMessageState.editing;
                });
              },
            ),
        };
      },
    );
  }
}