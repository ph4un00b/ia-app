import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/Lola/types.dart';

class LolaLoading extends StatelessWidget {
  const LolaLoading({
    super.key,
    required Stream<LolaServiceState>? lolaStream,
  }) : _lolaStream = lolaStream;

  final Stream<LolaServiceState>? _lolaStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _lolaStream,
        builder: (context, snapshot) {
          final service = snapshot.data;
          return switch (service) {
            null => const SizedBox.shrink(),
            IdleService() => const SizedBox.shrink(),
            Loading(intent: final userIntent) => switch (userIntent) {
                IntentKind.text => const LinearProgressIndicator(),
                IntentKind.greeting =>
                  const LinearProgressIndicator(color: Colors.yellow),
                IntentKind.reminder =>
                  const LinearProgressIndicator(color: Colors.blue),
                IntentKind.createReminder =>
                  const LinearProgressIndicator(color: Colors.green),
                IntentKind.none =>
                  const LinearProgressIndicator(color: Colors.white70),
              },
            Data() => const SizedBox.shrink(),
            Error() => const LinearProgressIndicator(color: Colors.deepOrange),
          };
        });
  }
}
