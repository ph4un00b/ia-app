import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Mensajes/components/messages_list.dart';
import 'package:lola_ai_app/features/Mensajes/mensajes_controller.dart';
import 'package:lola_ai_app/features/Mensajes/types.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageLola extends StatelessWidget {
  final MessagesController controller;
  final String? audioPath;

  const MessageLola({
    super.key,
    required this.items,
    required this.index,
    required this.scale,
    required this.controller,
    required this.audioPath,
  });

  final int index;
  final List<SingleMessage> items;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            child: Text(
              timeago.format(items[index].createdAt, locale: "es"),
              textScaler: TextScaler.linear(1.2 * scale),
            ),
            onPressed: () {/* ... */},
          ),
          ListTile(
            // leading: const Icon(Icons.verified_user),
            // title: Text(items[index].title),
            subtitle: Text(
              items[index].content,
              textScaler: TextScaler.linear(1.6 * scale),
              maxLines: 4,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expanded(
              //   child: TextButton.icon(
              //     label: Text(
              //       'Reproducir',
              //       textScaler: TextScaler.linear(1.0 * scale),
              //     ),
              //     onPressed: () {
              //       if (audioPath != null) {
              //         controller.playSpeech(path: audioPath!);
              //       }
              //     },
              //     icon: const Icon(Icons.play_arrow_rounded),
              //   ),
              // ),
              Expanded(
                child: audioPath != null
                    ? PlayButton(
                        scale: scale,
                        audioPath: audioPath,
                        controller: controller,
                      )
                    : DisabledPlayButton(scale: scale),
              ),
              Expanded(
                child: TextButton(
                  child: Text(
                    'Ver',
                    textScaler: TextScaler.linear(1.4 * scale),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (ctx) {
                        final content = items[index].content;
                        final kontext = ctx;
                        return ReadableMessageScreen(
                          content: content,
                          kontext: kontext,
                          initialScale: scale,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
