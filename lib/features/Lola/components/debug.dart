import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/core/components/debug_widget.dart';

class DebugLolaReplyState extends StatelessWidget {
  const DebugLolaReplyState({
    super.key,
    required this.stream,
    required this.state,
  });

  final Stream<LolaReplyState$>? stream;
  final String state;

  @override
  Widget build(BuildContext context) {
    return DebugWidget(
      children: StreamBuilder(
        stream: stream,
        builder: (_, __) => Center(child: Text(state)),
      ),
    );
  }
}

class DebugLolaAudioState extends StatelessWidget {
  const DebugLolaAudioState({
    super.key,
    required this.stream,
    required this.state,
  });

  final Stream<LolaAudioState$>? stream;
  final String state;

  @override
  Widget build(BuildContext context) {
    return DebugWidget(
      children: StreamBuilder(
        stream: stream,
        builder: (_, __) => Center(child: Text(state)),
      ),
    );
  }
}

class DebugLolaState extends StatelessWidget {
  const DebugLolaState({
    super.key,
    required this.stream,
    required this.state,
  });

  final Stream<LolaState$>? stream;
  final String state;

  @override
  Widget build(BuildContext context) {
    return DebugWidget(
      children: StreamBuilder(
        stream: stream,
        builder: (_, __) => Center(child: Text(state)),
      ),
    );
  }
}
