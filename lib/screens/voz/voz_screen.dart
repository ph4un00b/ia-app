import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/App/components/setting_text.dart';
import 'package:lola_ai_app/features/Lola/components/debug_voice_selector.dart';
import 'package:lola_ai_app/features/Lola/components/lola_control_audio.dart';
import 'package:lola_ai_app/features/Lola/components/lola_control_message.dart';
import 'package:lola_ai_app/features/Lola/components/lola_pad.dart';
import 'package:lola_ai_app/features/Memory/components/debug.dart';
import 'package:lola_ai_app/features/Voz/components/debug.dart';
import 'package:lola_ai_app/features/Voz/components/voz_control_form.dart';
import 'package:lola_ai_app/features/Voz/components/voz_control_message.dart';
import 'package:lola_ai_app/features/Voz/components/voz_pad.dart';
import 'package:lola_ai_app/features/core/components/debug_widget.dart';
import 'package:lola_ai_app/features/core/constants.dart';
import 'package:lola_ai_app/features/Lola/lola_stream.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/screens/drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/Voz/voz.dart';

class VozScreen extends StatelessWidget {
  const VozScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Voz',
          style: GoogleFonts.satisfy(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 28,
            fontWeight: FontWeight.w200,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: const VozBody(),
      drawer: const AppDrawer(),
    );
  }
}

class VozBody extends StatefulWidget {
  const VozBody({
    super.key,
  });

  @override
  State<VozBody> createState() => _VozBodyState();
}

class _VozBodyState extends State<VozBody> {
  bool debug = true;
  var debugLolaState = '';
  var debugLolaAudioState = '';
  var debugLolaReplyState = '';
  final $phau = Voz();
  final lola$ = Lola$();
  Stream<LolaState$>? lolaState$;
  Stream<LolaAudioState$>? lolaAudioState$;
  Stream<LolaReplyState$>? lolaReplyState$;
  var scale = Constants.scale;
  final messageFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserPrefereces();

    lolaState$ = lola$.state.stream.asBroadcastStream();
    lolaAudioState$ = lola$.audioState.stream.asBroadcastStream();
    lolaReplyState$ = lola$.replyState.stream.asBroadcastStream();

    if (debug) {
      lolaState$?.listen((state) {
        debugLolaState = state.toString();
      });

      lolaAudioState$?.listen((state) {
        debugLolaAudioState = state.toString();
      });

      lolaReplyState$?.listen((state) {
        debugLolaReplyState = state.toString();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    $phau.dispose();
    lola$.dispose();
  }

  Future<void> _loadUserPrefereces() async {
    final prefs = await SharedPreferences.getInstance();
    String voz = prefs.getString('lola-voice') ?? 'nova';

    setState(() {
      lola$.voice = VoiceLola.values.firstWhere((v) => v.name == voz);
      scale = prefs.getDouble('app-setting-text') ?? Constants.scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: SettingAppText(
              scale: scale,
              onChangedValue: (value) async {
                setState(() => scale = value);
                final prefs = await SharedPreferences.getInstance();
                prefs.setDouble(
                  'app-setting-text',
                  value,
                );
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: LolaPad(
              stream: lolaState$,
              scale: scale,
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: LolaControlAudio(
                    stream: lolaAudioState$,
                    lola: lola$,
                    scale: scale,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: LolaControlMessage(
                    stream: lolaReplyState$,
                    lola: lola$,
                    scale: scale,
                  ),
                ),
              ],
            ),
          ),
          if (debug)
            DebugWidget(
              children: StreamBuilder(
                stream: lolaState$,
                builder: (_, __) => Center(child: Text(debugLolaState)),
              ),
            ),
          if (debug)
            DebugWidget(
              children: StreamBuilder(
                stream: lolaAudioState$,
                builder: (_, __) => Center(child: Text(debugLolaAudioState)),
              ),
            ),
          if (debug)
            DebugWidget(
              children: StreamBuilder(
                stream: lolaReplyState$,
                builder: (_, __) => Center(child: Text(debugLolaReplyState)),
              ),
            ),
          Expanded(
            flex: 4,
            child: VozPad(
              formKey: messageFormKey,
              user: $phau,
              lola$: lola$,
              scale: scale,
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: VozControlFormMessage(
                    formKey: messageFormKey,
                    setState: setState,
                    user: $phau,
                    scale: scale,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: VozControlDisplayMessage(
                    user: $phau,
                    lola: lola$,
                    scale: scale,
                  ),
                ),
              ],
            ),
          ),
          if (debug) DebugMemory(lola: lola$),
          if (debug) const DebugMemorySaveFile(),
          if (debug) const DebugMemoryReadFile(),
          if (debug) DebugVozMessageState(user: $phau),
          if (debug) DebugVozAiState(user: $phau),
          if (debug) DebugVozState(user: $phau),
          if (debug) DebugLolaVoice(lola: lola$),
        ],
      ),
    );
  }
}
