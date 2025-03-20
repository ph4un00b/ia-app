import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/App/status.dart';
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
                IntentKind.text => AppStatus.isActive()
                    ? const LinearProgressIndicator()
                    : const LinearProgressIndicator(color: Colors.white70),
                IntentKind.greeting => AppStatus.isActive()
                    ? const LinearProgressIndicator(color: Colors.yellow)
                    : LinearProgressIndicator(color: Colors.yellow[100]),
                IntentKind.reminder => AppStatus.isActive()
                    ? const LinearProgressIndicator(color: Colors.indigoAccent)
                    : LinearProgressIndicator(color: Colors.indigoAccent[100]),
                IntentKind.createReminder => AppStatus.isActive()
                    ? const LinearProgressIndicator(color: Colors.lightGreenAccent)
                    : LinearProgressIndicator(color: Colors.lightGreenAccent[100]),
                IntentKind.none => const LinearProgressIndicator(color: Colors.white70),
              },
            Data() => const SizedBox.shrink(),
            Error() => AppStatus.isActive()
                ? const LinearProgressIndicator(color: Colors.deepOrange)
                : LinearProgressIndicator(color: Colors.deepOrange[100]),
          };
        });
  }
}
