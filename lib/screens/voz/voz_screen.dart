import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/App/components/setting_text.dart';
import 'package:lola_ai_app/features/Lola/components/debug_voice_selector.dart';
import 'package:lola_ai_app/features/Voz/components/voz_action_buttons.dart';
import 'package:lola_ai_app/screens/voz/lola_message/lola_message_screen.dart';
import 'package:lola_ai_app/features/Lola/lola_stream.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Voz/components/voz_message_pad.dart';
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
  bool debug = !true;
  var debugLolaState = '';
  var debugLolaAudioState = '';
  var debugLolaReplyState = '';
  final $phau = Voz();
  final lola$ = Lola$();
  Stream<LolaState$>? lolaState$;
  Stream<LolaAudioState$>? lolaAudioState$;
  Stream<LolaReplyState$>? lolaReplyState$;
  VoiceLola $lolavoice = VoiceLola.nova;
  var scale = 1.0;
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
      $lolavoice = VoiceLola.values.firstWhere((v) => v.name == voz);
      scale = prefs.getDouble('app-setting-text') ?? 1.0;
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
                onTap: () {
                  setState(() {
                    // refresh
                  });
                },
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
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
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
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
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
            child: ListenableBuilder(
              listenable: $phau,
              builder: (_, __) {
                return Card.filled(
                  shape: RoundedRectangleBorder(
                    side: $phau.state == VozState.recording
                        ? const BorderSide(color: Colors.green, width: 2.0)
                        : BorderSide.none,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: InkWell(
                    splashColor: Colors.purple.withAlpha(30),
                    onTap: () async {
                      debugPrint('Card tapped from: ${$phau.state}');
                      if ($phau.state
                          case VozState.idle ||
                              VozState.recordingOk ||
                              VozState.stopRecording ||
                              VozState.playingError ||
                              VozState.playingCompleted) {
                        recordMessage();
                      } else if ($phau.state case VozState.recording) {
                        await $phau.notifyStopRecording();
                        await lola$.loadReply(
                          input: $phau.input,
                          voice: $lolavoice,
                        );
                      } else if ($phau.state case _) {
                        debugPrint('noop');
                      }
                    },
                    child: VozMessagePad(
                      formkey: messageFormKey,
                      state: $phau.messageState,
                      controller: $phau,
                      scale: scale,
                      onMessageEdited: (value) async {
                        if (value != null) {
                          await askLola(value);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Card.filled(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      splashColor: Colors.purple.withAlpha(30),
                      child: ListenableBuilder(
                        listenable: $phau,
                        builder: (_, __) {
                          return switch ($phau.messageState) {
                            VozMessageState.empty => VozEditDisabled(
                                scale: scale,
                              ),
                            VozMessageState.editing => VozRequestAction(
                                scale: scale,
                                onPressed: () {
                                  setState(() {
                                    $phau.messageState = VozMessageState.edited;
                                  });

                                  messageFormKey.currentState?.save();
                                },
                              ),
                            VozMessageState.edited => VozEditAction(
                                scale: scale,
                                onPressed: () {
                                  setState(() {
                                    $phau.messageState =
                                        VozMessageState.editing;
                                  });
                                },
                              ),
                            VozMessageState.loaded => VozEditAction(
                                scale: scale,
                                onPressed: () {
                                  setState(() {
                                    $phau.messageState =
                                        VozMessageState.editing;
                                  });
                                },
                              ),
                          };
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Card.filled(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      splashColor: Colors.purple.withAlpha(30),
                      onTap: () {},
                      child: ListenableBuilder(
                        listenable: $phau,
                        builder: (_, __) {
                          return switch ($phau.messageState) {
                            VozMessageState.empty => VozOpenMessageDisabled(
                                scale: scale,
                              ),
                            VozMessageState.editing => VozOpenMessageDisabled(
                                scale: scale,
                              ),
                            VozMessageState.edited => VozOpenMessageAction(
                                scale: scale,
                                onPressed: () => openUserMessage(context),
                              ),
                            VozMessageState.loaded => VozOpenMessageAction(
                                scale: scale,
                                onPressed: () => openUserMessage(context),
                              ),
                          };
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (debug) _debugVozMessage(),
          if (debug) _debugAi(),
          if (debug) _debugVozState(),
          if (debug) _debugLolaVoz(),
        ],
      ),
    );
  }

  void recordMessage() {
    lola$.stopSpeech();
    $phau.notifyStartRecording();
  }

  Expanded _debugVozMessage() {
    return Expanded(
      flex: 1,
      child: Card.filled(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.purple.withAlpha(30),
          child: ListenableBuilder(
            listenable: $phau,
            builder: (_, __) =>
                Center(child: Text($phau.messageState.toString())),
          ),
        ),
      ),
    );
  }

  Expanded _debugAi() {
    return Expanded(
      flex: 1,
      child: Card.filled(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.purple.withAlpha(30),
          child: ListenableBuilder(
            listenable: $phau,
            builder: (_, __) => Center(child: Text($phau.aiState.toString())),
          ),
        ),
      ),
    );
  }

  Expanded _debugLolaReply() {
    return Expanded(
      flex: 1,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.purple.withAlpha(30),
          child: StreamBuilder(
            stream: lolaReplyState$,
            builder: (_, __) => Center(child: Text(debugLolaReplyState)),
          ),
        ),
      ),
    );
  }

  Expanded _debugLolaAudio() {
    return Expanded(
      flex: 1,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.purple.withAlpha(30),
          child: StreamBuilder(
            stream: lolaAudioState$,
            builder: (_, __) => Center(child: Text(debugLolaAudioState)),
          ),
        ),
      ),
    );
  }

  Expanded _debugLolaState() {
    return Expanded(
      flex: 1,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.purple.withAlpha(30),
          child: StreamBuilder(
            stream: lolaState$,
            builder: (_, __) => Center(child: Text(debugLolaState)),
          ),
        ),
      ),
    );
  }

  Expanded _debugLolaVoz() {
    return Expanded(
      flex: 2,
      child: DebugVoiceSelector(
        $lolavoice: $lolavoice,
        onSelected: (voz) async {
          if (voz != null) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString(
              'lola-voice',
              VoiceLola.values.firstWhere((v) => v.name == voz.name).name,
            );

            setState(() {
              $lolavoice = voz;
            });
          }
        },
      ),
    );
  }

  Expanded _debugVozState() {
    return Expanded(
      flex: 1,
      child: Card.filled(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.purple.withAlpha(30),
          onTap: () {
            debugPrint(
                '>> from: ${$phau.state.toString()}; path?: ${$phau.hasPath}');

            if ($phau.state
                case VozState.recordingOk ||
                    VozState.playingCompleted ||
                    VozState.idle) {
              $phau.notifyPlayAudio();
            } else if ($phau.state case VozState.playing) {
              $phau.notifyStopAudio();
            } else if ($phau.state case _) {
              debugPrint('noop');
            }
          },
          child: ListenableBuilder(
            listenable: $phau,
            builder: (context, child) {
              return Center(
                child: Text(
                  $phau.state.toString(),
                  // textScaler: const TextScaler.linear(1.6),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> askLola(String value) async {
    setState(() {
      $phau.input = value;
    });
    await lola$.loadReply(
      input: $phau.input,
      voice: $lolavoice,
    );
  }

  Future<dynamic> openUserMessage(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => LolaMessageScreen(
        message: $phau.input,
        context: context,
        scale: scale,
      ),
    );
  }

  Future<dynamic> openLolaMessage(BuildContext context, LolaMessage state) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => LolaMessageScreen(
        message: state.message,
        context: context,
        scale: scale,
      ),
    );
  }
}
