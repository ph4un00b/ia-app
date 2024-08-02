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
        debugPrint('>> voz-message-pad: ${controller.state}, ${controller.aiState}');
        return switch (controller.aiState) {
          VozAI.transcribingOk => MessageWidget(
              formkey: formkey,
              state: state,
              controller: controller,
              scale: scale,
              onMessageEdited: onMessageEdited,
            ),
          VozAI.transcribing => MessageWidget(
              formkey: formkey,
              state: state,
              controller: controller,
              scale: scale,
              onMessageEdited: onMessageEdited,
            ),
          VozAI.idle => MessageWidget(
              formkey: formkey,
              state: state,
              controller: controller,
              scale: scale,
              onMessageEdited: onMessageEdited,
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

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.formkey,
    required this.state,
    required this.controller,
    required this.scale,
    required this.onMessageEdited,
  });

  final GlobalKey<FormState> formkey;
  final VozMessageState state;
  final Voz controller;
  final double scale;
  final Function(String? p1) onMessageEdited;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: formkey,
              child: TextFormField(
                expands: true,
                enabled: state == VozMessageState.editing,
                // minLines: 4,
                minLines: null,
                // maxLines: 10,
                maxLines: null,
                controller: TextEditingController(text: controller.content()),
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  // filled: !true,
                  // isDense: !true,
                  border: state == VozMessageState.editing
                      ? const OutlineInputBorder()
                      : InputBorder.none,
                  labelText: 'Presiona para grabar mensaje',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.normal,
                    fontSize: 36 * scale,
                  ),
                  // floatingLabelAlignment: FloatingLabelAlignment.start,
                  // floatingLabelStyle: TextStyle(
                  //   color: Colors.green,
                  //   fontSize: 26,
                  // ),
                ),
                style: TextStyle(
                    fontSize: 36.0 * scale,
                    color: state == VozMessageState.editing
                        ? null
                        : Colors.white70),
                onSaved: (value) {
                  debugPrint('>> on-saved-value: $value');
                  onMessageEdited(value);
                  // voz.input = value ?? '';
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
