import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Mensajes/components/message_lola.dart';
import 'package:lola_ai_app/features/Mensajes/components/message_user.dart';
import 'package:lola_ai_app/features/Mensajes/mensajes_controller.dart';
import 'package:lola_ai_app/features/Mensajes/types.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class ReadableMessageScreen extends StatefulWidget {
  const ReadableMessageScreen({
    super.key,
    required this.content,
    required this.kontext,
    required this.initialScale,
  });

  final String content;
  final BuildContext kontext;
  final double initialScale;

  @override
  State<ReadableMessageScreen> createState() => _ReadableMessageScreenState();
}

class _ReadableMessageScreenState extends State<ReadableMessageScreen> {
  double scale = 1.0;

  @override
  initState() {
    super.initState();
    _loadUserPrefereces();
  }

  Future<void> _loadUserPrefereces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      scale = prefs.getDouble('app-setting-full-message-text') ??
          widget.initialScale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (_, setState) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Slider(
                value: scale,
                min: 0.5,
                max: 3.0,
                // divisions: 5,
                label: scale.toString(),
                // onChanged: null,
                onChanged: (double value) async {
                  setState(() => scale = value);
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setDouble(
                    'app-setting-full-message-text',
                    value,
                  );
                },
              ),
              Text(
                "Message",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0 * scale,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.content,
                    textScaler: TextScaler.linear(2.6 * scale),
                  ),
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
                    Navigator.pop(widget.kontext);
                  },
                  child: Text(
                    'Cerrar',
                     textScaler: TextScaler.linear(1.4 * scale),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
