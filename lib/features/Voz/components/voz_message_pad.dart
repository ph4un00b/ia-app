import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';

enum VozMessageState {
  printine,
  editing,
  edited,
}

class VozMessagePad extends StatelessWidget {
  const VozMessagePad({
    super.key,
    required this.voz,
    required this.context,
    required this.scale,
    required this.formkey,
    required this.onSaved,
    required this.state,
  });

  final double scale;
  final Voz voz;
  final BuildContext context;
  final GlobalKey<FormState> formkey;
  final Function(String?) onSaved;
  final VozMessageState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: voz,
      builder: (context, child) {
        debugPrint('>> ${voz.state}, ${voz.aiState}');
        switch (voz.aiState) {
          case VozAI.transcribingOk:
            return Center(
              child: Column(
                children: [
                  Text(
                    voz.aiState.toString(),
                    textScaler: TextScaler.linear(1.6 * scale),
                  ),
                  Expanded(
                    child: Form(
                      key: formkey,
                      child: TextFormField(
                        enabled: state == VozMessageState.editing,
                        minLines: 4,
                        maxLines: 10,
                        controller: TextEditingController(text: voz.input),
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
            return Center(
              child: Column(
                children: [
                  Text(
                    voz.aiState.toString(),
                    textScaler: TextScaler.linear(1.6 * scale),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}
