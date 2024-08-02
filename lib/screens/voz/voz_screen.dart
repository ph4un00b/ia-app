import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/App/components/setting_text.dart';
import 'package:lola_ai_app/features/Lola/components/debug_voice_selector.dart';
import 'package:lola_ai_app/features/Memory/components/debug.dart';
import 'package:lola_ai_app/features/Voz/components/voz_action_buttons.dart';
import 'package:lola_ai_app/features/Voz/components/voz_control_form.dart';
import 'package:lola_ai_app/features/Voz/components/voz_control_message.dart';
import 'package:lola_ai_app/features/Voz/components/voz_pad.dart';
import 'package:lola_ai_app/features/core/components/debug_alt_widget.dart';
import 'package:lola_ai_app/features/core/components/debug_widget.dart';
import 'package:lola_ai_app/features/core/constants.dart';
import 'package:lola_ai_app/screens/voz/lola_message/lola_message_screen.dart';
import 'package:lola_ai_app/features/Lola/lola_stream.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/screens/drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/Voz/voz.dart';
import 'user_message/user_message_screen.dart';

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
            child: Card(
              child: InkWell(
                splashColor: Colors.purple.withAlpha(30),
                onTap: () => setState(() {}),
                child: StreamBuilder(
                    stream: lolaState$,
                    builder: (context, snap) {
                      final ui = snap.data;
                      return switch (ui) {
                        null => Container(),
                        Idle() => ui.empty(),
                        FetchingCompletion() => ui.empty(),
                        CompletionOK() => ui.withMessage(scale: scale),
                        CompletionErr() => ui.empty(),
                        FetchingSpeech() => ui.withMessage(scale: scale),
                        SpeechOk() => ui.withMessage(scale: scale),
                        SpeechErr() => ui.withMessage(scale: scale),
                        SpeakingIdle() => ui.withMessage(scale: scale),
                        SpeakingOK() => ui.withMessage(scale: scale),
                        SpeakingErr() => ui.withMessage(scale: scale),
                      };
                    }),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: StreamBuilder(
                    stream: lolaAudioState$,
                    builder: (context, snap) {
                      final ui = snap.data;
                      return switch (ui) {
                        null => Container(),
                        NonePath() => ui.actionDisabled(scale: scale),
                        Playing() => ui.stop(
                            scale: scale,
                            action: () => lola$.stopSpeech(),
                          ),
                        PlayingErr() => ui.replay(
                            scale: scale,
                            action: () => lola$.playSpeech(),
                          ),
                        PlayingCompleted() => ui.replay(
                            scale: scale,
                            action: () => lola$.playSpeech(),
                          ),
                        Stopped() => ui.play(
                            scale,
                            action: () => lola$.playSpeech(),
                          ),
                        StoppedErr() => ui.play(
                            scale,
                            action: () => lola$.playSpeech(),
                          ),
                      };
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: StreamBuilder(
                    stream: lolaReplyState$,
                    builder: (context, snap) {
                      final ui = snap.data;
                      return switch (ui) {
                        null => Container(),
                        LolaEmpty() => ui.actionDisabled(scale: scale),
                        LolaMessage() => ui.actionEnabled(
                            scale: scale,
                            action: () => openLolaMessage(context, ui),
                          ),
                      };
                    },
                  ),
                ),
              ],
            ),
          ),
          if (debug) _debugLolaState(),
          if (debug) _debugLolaAudio(),
          if (debug) _debugLolaReply(),
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
          if (debug) DebugMemory(lola$: lola$),
          if (debug) const DebugMemorySaveFile(),
          if (debug) const DebugMemoryReadFile(),
          if (debug) _debugVozMessage(),
          if (debug) _debugAi(),
          if (debug) _debugVozState(),
          if (debug) _debugLolaVoz(),
        ],
      ),
    );
  }

  Widget _debugLolaReply() {
    return DebugWidget(
      children: StreamBuilder(
        stream: lolaReplyState$,
        builder: (_, __) => Center(child: Text(debugLolaReplyState)),
      ),
    );
  }

  Widget _debugLolaAudio() {
    return DebugWidget(
      children: StreamBuilder(
        stream: lolaAudioState$,
        builder: (_, __) => Center(child: Text(debugLolaAudioState)),
      ),
    );
  }

  Widget _debugLolaState() {
    return DebugWidget(
      children: StreamBuilder(
        stream: lolaState$,
        builder: (_, __) => Center(child: Text(debugLolaState)),
      ),
    );
  }

  Widget _debugVozMessage() {
    return DebugAltWidget(
      children: ListenableBuilder(
        listenable: $phau,
        builder: (_, __) {
          return Center(child: Text($phau.messageState.toString()));
        },
      ),
    );
  }

  Widget _debugAi() {
    return DebugAltWidget(
      children: ListenableBuilder(
        listenable: $phau,
        builder: (_, __) {
          return Center(child: Text($phau.aiState.toString()));
        },
      ),
    );
  }

  Widget _debugVozState() {
    return DebugAltWidget(
      children: ListenableBuilder(
        listenable: $phau,
        builder: (_, __) {
          return Center(child: Text($phau.state.toString()));
        },
      ),
    );
  }

  Expanded _debugLolaVoz() {
    return Expanded(
      flex: 2,
      child: DebugVoiceSelector(
        $lolavoice: lola$.voice,
        onSelected: (voz) async {
          if (voz != null) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString(
              'lola-voice',
              VoiceLola.values.firstWhere((v) => v.name == voz.name).name,
            );

            setState(() {
              lola$.voice = voz;
            });
          }
        },
      ),
    );
  }

  Future<dynamic> openUserMessage(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => UserMessageScreen(
        lolaController: lola$,
        controller: $phau,
        parentContext: context,
        scale: scale,
      ),
    );
  }

  Future<dynamic> openLolaMessage(BuildContext context, LolaMessage state) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => LolaMessageScreen(
        controller: lola$,
        parentContext: context,
        scale: scale,
      ),
    );
  }
}
