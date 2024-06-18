import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/lola.dart';

class LolaToggleAudioPad extends StatelessWidget {
  const LolaToggleAudioPad({
    super.key,
    required this.$lola,
    required this.scale,
  });

  final Lola $lola;
  final double scale;

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
                      text: 'Repetir',
                      scale: scale,
                      color: Colors.lightGreen,
                      handleAction: _toggleLolaAudio,
                    ),
                  ),
                LolaState.playing => Expanded(
                    child: ActionButton(
                      text: 'Parar',
                      scale: scale,
                      handleAction: _toggleLolaAudio,
                    ),
                  ),
                LolaState.playingError => Expanded(
                    child: ActionButton(
                      text: 'Repetir',
                      scale: scale,
                      color: Colors.lightGreen,
                      handleAction: _toggleLolaAudio,
                    ),
                  ),
                LolaState.stopPlaying => Expanded(
                    child: ActionButton(
                      text: 'Repetir',
                      scale: scale,
                      color: Colors.lightGreen,
                      handleAction: _toggleLolaAudio,
                    ),
                  ),
                LolaState.stopPlayingError => Expanded(
                    child: ActionButton(
                      text: 'Repetir',
                      scale: scale,
                      color: Colors.lightGreen,
                      handleAction: _toggleLolaAudio,
                    ),
                  ),
                LolaState.playingCompleted => Expanded(
                    child: ActionButton(
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

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.text,
    required this.scale,
    required this.handleAction,
    this.color,
  });

  final String text;
  final double scale;
  final Color? color;
  final void Function() handleAction;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.play_circle_fill_sharp),
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: 10 * scale,
            vertical: 10 * scale,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          iconColor: color == null ? null : Colors.lightGreen),
      onPressed: () {
        handleAction();
      },
      label: Text(
        text,
        style: TextStyle(color: color == null ? null : Colors.lightGreen),
        textScaler: TextScaler.linear(1.4 * scale),
      ),
    );
  }
}
