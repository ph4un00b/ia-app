import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/lola.dart';

class LolaMessage extends StatelessWidget {
  const LolaMessage({
    super.key,
    required this.$lola,
    required this.context,
  });

  final Lola $lola;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lola Message",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text($lola.output),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    // foregroundColor: Color.
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('exit')),
            )
          ],
        ),
      ),
    );
  }
}
