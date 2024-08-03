import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadableMessageScreen extends StatefulWidget {
  const ReadableMessageScreen({
    super.key,
    required this.content,
    required this.kontext,
    required this.initialScale,
  });

  final String content;
  final BuildContext kontext;
  final double initialScale;

  @override
  State<ReadableMessageScreen> createState() => _ReadableMessageScreenState();
}

class _ReadableMessageScreenState extends State<ReadableMessageScreen> {
  double scale = 1.0;

  @override
  initState() {
    super.initState();
    _loadUserPrefereces();
  }

  Future<void> _loadUserPrefereces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      scale = prefs.getDouble('app-setting-full-message-text') ??
          widget.initialScale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (_, setState) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Slider(
                value: scale,
                min: 0.5,
                max: 3.0,
                // divisions: 5,
                label: scale.toString(),
                // onChanged: null,
                onChanged: (double value) async {
                  setState(() => scale = value);
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setDouble(
                    'app-setting-full-message-text',
                    value,
                  );
                },
              ),
              Text(
                "Message",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0 * scale,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.content,
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
                  ),
                  onPressed: () {
                    Navigator.pop(widget.kontext);
                  },
                  child: Text(
                    'Cerrar',
                    textScaler: TextScaler.linear(1.4 * scale),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
