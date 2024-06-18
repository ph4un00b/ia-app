import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/components/debug_voice_selector.dart';
import 'package:lola_ai_app/features/Lola/components/lola_message_pad.dart';
import 'package:lola_ai_app/features/Lola/components/lola_show_full_message_pad.dart';
import 'package:lola_ai_app/features/Lola/components/lola_toggle_audio_pad.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Lola/lola.dart';
import 'package:lola_ai_app/features/Voz/components/voz_message.dart';
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
  final $lola = Lola();

  final TextEditingController lolaController = TextEditingController();
  VoiceLola $lolavoice = VoiceLola.nova;
  var scale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadLolaVoz();
  }

  Future<void> _loadLolaVoz() async {
    final prefs = await SharedPreferences.getInstance();
    String voz = prefs.getString('lola-voice') ?? 'nova';

    setState(() {
      $lolavoice = VoiceLola.values.firstWhere((v) => v.name == voz);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
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
                child: LolaMessagePad(
                  $lola: $lola,
                  $lolavoice: $lolavoice,
                  voz: $phau,
                  context: context,
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
                  child: Card(
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        child: LolaToggleAudioPad($lola: $lola, scale: scale),
                      )),
                ),
                Expanded(
                  flex: 1,
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(child: LolaShowFullMessagePad($lola: $lola)),
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
                    $lola.notifyStopSpeech();
                    $phau.notifyStartRecording();
                  } else if ($phau.state case VozState.recording) {
                    await $phau.notifyStopRecording();
                    $lola.notifyStart();
                  } else if ($phau.state case _) {
                    debugPrint('noop');
                  }
                },
                child: VozMessagePad(voz: $phau, context: context),
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
                ),
                Expanded(
                  flex: 1,
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      splashColor: Colors.purple.withAlpha(30),
                      onTap: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (ctx) {
                            return VozMessage(voz: $phau, context: context);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: DebugVoiceSelector(
              $lolavoice: $lolavoice,
              onSelected: (voz) async {
                if (voz != null) {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString(
                      'lola-voice',
                      VoiceLola.values
                          .firstWhere((v) => v.name == voz.name)
                          .name);

                  setState(() {
                    $lolavoice = voz;
                  });
                }
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
