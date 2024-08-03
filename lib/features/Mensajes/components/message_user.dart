import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Mensajes/components/messages_list.dart';
import 'package:lola_ai_app/features/Mensajes/types.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageUser extends StatelessWidget {
  const MessageUser({
    super.key,
    required this.items,
    required this.index,
    required this.scale,
  });

  final int index;
  final List<SingleMessage> items;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
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
              Expanded(child: DisabledPlayButton(scale: scale)),
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
