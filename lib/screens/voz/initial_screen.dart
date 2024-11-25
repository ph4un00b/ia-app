import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:lola_ai_app/features/App/components/setting_text.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/InitialVoz/initial_voz_controller.dart';
import 'package:lola_ai_app/features/AudioPlayer/components/audio_handler.dart';
import 'package:lola_ai_app/features/Lola/components/lola_control_message.dart';
import 'package:lola_ai_app/features/Lola/components/lola_message_pad.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/core/components/action_btn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialVozScreen extends StatefulWidget {
  const InitialVozScreen({super.key});

  @override
  State<InitialVozScreen> createState() => _InitialVozScreenState();
}

class _InitialVozScreenState extends State<InitialVozScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
      body: const InitialVozBody(),
    );
  }
}

class InitialVozBody extends StatefulWidget {
  const InitialVozBody({
    super.key,
  });

  @override
  State<InitialVozBody> createState() => _InitialVozBodyState();
}

class _InitialVozBodyState extends State<InitialVozBody> {
  final _debug = !true;
  final _initialCtrl = InitialVozController();
  Stream<LolaServiceState>? _serviceStream;
  Stream<AudioState>? _audioStream;
  double _scale = Constants.scale;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();

    _serviceStream = _initialCtrl.serviceState.stream.asBroadcastStream();
    _audioStream = _initialCtrl.audioState.stream.asBroadcastStream();

    // if (_debug) {
    //   _serviceStream?.listen((state) {
    //     _debugServiceState = state.toString();
    //   });

    //   _audioStream?.listen((state) {
    //     _debugAudioState = state.toString();
    //   });
    // }
  }

  @override
  void dispose() {
    _initialCtrl.dispose();
    super.dispose();
    debugPrint('🫡 disposing initial voz body screen');
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
              scale: _scale,
              onChangedValue: (value) async {
                setState(() => _scale = value);
                final prefs = await SharedPreferences.getInstance();
                prefs.setDouble('app-setting-text', value);
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: LolaServerMessagePad(
                stream: _serviceStream, scale: _scale, maxLines: 10),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: LolaAudioHandler(
                            stream: _audioStream,
                            lolaController: _initialCtrl,
                            scale: _scale,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: LolaControlMessage(
                            from: widget.toString(),
                            scale: _scale,
                            stream: _serviceStream,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ActionButton(
                            icon: const Icon(Icons.check),
                            text: 'Continuar',
                            scale: _scale,
                            onPressed: () async {
                              await _initialCtrl.loadUserMetadata();

                              await switch (_initialCtrl.currentState) {
                                InitialState.idle =>
                                  _initialCtrl.loadSummary(debug: _debug),
                                InitialState.loadingReminders =>
                                  Navigator.of(context).popAndPushNamed('/voz'),
                                InitialState.loadingSummary =>
                                  _initialCtrl.loadReminders(debug: _debug)
                              };
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String voz = prefs.getString('lola-voice') ?? 'nova';

    setState(() {
      _initialCtrl.currentVoice =
          VoiceLola.values.firstWhere((v) => v.name == voz);

      _scale = prefs.getDouble('app-setting-text') ?? Constants.scale;
    });
  }
}
