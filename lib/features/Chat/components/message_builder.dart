import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
    required TextEditingController queryController,
    required Stream<LolaServiceState>? stream,
  })  : _scale = scale,
        _queryController = queryController,
        _stream = stream;

  final double _scale;
  final Stream<LolaServiceState>? _stream;
  final TextEditingController _queryController;

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
            IdleService(payload: final _) => defaultMessage([
                ChatMessage(
                  msgContent:
                      "Bienvenido/a. Puedes comenzar la conversación cuando lo desees, estoy aquí para ayudarte y responderé a todos tus mensajes.",
                  msgType: "sender",
                ),
                // ChatMessage(msgContent: "...", msgType: "receiver"),
              ]),
            // IdleService(payload: final _) => respuestaLola(messages),
            Loading(payload: final payload) => respuestaLoading([
                ChatMessage(msgContent: payload.userQuestion, msgType: "sender"),
                ChatMessage(msgContent: payload.reply, msgType: "receiver"),
              ]),
            Data(payload: final payload) => respuestaLola([
                ChatMessage(msgContent: payload.userQuestion, msgType: "sender"),
                ChatMessage(msgContent: payload.reply, msgType: "receiver"),
              ]),
            Error(payload: final message) => respuestaLola([
                ChatMessage(msgContent: message.userQuestion, msgType: "sender"),
                ChatMessage(msgContent: message.reply, msgType: "receiver"),
              ]),
          };
        });
  }

  ListView respuestaLola(
    List<ChatMessage> messages,
  ) {
    return ListView.builder(
        itemCount: messages.length,
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: LayoutBuilder(builder: (_, constrains) {
              var textStyle = TextStyle(
                color: messages[index].msgType == "receiver" ? Colors.white70 : Theme.of(context).colorScheme.primary,
                fontSize: 15 * _scale,
              );

              var boxDecoration = BoxDecoration(
                  color: (messages[index].msgType == "receiver"
                      ? Colors.grey.shade900.withAlpha(200)
                      : Theme.of(context).colorScheme.surfaceContainer),
                  borderRadius: BorderRadius.circular(16));

              return Row(children: [
                if (messages[index].msgType == "sender") const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: constrains.maxWidth),
                      child: DecoratedBox(
                        decoration: boxDecoration,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(messages[index].msgContent, style: textStyle),
                        ),
                      ),
                    ),
                    if (messages[index].msgType == "sender")
                      Row(
                        children: [
                          Row(
                            children: [
                              IconButton.outlined(
                                color: Theme.of(context).colorScheme.primary,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.transparent), // Border color
                                ),
                                isSelected: !true,
                                icon: const Icon(Icons.edit),
                                selectedIcon: const Icon(Icons.edit),
                                onPressed: () {
                                  _queryController.text = messages[index].msgContent;
                                },
                              ),
                              Text(
                                'Editar',
                                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12 * _scale),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
                if (messages[index].msgType != "sender") const Spacer()
              ]);
            })));
  }

  ListView respuestaLoading(
    List<ChatMessage> messages,
  ) {
    return ListView.builder(
        itemCount: messages.length,
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: LayoutBuilder(builder: (_, constrains) {
              var textStyle = TextStyle(
                color: messages[index].msgType == "receiver" ? Colors.white70 : Theme.of(context).colorScheme.primary,
                fontSize: 15 * _scale,
              );

              var boxDecoration = BoxDecoration(
                  color: (messages[index].msgType == "receiver"
                      ? Colors.grey.shade900.withAlpha(200)
                      : Theme.of(context).colorScheme.surfaceContainer),
                  borderRadius: BorderRadius.circular(16));

              return Row(children: [
                if (messages[index].msgType == "sender") const Spacer(),
                messages[index].msgType == "sender"
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: constrains.maxWidth),
                            child: DecoratedBox(
                                decoration: boxDecoration,
                                child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(messages[index].msgContent, style: textStyle))))
                      ])
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SpinKitThreeBounce(
                          color: Colors.white70,
                          size: 12 * _scale,
                        )),
                if (messages[index].msgType != "sender") const Spacer()
              ]);
            })));
  }

  ListView defaultMessage(List<ChatMessage> messages) {
    return ListView.builder(
        itemCount: messages.length,
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: LayoutBuilder(builder: (_, constrains) {
              var textStyle = TextStyle(
                color: messages[index].msgType == "receiver" ? Colors.white70 : Theme.of(context).colorScheme.primary,
                fontSize: 15 * _scale,
              );

              var boxDecoration = BoxDecoration(
                  color: (messages[index].msgType == "receiver"
                      ? Colors.grey.shade900.withAlpha(200)
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
                      child: Text(messages[index].msgContent, style: textStyle),
                    ),
                  ),
                ),
                if (messages[index].msgType != "sender") const Spacer()
              ]);
            })));
  }
}
