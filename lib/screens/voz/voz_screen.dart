import 'package:flutter/material.dart';
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
  final $phau = Voz();
  final lola$ = Lola$();
  VoiceLola $lolavoice = VoiceLola.nova;
  var scale = 1.0;
  final messageFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserPrefereces();
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
                    stream: lola$.state.stream,
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
                        stream: lola$.audioState.stream,
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
                        stream: lola$.outputState.stream,
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
          // const DebugShowVoices(),
          Expanded(
            flex: 4,
            child: Card.filled(
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
                    lola$.stopSpeech();
                    $phau.notifyStartRecording();
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
                  context: context,
                  scale: scale,
                  onSaved: (value) async {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      $phau.input = value;
                    });
                    await lola$.loadReply(
                      input: $phau.input,
                      voice: $lolavoice,
                    );
                  },
                ),
              ),
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
                        child: switch ($phau.messageState) {
                          VozMessageState.printine => VozEditAction(
                              scale: scale,
                              onPressed: () {
                                setState(() {
                                  $phau.messageState = VozMessageState.editing;
                                });
                              },
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
                                  $phau.messageState = VozMessageState.editing;
                                });
                              },
                            ),
                        }),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Card.filled(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      splashColor: Colors.purple.withAlpha(30),
                      onTap: () {},
                      child: switch ($phau.messageState) {
                        VozMessageState.printine => VozOpenMessageAction(
                            scale: scale,
                            onPressed: () => openUserMessage(context),
                          ),
                        VozMessageState.editing => VozOpenMessageDisabled(
                            scale: scale,
                          ),
                        VozMessageState.edited => VozOpenMessageAction(
                            scale: scale,
                            onPressed: () => openUserMessage(context),
                          ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Expanded(
          //   flex: 1,
          //   child: Row(
          //     children: [
          //       Expanded(
          //         flex: 1,
          //         child: Card.filled(
          //           clipBehavior: Clip.hardEdge,
          //           child: InkWell(
          //             splashColor: Colors.purple.withAlpha(30),
          //             onTap: () {
          //               debugPrint(
          //                   '>> from: ${$phau.state.toString()}; path?: ${$phau.hasPath}');

          //               if ($phau.state
          //                   case VozState.recordingOk ||
          //                       VozState.playingCompleted ||
          //                       VozState.idle) {
          //                 $phau.notifyPlayAudio();
          //               } else if ($phau.state case VozState.playing) {
          //                 $phau.notifyStopAudio();
          //               } else if ($phau.state case _) {
          //                 debugPrint('noop');
          //               }
          //             },
          //             child: ListenableBuilder(
          //               listenable: $phau,
          //               builder: (context, child) {
          //                 return Center(
          //                   child: Text(
          //                     $phau.state.toString(),
          //                     // textScaler: const TextScaler.linear(1.6),
          //                   ),
          //                 );
          //               },
          //             ),
          //           ),
          //         ),
          //       ),
          //       Expanded(
          //         flex: 1,
          //         child: Card(
          //           clipBehavior: Clip.hardEdge,
          //           child: InkWell(
          //             splashColor: Colors.purple.withAlpha(30),
          //             onTap: () {
          //               showModalBottomSheet(
          //                 isScrollControlled: true,
          //                 context: context,
          //                 builder: (ctx) {
          //                   return VozMessage(voz: $phau, context: context);
          //                 },
          //               );
          //             },
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Expanded(
          //   flex: 2,
          //   child: DebugVoiceSelector(
          //     $lolavoice: $lolavoice,
          //     onSelected: (voz) async {
          //       if (voz != null) {
          //         final prefs = await SharedPreferences.getInstance();
          //         prefs.setString(
          //           'lola-voice',
          //           VoiceLola.values.firstWhere((v) => v.name == voz.name).name,
          //         );

          //         setState(() {
          //           $lolavoice = voz;
          //         });
          //       }
          //     },
          //   ),
          // ),
        ],
      ),
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

class SettingAppText extends StatelessWidget {
  const SettingAppText({
    super.key,
    required this.scale,
    required this.onChangedValue,
  });

  final double scale;
  final void Function(double) onChangedValue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Text(
              '${scale.toStringAsFixed(2)} - Ajuste de texto',
              textScaler: TextScaler.linear(1.6 * scale),
            ),
          ),
          Expanded(
            child: Slider(
              value: scale,
              // value: 1.0,
              min: 0.5,
              max: 3.0,
              // divisions: 5,
              label: scale.toString(),
              onChanged: (double value) {
                onChangedValue(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileArgs {
  ProfileArgs({required this.city, required this.country});
  final String city;
  final String country;

  bool get isGermanCapital {
    return country == 'Germany' && city == 'Berlin';
  }
}

class ExampleDestination {
  const ExampleDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<ExampleDestination> destinations = <ExampleDestination>[
  ExampleDestination(
      'Mensajes', Icon(Icons.mail_outline), Icon(Icons.mail_outline)),
  ExampleDestination(
      'Perfil', Icon(Icons.manage_accounts), Icon(Icons.manage_accounts)),
  ExampleDestination(
      'Otros', Icon(Icons.add_circle_outline), Icon(Icons.add_circle_outline)),
];
