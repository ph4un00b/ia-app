import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/lola.dart';

class DebugLolaState extends StatelessWidget {
  const DebugLolaState({
    super.key,
    required this.$lola,
  });

  final Lola $lola;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(child: Text($lola.state.toString())),
          Expanded(child: Text("fetching-count: ${$lola.fetchingCounter}")),
        ],
      ),
    );
  }
}