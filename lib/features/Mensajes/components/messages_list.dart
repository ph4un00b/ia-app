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
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(10),
        // ),
        // iconColor: Colors.grey[700],
      ),
      onPressed: () async {
        if (audioPath != null) {
          controller.playSpeech(path: audioPath!);
        }
      },
      label: Text(
        'Reproducir',
        // style: TextStyle(color: Colors.grey[700]),
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
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(10),
        // ),
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

class Readable extends StatelessWidget {
  const Readable({
    super.key,
    required this.content,
    required this.kontext,
  });

  final String content;
  final BuildContext kontext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Slider(
            value: 1.0,
            // value: 1.0,
            min: 0.5,
            max: 3.0,
            // divisions: 5,
            label: '1.0',
            onChanged: null,
            // onChanged: (double value) async {
            //   setState(() => screenScale = value);
            //   final prefs = await SharedPreferences.getInstance();
            //   prefs.setDouble(
            //     'app-setting-full-message-text',
            //     value,
            //   );
            // },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Text(content),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.pop(kontext);
              },
              child: const Text(
                'Cerrar',
                textScaler: TextScaler.linear(1.4),
              ),
            ),
          )
        ],
      ),
    );
  }
}
