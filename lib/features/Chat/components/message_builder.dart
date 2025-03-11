import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/types.dart';

final class ChatMessage {
  String msgContent;
  String msgType;
  ChatMessage({required this.msgContent, required this.msgType});
}

class MessagesBuilder extends StatelessWidget {
  const MessagesBuilder({
    super.key,
    required double scale,
    required Stream<LolaServiceState>? stream,
  })  : _scale = scale,
        _stream = stream;

  final double _scale;
  final Stream<LolaServiceState>? _stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          final service = snapshot.data;
          return switch (service) {
            null => respuestaLola([
                ChatMessage(msgContent: "null", msgType: "sender"),
                ChatMessage(msgContent: "null", msgType: "receiver"),
              ]),
            IdleService(payload: final _) => respuestaLola([
                ChatMessage(
                    msgContent:
                        "Bienvenido/a. Puedes comenzar la conversación cuando lo desees, estoy aquí para ayudarte y responderé a todos tus mensajes.",
                    msgType: "sender"),
                // ChatMessage(msgContent: message.reply, msgType: "receiver"),
              ]),
            Loading(payload: final payload) => respuestaLola([
                ChatMessage(
                    msgContent: payload.userQuestion, msgType: "sender"),
                ChatMessage(msgContent: payload.reply, msgType: "receiver"),
              ]),
            Data(payload: final payload) => respuestaLola([
                ChatMessage(
                    msgContent: payload.userQuestion, msgType: "sender"),
                ChatMessage(msgContent: payload.reply, msgType: "receiver"),
              ]),
            Error(payload: final message) => respuestaLola([
                ChatMessage(
                    msgContent: message.userQuestion, msgType: "sender"),
                ChatMessage(msgContent: message.reply, msgType: "receiver"),
              ]),
          };
        });
  }

  ListView respuestaLola(List<ChatMessage> messages) {
    return ListView.builder(
        itemCount: messages.length,
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: LayoutBuilder(builder: (_, constrains) {
              var textStyle = TextStyle(
                  color: messages[index].msgType == "receiver"
                      ? Colors.white70
                      : Theme.of(context).colorScheme.primary,
                  fontSize: 15 * _scale);

              var boxDecoration = BoxDecoration(
                  color: (messages[index].msgType == "receiver"
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.surfaceContainer),
                  borderRadius: BorderRadius.circular(16));

              return Row(children: [
                if (messages[index].msgType == "sender") const Spacer(),
                ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constrains.maxWidth),
                    child: DecoratedBox(
                      decoration: boxDecoration,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child:
                            Text(messages[index].msgContent, style: textStyle),
                      ),
                    )),
                if (messages[index].msgType != "sender") const Spacer()
              ]);
            })));
  }
}
