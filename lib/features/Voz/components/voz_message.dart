import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';

class VozMessage extends StatelessWidget {
  const VozMessage({
    super.key,
    required this.voz,
    required this.context,
  });

  final VozController voz;
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
              "Voz Message",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(voz.content()),
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
                  child: const Text('exit')),
            )
          ],
        ),
      ),
    );
  }
}
