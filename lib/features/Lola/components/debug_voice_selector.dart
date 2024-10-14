import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/lola_controller.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugLolaVoice extends StatefulWidget {
  const DebugLolaVoice({
    super.key,
    required this.lola,
  });

  final LolaController lola;

  @override
  State<DebugLolaVoice> createState() => _DebugLolaVoiceState();
}

class _DebugLolaVoiceState extends State<DebugLolaVoice> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: DebugVoiceSelector(
        $lolavoice: widget.lola.currentVoice,
        onSelected: (voz) async {
          if (voz != null) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString(
              'lola-voice',
              VoiceLola.values.firstWhere((v) => v.name == voz.name).name,
            );

            setState(() {
              widget.lola.currentVoice = voz;
            });
          }
        },
      ),
    );
  }
}

class DebugVoiceSelector extends StatelessWidget {
  const DebugVoiceSelector({
    super.key,
    required this.$lolavoice,
    required this.onSelected,
  });

  final VoiceLola $lolavoice;
  final Future<void> Function(VoiceLola? voz) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // const Expanded(
        //   child: Align(
        //     alignment: AlignmentDirectional(-1, 0),
        //     child: Padding(
        //       padding: EdgeInsetsDirectional.fromSTEB(24, 10, 0, 0),
        //       child: Text(
        //         'Voz de Lola',
        //         textScaler: TextScaler.linear(1.6),
        //         textAlign: TextAlign.start,
        //       ),
        //     ),
        //   ),
        // ),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 0, 0),
            child: DropdownMenu<VoiceLola>(
              initialSelection: $lolavoice,
              // controller: lolaController,
              // requestFocusOnTap is enabled/disabled by platforms when it is null.
              // On mobile platforms, this is false by default. Setting this to true will
              // trigger focus request on the text field and virtual keyboard will appear
              // afterward. On desktop platforms however, this defaults to true.
              requestFocusOnTap: true,
              label: const Text(
                'Voz de Lola',
                textScaler: TextScaler.linear(1.4),
                textAlign: TextAlign.start,
              ),
              onSelected: onSelected,
              dropdownMenuEntries: VoiceLola.values
                  .map<DropdownMenuEntry<VoiceLola>>((VoiceLola voz) {
                return DropdownMenuEntry<VoiceLola>(
                  value: voz,
                  label: voz.label,
                  enabled: true,
                  style: MenuItemButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 18.0)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
