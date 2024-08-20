import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/types.dart';

class LolaServerMessagePad extends StatelessWidget {
  const LolaServerMessagePad({
    super.key,
    required this.stream,
    required this.scale,
  });

  final Stream<LolaServiceState>? stream;
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
            final service = snap.data;
            return switch (service) {
              null => Container(),
              IdleService(payload: String message) => Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          textScaler: TextScaler.linear(2.6 * scale),
                          maxLines: 4,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Loading() => Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: Text(
                          'Lola está escribiendo un mensaje...',
                          textScaler: TextScaler.linear(2.6 * scale),
                          maxLines: 4,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Data(payload: String message) => Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          textScaler: TextScaler.linear(2.6 * scale),
                          maxLines: 4,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Error() => Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: Text(
                          '',
                          textScaler: TextScaler.linear(2.6 * scale),
                          maxLines: 4,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
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
