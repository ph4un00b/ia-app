import 'package:flutter/material.dart';

class TestErrorLogger extends StatelessWidget {
  const TestErrorLogger({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ElevatedButton(
        onPressed: () {
          throw Exception('This is your error 💅');
        },
        child: const Text('Verify Sentry Setup'),
      ),
    );
  }
}
