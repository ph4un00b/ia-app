import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/lola_controller.dart';
import 'package:lola_ai_app/features/Voz/components/voz_message_pad.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';

class VozPad extends StatelessWidget {
  const VozPad({
    super.key,
    required this.user,
    required this.lola$,
    required this.formKey,
    required this.scale,
  });

  final Voz user;
  final LolaController lola$;
  final GlobalKey<FormState> formKey;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: user,
      builder: (_, __) {
        return Card.filled(
          shape: RoundedRectangleBorder(
            side: user.state == VozState.recording
                ? const BorderSide(color: Colors.green, width: 2.0)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: InkWell(
            splashColor: Colors.purple.withAlpha(30),
            onTap: () async {
              debugPrint('Card tapped from: ${user.state}');
              if (user.state
                  case VozState.idle ||
                      VozState.recordingOk ||
                      VozState.stopRecording ||
                      VozState.stopRecordingError ||
                      VozState.playingError ||
                      VozState.playingCompleted) {
                await lola$.stopAudio();
                await user.notifyStartRecording();
              } else if (user.state case VozState.recording) {
                await user.notifyStopRecording();
                // TODO: handle debug
                await lola$.loadReply(userQuestion: user.content(), debug: false);
              } else if (user.state case _) {
                debugPrint('noop');
              }
            },
            child: VozMessagePad(
              formkey: formKey,
              state: user.messageState,
              controller: user,
              scale: scale,
              onMessageEdited: (value) async {
                debugPrint('>> on-message-edited: $value');
                if (value != null) {
                  user.updateContent(value);
                  // TODO: handle debug
                  await lola$.loadReply(userQuestion: user.content(), debug: false);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
