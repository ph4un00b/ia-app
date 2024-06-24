import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';

class VozMessagePad extends StatelessWidget {
  const VozMessagePad({
    super.key,
    required this.controller,
    required this.scale,
    required this.formkey,
    required this.onMessageEdited,
    required this.state,
  });

  final double scale;
  final Voz controller;
  final GlobalKey<FormState> formkey;
  final Function(String?) onMessageEdited;
  final VozMessageState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (_, __) {
        debugPrint('>> ${controller.state}, ${controller.aiState}');
        return switch (controller.aiState) {
          VozAI.transcribingOk => Center(
              child: Column(
                children: [
                  Expanded(
                    child: Form(
                      key: formkey,
                      child: TextFormField(
                        enabled: state == VozMessageState.editing,
                        minLines: 4,
                        maxLines: 10,
                        controller:
                            TextEditingController(text: controller.input),
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          border: state == VozMessageState.editing
                              ? const OutlineInputBorder()
                              : InputBorder.none,
                          labelText: 'Presiona para grabar mensaje',
                          // hintText: 'jamon',
                        ),
                        style: TextStyle(
                            fontSize: 36.0 * scale,
                            color: state == VozMessageState.editing
                                ? null
                                : Colors.white70),
                        onSaved: (value) {
                          debugPrint('>> value: $value');
                          onMessageEdited(value);
                          // voz.input = value ?? '';
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          VozAI.idle => Center(
              child: Text(
                'Presiona para grabar mensaje.',
                style: TextStyle(fontSize: 36.0 * scale),
              ),
            ),
          VozAI.transcribing => Center(
              child: Text(
                'Presiona para grabar mensaje.',
                style: TextStyle(fontSize: 36.0 * scale),
              ),
            ),
          VozAI.transcribingError => Center(
              child: Text(
                'Presiona para grabar mensaje.',
                style: TextStyle(fontSize: 36.0 * scale),
              ),
            ),
        };
      },
    );
  }
}
