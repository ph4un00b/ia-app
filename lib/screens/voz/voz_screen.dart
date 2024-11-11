import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/App/components/setting_text.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/Lola/components/debug_voice_selector.dart';
import 'package:lola_ai_app/features/AudioPlayer/components/audio_handler.dart';
import 'package:lola_ai_app/features/Lola/components/lola_control_message.dart';
import 'package:lola_ai_app/features/Lola/components/lola_message_pad.dart';
import 'package:lola_ai_app/features/Memory/components/debug.dart';
import 'package:lola_ai_app/features/Voz/components/debug.dart';
import 'package:lola_ai_app/features/Voz/components/voz_control_form.dart';
import 'package:lola_ai_app/features/Voz/components/voz_control_message.dart';
import 'package:lola_ai_app/features/Voz/components/voz_pad.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';
import 'package:lola_ai_app/features/core/components/debug_widget.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:lola_ai_app/features/Lola/lola_controller.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/core/components/test_error_logger.dart';
import 'package:lola_ai_app/screens/drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _debug = !true;
  final _phau = Voz();
  final _lola = LolaController();
  final _messageFormKey = GlobalKey<FormState>();
  Stream<LolaServiceState>? _lolaServiceState;
  Stream<AudioState>? _audioStream;

  var _debugLolaState = '';
  var _debugLolaAudioState = '';
  var _scale = Constants.scale;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();

    _lolaServiceState = _lola.serviceState.stream.asBroadcastStream();
    _audioStream = _lola.audioState.stream.asBroadcastStream();

    if (_debug) {
      _lolaServiceState?.listen((state) {
        _debugLolaState = state.toString();
      });

      _audioStream?.listen((state) {
        _debugLolaAudioState = state.toString();
      });
    }
  }

  @override
  void dispose() {
    _phau.dispose();
    _lola.dispose();
    super.dispose();
    debugPrint('disposing voz screen');
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String voz = prefs.getString('lola-voice') ?? 'nova';

    setState(() {
      _lola.currentVoice = VoiceLola.values.firstWhere((v) => v.name == voz);
      _scale = prefs.getDouble('app-setting-text') ?? Constants.scale;
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
              scale: _scale,
              onChangedValue: (value) async {
                setState(() => _scale = value);
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
            child: LolaServerMessagePad(
              stream: _lolaServiceState,
              scale: _scale,
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AudioHandler(
                    stream: _audioStream,
                    controller: _lola,
                    scale: _scale,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: LolaControlMessage(
                    from: widget.toString(),
                    scale: _scale,
                    stream: _lolaServiceState,
                  ),
                ),
              ],
            ),
          ),
          if (_debug)
            DebugWidget(
              children: StreamBuilder(
                stream: _lolaServiceState,
                builder: (_, __) =>
                    Center(child: Text(_debugLolaState.toString())),
              ),
            ),
          if (_debug)
            DebugWidget(
              children: StreamBuilder(
                stream: _audioStream,
                builder: (_, __) => Center(child: Text(_debugLolaAudioState)),
              ),
            ),
          Expanded(
            flex: 4,
            child: VozPad(
              formKey: _messageFormKey,
              user: _phau,
              lola$: _lola,
              scale: _scale,
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: VozControlFormMessage(
                    formKey: _messageFormKey,
                    setState: setState,
                    user: _phau,
                    scale: _scale,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: VozControlDisplayMessage(
                    from: widget.toString(),
                    user: _phau,
                    lola: _lola,
                    scale: _scale,
                  ),
                ),
              ],
            ),
          ),
          if (_debug) const TestErrorLogger(),
          if (_debug) const DebugClassificationAgent(),
          if (_debug) DebugMemory(lola: _lola),
          if (_debug) const DebugMemorySaveFile(),
          if (_debug) const DebugMemoryReadFile(),
          if (_debug) DebugVozMessageState(user: _phau),
          if (_debug) DebugVozAiState(user: _phau),
          if (_debug) DebugVozState(user: _phau),
          if (_debug) DebugLolaVoice(lola: _lola),
        ],
      ),
    );
  }
}
