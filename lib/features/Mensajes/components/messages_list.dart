import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Mensajes/components/message_lola.dart';
import 'package:lola_ai_app/features/Mensajes/components/message_user.dart';
import 'package:lola_ai_app/features/Mensajes/mensajes_controller.dart';
import 'package:lola_ai_app/features/Mensajes/types.dart';

class MessagesList extends StatelessWidget {
  final List<SingleMessage> items;
  final double scale;

  final MessagesController controller;

  const MessagesList({
    super.key,
    required this.items,
    required this.scale,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      // prototypeItem: ListTile(
      //   title: Text(items.first),
      // ),
      itemBuilder: (_, index) {
        return items[index].from == "user"
            // TODO: refactor in order to remove index
            ? MessageUser(items: items, index: index, scale: scale)
            : MessageLola(
                controller: controller,
                items: items,
                // TODO: check audio path for lola before since it might not be a valid path anymore.
                audioPath: items[index].path,
                index: index,
                scale: scale);
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.scale,
    required this.audioPath,
    required this.controller,
  });

  final double scale;
  final String? audioPath;
  final MessagesController controller;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.play_arrow_rounded),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
          vertical: 10 * scale,
        ),
      ),
      onPressed: () async {
        if (audioPath != null) {
          controller.playSpeech(path: audioPath!);
        }
      },
      label: Text(
        'Reproducir',
        textScaler: TextScaler.linear(1.4 * scale),
      ),
    );
  }
}

class DisabledPlayButton extends StatelessWidget {
  const DisabledPlayButton({
    super.key,
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.play_arrow_rounded),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
          vertical: 10 * scale,
        ),
        backgroundColor: Colors.transparent,
        iconColor: Colors.grey[600],
      ),
      onPressed: null,
      label: Text(
        'Reproducir',
        style: TextStyle(color: Colors.grey[600]),
        textScaler: TextScaler.linear(1.4 * scale),
      ),
    );
  }
}
