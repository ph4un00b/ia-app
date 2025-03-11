import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:lola_ai_app/features/App/components/bottom_tabs.dart';
import 'package:lola_ai_app/features/App/components/core/avatar_lola.dart';
import 'package:lola_ai_app/features/App/status.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/Chat/components/input_form.dart';
import 'package:lola_ai_app/features/Chat/components/message_builder.dart';
import 'package:lola_ai_app/features/Lola/components/lola_loading.dart';
import 'package:lola_ai_app/features/Lola/lola_controller.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/User/user_settings.dart';
import 'package:lola_ai_app/features/Voz/voz_controller.dart';
import 'package:lola_ai_app/features/core/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int pageIndex = 0;
  double screenScale = Constants.scale;

  @override
  void initState() {
    super.initState();
    _loadUserPrefereces();
    _loadUserMetadata();
  }

  Future<void> _loadUserMetadata() async {
    try {
      final userMetadata = await UserSettings.metadata();
      AppStatus.instance.currentUserStatus = userMetadata!.appStatus;
      debugPrint(
          '🚀 ChatScreen.initState: ${DateTime.now()} : ${AppStatus.instance.user?.email} : ${AppStatus.instance.currentUserStatus}');
    } on PostgrestException catch (e) {
      //! manejamos el error de PostgrestException de Supabase por que
      //! se pierde el stacktrace de la excepcion en el logger
      ErrorLogger.logException(e, StackTrace.current);
    } on TimeoutException catch (e) {
      ErrorLogger.logException(e, StackTrace.current);
    } catch (e, st) {
      ErrorLogger.logException(e, st);
    }
  }

  Future<void> _loadUserPrefereces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      screenScale = prefs.getDouble('screen-lola-voz') ?? screenScale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          flexibleSpace: SafeArea(
              child: Container(
                  padding: const EdgeInsets.only(right: 66, left: 0),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const AvatarLola(),
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
                              ),
                              Text(
                                "Online",
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 13),
                              )
                            ],
                          )),
                      Expanded(
                          child: IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  constraints:
                                      const BoxConstraints(maxHeight: 180),
                                  showDragHandle: true,
                                  barrierColor: Colors.transparent,
                                  builder: (bottomSheetContext) =>
                                      _textPickerModal(),
                                );
                              },
                              icon: Badge(
                                  offset: const Offset(24, -6),
                                  label: Text(screenScale.toStringAsFixed(2)),
                                  textStyle: TextStyle(
                                      fontSize: 12 * screenScale,
                                      fontWeight: FontWeight.w600),
                                  backgroundColor: Colors.orangeAccent,
                                  textColor: Colors.black87,
                                  child: const Icon(Icons.text_fields))))
                    ],
                  )))),
      bottomNavigationBar: BottomTabs(scale: screenScale.clamp(0.8, 1.7)),
      body: StackedBody(scale: screenScale),
    );
  }

  StatefulBuilder _textPickerModal() {
    return StatefulBuilder(builder: (context, setStateModal) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: Column(
          children: [
            Text("Ajuste de texto",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0 *
                        screenScale.clamp(
                          0.5,
                          1.5,
                        ))),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: FilledButton.tonal(
                    onPressed: () {},
                    child: Text(screenScale.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 14)),
                  ),
                ),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () async {
                      double newScale = screenScale - 0.1;
                      setState(() => screenScale = newScale.clamp(0.5, 4.0));
                      setStateModal(
                          () => screenScale = newScale.clamp(0.5, 4.0));

                      debugPrint("screen-scale: ${screenScale - 0.1}");
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setDouble(
                        'screen-lola-voz',
                        screenScale,
                      );
                    },
                    child: const Icon(Icons.text_decrease, size: 16),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () async {
                      double newScale = screenScale + 0.1;
                      setState(() => screenScale = newScale.clamp(0.5, 4.0));
                      setStateModal(
                          () => screenScale = newScale.clamp(0.5, 4.0));

                      debugPrint("screen-scale: ${screenScale + 0.1}");
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setDouble(
                        'screen-lola-voz',
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
                      setState(() => screenScale = newScale.clamp(0.5, 4.0));
                      setStateModal(
                          () => screenScale = newScale.clamp(0.5, 4.0));

                      (await SharedPreferences.getInstance()).setDouble(
                        'screen-lola-voz',
                        1.0,
                      );
                    },
                    child: const Text("Reset", style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class StackedBody extends StatefulWidget {
  const StackedBody({
    super.key,
    required double scale,
  }) : _scale = scale;

  final double _scale;

  @override
  State<StackedBody> createState() => _StackedBodyState();
}

class _StackedBodyState extends State<StackedBody> {
  final _debug = true;
  final _userNotifier = VozController();
  final _lolaController = LolaController();
  final _messageFormKey = GlobalKey<FormState>();
  Stream<LolaServiceState>? _lolaStream;
  Stream<AudioState>? _audioStream;

  @override
  void initState() {
    super.initState();

    _lolaStream = _lolaController.serviceState.stream.asBroadcastStream();
    _audioStream = _lolaController.audioState.stream.asBroadcastStream();

    if (_debug) {
      _lolaStream?.listen((state) {
        // _debugLolaState = state.toString();
      });

      _audioStream?.listen((state) {
        // _debugLolaAudioState = state.toString();
      });
    }
  }

  @override
  void dispose() {
    _userNotifier.dispose();
    _lolaController.dispose();
    super.dispose();
    debugPrint('disposing voz screen');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SafeArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LolaLoading(lolaStream: _lolaStream),
              MessagesBuilder(stream: _lolaStream, scale: widget._scale),
              SizedBox(height: Constants.inputHeight * widget._scale)
            ],
          ))),
      InputMessageForm(
          messageFormKey: _messageFormKey,
          userNotifier: _userNotifier,
          lolaController: _lolaController,
          lolaStream: _audioStream,
          scale: widget._scale.clamp(0.5, 2.5))
    ]);
  }
}
