import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/types.dart';

extension MessageText on Widget {
  Widget messageText(String message, double scale, int maxLines,
      {TextOverflow? overflow}) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Text(
              message,
              textScaler: TextScaler.linear(2.6 * scale),
              maxLines: maxLines,
              softWrap: true,
              overflow: overflow ?? TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class LolaServerMessagePad extends StatelessWidget {
  const LolaServerMessagePad({
    super.key,
    required this.stream,
    required this.scale,
    this.maxLines = 4,
  });

  final Stream<LolaServiceState>? stream;
  final double scale;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.purple.withAlpha(30),
        onTap: () => {},
        child: StreamBuilder(
          stream: stream,
          builder: (context, snap) {
            final service = snap.data;
            return switch (service) {
              null => const SizedBox.shrink(),
              IdleService(payload: final message) =>
                Container().messageText(message, scale, maxLines),
              Loading() => Container().messageText(
                  'Lola está escribiendo un mensaje...', scale, maxLines),
              Data(payload: final message) =>
                Container().messageText(message, scale, maxLines),
              Error() => Container().messageText('', scale, maxLines),
            };
          },
        ),
      ),
    );
  }
}

class LolaLocalMessagePad extends StatelessWidget {
  const LolaLocalMessagePad({
    super.key,
    required this.stream,
    required this.scale,
  });

  final Stream<LolaState$>? stream;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.purple.withAlpha(30),
        onTap: () => {},
        child: StreamBuilder(
          stream: stream,
          builder: (context, snap) {
            final ui = snap.data;
            return switch (ui) {
              null => Container(),
              Idle() => ui.withMessage(scale: scale),
              FetchingResponse() => ui.empty(),
              ResponseOk() => ui.withMessage(scale: scale),
              ResponseErr() => ui.empty(),
              FetchingAudio() => ui.withMessage(scale: scale),
              AudioOk() => ui.withMessage(scale: scale),
              AudioErr() => ui.withMessage(scale: scale),
              LolaSilent() => ui.withMessage(scale: scale),
              LolaSpoken() => ui.withMessage(scale: scale),
              LolaSpeechErr() => ui.withMessage(scale: scale),
            };
          },
        ),
      ),
    );
  }
}
