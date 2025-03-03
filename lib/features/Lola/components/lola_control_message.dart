import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/core/components/action_btn.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:lola_ai_app/screens/voz/lola_message/lola_message_screen.dart';

class LolaControlMessage extends StatelessWidget {
  const LolaControlMessage({
    super.key,
    required this.stream,
    required this.scale,
    required this.from,
  });

  final String from;
  final Stream<LolaServiceState>? stream;
  final double scale;

  void _showMessage(BuildContext context, String message) {
    unawaited(AppEvent.lolaMessageDisplayed.track(params: {'from': from}));

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => LolaMessageScreen(
        text: message,
        scale: scale,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snap) {
        final service = snap.data;
        return switch (service) {
          null => Container(),
          IdleService(payload: final message) ||
          Data(payload: final message) ||
          Error(payload: final message) =>
            ActionButton(
              icon: const Icon(Icons.expand_less),
              text: 'Ver',
              scale: scale * 0.8,
              onPressed: () => _showMessage(context, message.reply),
            ),
          Loading() => ActionButton(
              icon: const Icon(Icons.expand_less),
              text: 'Ver',
              scale: scale * 0.8,
              color: Colors.grey,
            ),
        };
      },
    );
  }
}
