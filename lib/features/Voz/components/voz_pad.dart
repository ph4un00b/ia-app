import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/Lola/lola_controller.dart';
import 'package:lola_ai_app/features/Voz/components/voz_message_pad.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';

class VozInputPad extends StatelessWidget {
  const VozInputPad({
    super.key,
    required this.vozController,
    required this.lolaController,
    required this.formKey,
    required this.scale,
    required this.debug,
  });

  final VozController vozController;
  final LolaController lolaController;
  final GlobalKey<FormState> formKey;
  final double scale;
  final bool debug;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vozController,
      builder: (_, __) {
        return Card.filled(
          shape: RoundedRectangleBorder(
            side: vozController.currentStatus == RecordState.recording
                ? const BorderSide(color: Colors.green, width: 2.0)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: InkWell(
            splashColor: Colors.purple.withAlpha(30),
            onTap: () => _handleTap(),
            child: VozMessagePad(
              formkey: formKey,
              state: vozController.messageStatus,
              controller: vozController,
              scale: scale,
              onMessageEdited: (value) async {
                if (value == null) return;

                vozController.updateContent(value);
                await lolaController.queryReply(
                    userQuestion: vozController.content(), debug: debug);
              },
            ),
          ),
        );
      },
    );
  }

  void _handleTap() async {
    if (vozController.currentStatus
        case RecordState.idle ||
            RecordState.recordingOk ||
            RecordState.stopRecording ||
            RecordState.stopRecordingError ||
            RecordState.playingError ||
            RecordState.playingCompleted) {
      await lolaController.stopAudio();
      await vozController.startRecording();
    } else if (vozController.currentStatus case RecordState.recording) {
      await vozController.stopRecording();
      await lolaController.queryReply(
          userQuestion: vozController.content(), debug: debug);
    } else if (vozController.currentStatus case _) {
      debugPrint('noop');
    }
  }
}
