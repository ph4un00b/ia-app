import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/lola.dart';
import 'package:lola_ai_app/features/core/components/action_btn.dart';

class LolaToggleAudioPad extends StatelessWidget {
  const LolaToggleAudioPad({
    super.key,
    required this.$lola,
    required this.scale,
  });

  final Lola $lola;
  final double scale;
  final Icon icon = const Icon(Icons.play_circle_fill_sharp);

  void _toggleLolaAudio() {
    debugPrint('>> lola tapped: ${$lola.state.toString()}');
    if ($lola.state case LolaState.playingCompleted || LolaState.idle) {
      $lola.notifyPlaySpeech();
    } else if ($lola.state case LolaState.playing) {
      $lola.notifyStopSpeech();
    } else if ($lola.state case _) {
      debugPrint('noop');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: $lola,
      builder: (context, child) {
        return Center(
          child: Row(
            children: [
              // Expanded(
              // ClipOval(
              //   child: Material(
              //     child: InkWell(
              //       splashColor: Colors.purple.withAlpha(30),
              //       child: const SizedBox(
              //         width: 56,
              //         height: 56,
              //         child: Icon(
              //           Icons.mic,
              //           color: Colors.white60,
              //         ),
              //       ),
              //       onTap: () {},
              //     ),
              //   ),
              // ),
              // ),
              switch ($lola.state) {
                LolaState.idle => Expanded(
                    child: ActionButton(
                      icon: icon,
                      text: 'Repetir',
                      scale: scale,
                      color: Colors.lightGreen,
                      handleAction: _toggleLolaAudio,
                    ),
                  ),
                LolaState.playing => Expanded(
                    child: ActionButton(
                      icon: icon,
                      text: 'Parar',
                      scale: scale,
                      handleAction: _toggleLolaAudio,
                    ),
                  ),
                LolaState.playingError => Expanded(
                    child: ActionButton(
                      icon: icon,
                      text: 'Repetir',
                      scale: scale,
                      color: Colors.lightGreen,
                      handleAction: _toggleLolaAudio,
                    ),
                  ),
                LolaState.stopPlaying => Expanded(
                    child: ActionButton(
                      icon: icon,
                      text: 'Repetir',
                      scale: scale,
                      color: Colors.lightGreen,
                      handleAction: _toggleLolaAudio,
                    ),
                  ),
                LolaState.stopPlayingError => Expanded(
                    child: ActionButton(
                      icon: icon,
                      text: 'Repetir',
                      scale: scale,
                      color: Colors.lightGreen,
                      handleAction: _toggleLolaAudio,
                    ),
                  ),
                LolaState.playingCompleted => Expanded(
                    child: ActionButton(
                      icon: icon,
                      text: 'Repetir',
                      scale: scale,
                      color: Colors.lightGreen,
                      handleAction: _toggleLolaAudio,
                    ),
                  ),
              },
            ],
          ),
        );
      },
    );
  }
}
