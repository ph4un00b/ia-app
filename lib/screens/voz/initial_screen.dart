import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lola_ai_app/config/constants.dart';
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
  double screenScale = Constants.scale;

  @override
  void initState() {
    super.initState();
    _loadTextPreference();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: SafeArea(
            child: Container(
                padding: const EdgeInsets.only(right: 66, left: 0),
                child: Row(children: [
                  const SizedBox(width: 16),
                  const CircleAvatar(
                    // backgroundImage: NetworkImage(
                    //     "<https://randomuser.me/api/portraits/women/84.jpg>"),
                    maxRadius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 8,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Lola",
                            style: GoogleFonts.satisfy(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 28,
                              fontWeight: FontWeight.w200,
                              fontStyle: FontStyle.italic,
                            ),
                            // style: TextStyle(
                            //     fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          // const SizedBox(height: 6),
                          Text(
                            "Online",
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 13),
                          )
                        ]),
                  ),
                  Expanded(
                      child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              showDragHandle: true,
                              barrierColor: Colors.transparent,
                              builder: (bottomSheetContext) {
                                return StatefulBuilder(
                                    builder: (context, setStateModal) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 0, 20, 30),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          child: FilledButton.tonal(
                                            onPressed: () {},
                                            child: Text(
                                                screenScale.toStringAsFixed(2),
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          ),
                                        ),
                                        Expanded(
                                          child: FilledButton.tonal(
                                            onPressed: () async {
                                              double newScale =
                                                  screenScale - 0.1;
                                              setState(
                                                  () => screenScale = newScale);
                                              setStateModal(
                                                  () => screenScale = newScale);

                                              debugPrint(
                                                  "screen-scale: ${screenScale - 0.1}");
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setDouble(
                                                'screen-initial',
                                                screenScale,
                                              );
                                            },
                                            child: const Icon(
                                                Icons.text_decrease,
                                                size: 16),
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: FilledButton.tonal(
                                            onPressed: () async {
                                              double newScale =
                                                  screenScale + 0.1;
                                              setState(
                                                  () => screenScale = newScale);
                                              setStateModal(
                                                  () => screenScale = newScale);

                                              debugPrint(
                                                  "screen-scale: ${screenScale + 0.1}");
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setDouble(
                                                'screen-initial',
                                                screenScale,
                                              );
                                            },
                                            child: const Icon(
                                              Icons.text_increase,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 100,
                                          child: FilledButton.tonal(
                                            onPressed: () async {
                                              debugPrint("screen-scale: 1.0");
                                              double newScale = 1.0;
                                              setState(
                                                  () => screenScale = newScale);
                                              setStateModal(
                                                  () => screenScale = newScale);

                                              (await SharedPreferences
                                                      .getInstance())
                                                  .setDouble(
                                                'screen-initial',
                                                1.0,
                                              );
                                            },
                                            child: const Text(
                                              "Reset",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              },
                            );
                          },
                          icon: Badge(
                                    offset: const Offset(24, 0),
                                    label: Text(screenScale.toStringAsFixed(2)),
                                    textStyle: TextStyle(
                                        fontSize: 12 * screenScale,
                                        fontWeight: FontWeight.w600),
                                    backgroundColor: Colors.orangeAccent,
                                    textColor: Colors.black87,
                                    child: const Icon(Icons.text_fields))))
                ]))),
      ),
      body: InitialVozBody(scale: screenScale),
    );
  }

  Future<void> _loadTextPreference() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      screenScale = prefs.getDouble('screen-initial') ?? screenScale;
    });
  }
}

class InitialVozBody extends StatefulWidget {
  const InitialVozBody({
    super.key,
    required double scale,
  }) : _scale = scale;

  final double _scale;

  @override
  State<InitialVozBody> createState() => _InitialVozBodyState();
}

class _InitialVozBodyState extends State<InitialVozBody> {
  final _debug = !true;
  final _initialCtrl = InitialVozController();
  Stream<LolaServiceState>? _serviceStream;
  Stream<AudioState>? _audioStream;

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
            flex: 4,
            child: LolaServerMessagePad(
                stream: _serviceStream, scale: widget._scale, maxLines: 10),
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
                            scale: widget._scale,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: LolaControlMessage(
                            from: widget.toString(),
                            scale: widget._scale,
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
                            scale: widget._scale,
                            onPressed: () async {
                              final navigator = Navigator.of(context);

                              await _initialCtrl.loadUserMetadata();

                              await switch (_initialCtrl.currentState) {
                                InitialState.idle =>
                                  _initialCtrl.loadSummary(debug: _debug),
                                InitialState.loadingReminders =>
                                  navigator.popAndPushNamed('/voz'),
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
    });
  }
}
