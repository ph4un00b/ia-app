import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';

class VozMessagePad extends StatelessWidget {
  const VozMessagePad({
    super.key,
    required this.controller,
    required this.scale,
    required this.formkey,
    required this.onSaved,
    required this.state,
  });

  final double scale;
  final Voz controller;
  final GlobalKey<FormState> formkey;
  final Function(String?) onSaved;
  final VozMessageState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        debugPrint('>> ${controller.state}, ${controller.aiState}');
        switch (controller.aiState) {
          case VozAI.transcribingOk:
            return Center(
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
                          // labelText: '',
                          // hintText: '',
                        ),
                        style: TextStyle(
                            fontSize: 36.0 * scale,
                            color: state == VozMessageState.editing
                                ? null
                                : Colors.white70),
                        onSaved: (value) {
                          debugPrint('>> value: $value');
                          onSaved(value);
                          // voz.input = value ?? '';
                        },
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: Text(
                  //     voz.input,
                  //     textScaler: TextScaler.linear(2.6 * scale),
                  //     maxLines: 4,
                  //     softWrap: true,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
                ],
              ),
            );
          default:
            return Container();
        }
      },
    );
  }
}
