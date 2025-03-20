import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:lola_ai_app/features/App/components/bottom_tabs.dart';
import 'package:lola_ai_app/features/App/init.dart';
import 'package:lola_ai_app/features/App/status.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/Chat/components/input_form.dart';
import 'package:lola_ai_app/features/Chat/components/message_builder.dart';
import 'package:lola_ai_app/features/Lola/components/lola_loading.dart';
import 'package:lola_ai_app/features/Lola/components/lola_topbar.dart';
import 'package:lola_ai_app/features/Lola/lola_controller.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Reminders/types.dart';
import 'package:lola_ai_app/features/User/types.dart';
import 'package:lola_ai_app/features/User/user_settings.dart';
import 'package:lola_ai_app/features/Voz/voz_controller.dart';
import 'package:lola_ai_app/features/core/logger.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:lola_ai_app/screens/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  static String routeName = '/voz';

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
    _loadUserPreferences();
    _loadUserMetadata();
  }

  Future<void> _loadUserMetadata() async {
    try {
      final userMetadata = await UserSettings.metadata();

      final decisionResult =
          AppInitDecision.from(userState: AppStatus.instance.currentUserStatus, userMetadata: userMetadata);

      final _ = switch (decisionResult) {
        AppInitDecision.createUserMetadata => await UserSettings.initialize(),
        AppInitDecision.updateUserStatus => AppStatus.instance.currentUserStatus = userMetadata!.appStatus,
        AppInitDecision.none => {},
      };

      debugPrint(
          '🚀 ChatScreen.initState: ${DateTime.now()} : ${AppStatus.instance.user?.email} : ${AppStatus.instance.currentUserStatus}');
    } on PostgrestException catch (e) {
      //! manejamos el error de PostgrestException de Supabase por que
      //! se pierde el stacktrace de la exception en el logger
      ErrorLogger.logException(e, StackTrace.current);
    } on TimeoutException catch (e) {
      ErrorLogger.logException(e, StackTrace.current);
    } catch (e, st) {
      ErrorLogger.logException(e, st);
    }
  }

  Future<void> _loadUserPreferences() async {
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
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
              child: Container(
                  padding: const EdgeInsets.only(right: 0, left: 0),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const LolaAvatar(),
                      const SizedBox(width: 12),
                      const Expanded(flex: 8, child: LolaStatus()),
                      buildLeftWidgets(context),
                    ],
                  )))),
      bottomNavigationBar: BottomTabs(scale: screenScale.clamp(0.8, 1.7)),
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.57, 0.9],
              colors: [Colors.black87, Colors.deepPurple],
            ),
          ),
          child: StackedBody(scale: screenScale)),
    );
  }

  Widget buildLeftWidgets(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  constraints: const BoxConstraints(maxHeight: 180),
                  showDragHandle: true,
                  barrierColor: Colors.transparent,
                  builder: (bottomSheetContext) => _textPickerModal(),
                );
              },
              icon: Badge(
                  offset: const Offset(10, -12),
                  label: Text(screenScale.toStringAsFixed(2)),
                  textStyle: TextStyle(fontSize: 12 * screenScale, fontWeight: FontWeight.w600),
                  backgroundColor: Colors.orangeAccent,
                  textColor: Colors.black87,
                  child: const Icon(Icons.text_fields))),
          // const SizedBox(width: 12),
          IconButton(
              onPressed: () async {
                try {
                  debugPrint(AppStatus.instance.user.toString());
                  await Supabase.instance.client.auth.signOut();
                } catch (e) {
                  debugPrint('Error signing out: $e');
                  ErrorLogger.logException(e, StackTrace.current);
                } finally {
                  AppStatus.instance.user == null;
                  ACTIVE_SESSION = null;

                  unawaited(AppEvent.userReset.track());
                  debugPrint('>> session? ${Supabase.instance.client.auth.currentSession}');
                  AppStatus.instance.reminderStatus = ReminderState.idle;
                  AppStatus.instance.currentUserStatus = UserState.idle;
                  AppStatus.instance.lolaStatus = LolaState.idle;
                  AppStatus.instance.currentReminderChat = [];
                  AppStatus.instance.currentReminder = {};
                }

                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/');
                }
              },
              icon: const Icon(Icons.exit_to_app_sharp)),
        ],
      ),
    );
  }

  StatefulBuilder _textPickerModal() {
    return StatefulBuilder(builder: (context, setStateModal) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: Column(
          children: [
            Text("Ajuste de texto",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0 * screenScale.clamp(0.5, 1.2))),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: FilledButton.tonal(
                    onPressed: () {},
                    child: Text(screenScale.toStringAsFixed(2), style: const TextStyle(fontSize: 14)),
                  ),
                ),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () async {
                      double newScale = screenScale - 0.1;
                      setState(() => screenScale = newScale.clamp(0.5, 4.0));
                      setStateModal(() => screenScale = newScale.clamp(0.5, 4.0));

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
                      setStateModal(() => screenScale = newScale.clamp(0.5, 4.0));

                      debugPrint("screen-scale: ${screenScale + 0.1}");
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setDouble(
                        'screen-lola-voz',
                        screenScale,
                      );
                    },
                    child: const Icon(Icons.text_increase, size: 22),
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
                      setStateModal(() => screenScale = newScale.clamp(0.5, 4.0));

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
  final TextEditingController _queryController = TextEditingController();
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
              MessagesBuilder(
                queryController: _queryController,
                stream: _lolaStream,
                scale: widget._scale,
              ),
              SizedBox(height: Constants.inputHeight * widget._scale)
            ],
          ))),
      InputMessageForm(
          messageFormKey: _messageFormKey,
          queryController: _queryController,
          userNotifier: _userNotifier,
          lolaController: _lolaController,
          lolaStream: _audioStream,
          scale: widget._scale.clamp(0.5, 2.5))
    ]);
  }
}
