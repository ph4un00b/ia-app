import 'package:flutter/material.dart';

class LolaMessageScreen extends StatelessWidget {
  const LolaMessageScreen({
    super.key,
    required this.scale,
    required this.message,
    required this.context,
  });

  final double scale;
  final String message;
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
            Text(
              "Lola Message",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0 * scale,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  message,
                  textScaler: TextScaler.linear(2.6 * scale),
                ),
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
                child: const Text('exit'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
