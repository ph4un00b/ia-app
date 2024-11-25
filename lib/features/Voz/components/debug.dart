import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';
import 'package:lola_ai_app/features/core/components/debug_alt_widget.dart';

class DebugVozMessageState extends StatelessWidget {
  const DebugVozMessageState({
    super.key,
    required this.vozController,
  });

  final VozController vozController;

  @override
  Widget build(BuildContext context) {
    return DebugAltWidget(
      children: ListenableBuilder(
        listenable: vozController,
        builder: (_, __) {
          return Center(child: Text(vozController.messageStatus.toString()));
        },
      ),
    );
  }
}

class DebugVozAiState extends StatelessWidget {
  const DebugVozAiState({
    super.key,
    required this.vozController,
  });

  final VozController vozController;

  @override
  Widget build(BuildContext context) {
    return DebugAltWidget(
      children: ListenableBuilder(
        listenable: vozController,
        builder: (_, __) {
          return Center(child: Text(vozController.transcriptionStatus.toString()));
        },
      ),
    );
  }
}

class DebugVozState extends StatelessWidget {
  const DebugVozState({
    super.key,
    required this.vozController,
  });

  final VozController vozController;

  @override
  Widget build(BuildContext context) {
    return DebugAltWidget(
      children: ListenableBuilder(
        listenable: vozController,
        builder: (_, __) {
          return Center(child: Text(vozController.currentStatus.toString()));
        },
      ),
    );
  }
}
