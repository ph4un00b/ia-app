import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LolaMessageScreen extends StatefulWidget {
  const LolaMessageScreen({
    super.key,
    required this.scale,
    required this.controller,
    required this.parentContext,
  });

  final double scale;
  final BuildContext parentContext;
  final QueryContent controller;

  @override
  State<LolaMessageScreen> createState() => _LolaMessageScreenState();
}

class _LolaMessageScreenState extends State<LolaMessageScreen> {
  bool debug = !true;
  double screenScale = 1.0;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  VozMessageState state = VozMessageState.loaded;
  final messageController = TextEditingController(text: '');

  @override
  initState() {
    super.initState();
    _loadUserPrefereces();
    messageController.text = widget.controller.content();
  }

  Future<void> _loadUserPrefereces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      screenScale =
          prefs.getDouble('app-setting-full-message-text') ?? widget.scale;
    });
  }

  @override
  Widget build(BuildContext _) {
    return StatefulBuilder(builder: (_, setState) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Slider(
                value: screenScale,
                // value: 1.0,
                min: 0.5,
                max: 3.0,
                // divisions: 5,
                label: screenScale.toString(),
                onChanged: (double value) async {
                  setState(() => screenScale = value);
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setDouble(
                    'app-setting-full-message-text',
                    value,
                  );
                },
              ),
              Text(
                "Lola Message",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0 * screenScale,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.controller.content(),
                    textScaler: TextScaler.linear(2.6 * screenScale),
                  ),
                ),
              ),
              if (debug) const SizedBox(height: 40),
              if (debug) _debugMessageState(),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    // foregroundColor: Color.
                  ),
                  onPressed: () {
                    Navigator.pop(widget.parentContext);
                  },
                  child: Text(
                    'Cerrar',
                    textScaler: TextScaler.linear(1.4 * screenScale),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _debugMessageState() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          // foregroundColor: Color.
        ),
        onPressed: () {
          Navigator.pop(widget.parentContext);
        },
        child: Text(
          state.toString(),
          textScaler: TextScaler.linear(1 * screenScale),
        ),
      ),
    );
  }
}
