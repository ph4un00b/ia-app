import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:lola_ai_app/features/AudioPlayer/components/audio_handler.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/Lola/lola_controller.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Voz/voz_controller.dart';
import 'package:lola_ai_app/screens/voz/lola_message/lola_message_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:keyboard_actions/keyboard_actions.dart';
// import 'package:keyboard_actions/keyboard_actions_config.dart';

const double _INPUT_H = 60.0;

final class ChatMessage {
  String msgContent;
  String msgType;
  ChatMessage({required this.msgContent, required this.msgType});
}

List<ChatMessage> messages = [
  ChatMessage(msgContent: "Hello, Will", msgType: "receiver"),
  ChatMessage(msgContent: "How have you been?", msgType: "receiver"),
  ChatMessage(
      msgContent: "I am doing fine dude. wbu asdasd dsa ds dsa d af sfafaasf?",
      msgType: "sender"),
  ChatMessage(
      msgContent: "ehhhh, doing OK af f fasfaafs.", msgType: "receiver"),
  ChatMessage(msgContent: "Is there any thing wrong?", msgType: "sender"),
  ChatMessage(
      msgContent: "ehhhh, doing OK af f fasfaafs.", msgType: "receiver"),
  ChatMessage(msgContent: "Hello, Will", msgType: "receiver"),
  ChatMessage(msgContent: "How have you been?", msgType: "receiver"),
  ChatMessage(
      msgContent: "I am doing fine dude. wbu asdasd dsa ds dsa d af sfafaasf?",
      msgType: "sender"),
  ChatMessage(
      msgContent: "ehhhh, doing OK af f fasfaafs.", msgType: "receiver"),
  ChatMessage(msgContent: "Is there any thing wrong?", msgType: "sender"),
  ChatMessage(
      msgContent: "ehhhh, doing OK af f fasfaafs.", msgType: "receiver"),
  ChatMessage(
      msgContent: "I am doing fine dude. wbu asdasd dsa ds dsa d af sfafaasf?",
      msgType: "sender"),
  ChatMessage(
      msgContent: "ehhhh, doing OK af f fasfaafs.", msgType: "receiver"),
  ChatMessage(msgContent: "Is there any thing wrong?", msgType: "sender"),
  ChatMessage(
      msgContent: "ehhhh, doing OK af f fasfaafs.", msgType: "receiver"),
];

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  int pageIndex = 0;
  double screenScale = Constants.scale;

  // final _userNotifier = VozController();
  // final _messageFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserPrefereces();
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
          // centerTitle: true,
          // automaticallyImplyLeading: !false,
          // backgroundColor: Colors.grey[900],
          flexibleSpace: SafeArea(
              child: Container(
                  padding: const EdgeInsets.only(right: 66, left: 0),
                  child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // IconButton(
                        //   onPressed: () {
                        //     Navigator.pop(context);
                        //   },
                        //   icon: const Icon(
                        //     Icons.arrow_back,
                        //     color: Colors.white,
                        //   ),
                        // ),
                        const SizedBox(width: 16),
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
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
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
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
                                      color: Colors.grey.shade400,
                                      fontSize: 13),
                                )
                              ]),
                        ),
                        Expanded(
                            child: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    constraints: const BoxConstraints(
                                        maxHeight: _INPUT_H * 3),
                                    showDragHandle: true,
                                    barrierColor: Colors.transparent,
                                    builder: (bottomSheetContext) {
                                      return StatefulBuilder(
                                          builder: (context, setStateModal) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 0, 20, 30),
                                          child: Column(
                                            children: [
                                              Text("Ajuste de texto",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                      child: Text(
                                                          screenScale
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      14)),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: FilledButton.tonal(
                                                      onPressed: () async {
                                                        double newScale =
                                                            screenScale - 0.1;
                                                        setState(() =>
                                                            screenScale =
                                                                newScale);
                                                        setStateModal(() =>
                                                            screenScale =
                                                                newScale);

                                                        debugPrint(
                                                            "screen-scale: ${screenScale - 0.1}");
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        prefs.setDouble(
                                                          'screen-lola-voz',
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
                                                        setState(() =>
                                                            screenScale =
                                                                newScale);
                                                        setStateModal(() =>
                                                            screenScale =
                                                                newScale);

                                                        debugPrint(
                                                            "screen-scale: ${screenScale + 0.1}");
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
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
                                                        debugPrint(
                                                            "screen-scale: 1.0");
                                                        double newScale = 1.0;
                                                        setState(() =>
                                                            screenScale =
                                                                newScale);
                                                        setStateModal(() =>
                                                            screenScale =
                                                                newScale);

                                                        (await SharedPreferences
                                                                .getInstance())
                                                            .setDouble(
                                                          'screen-lola-voz',
                                                          1.0,
                                                        );
                                                      },
                                                      child: const Text("Reset",
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                    },
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
                      ])))
          // toolbarHeight: 140,
          // title: const Column(
          //   children: [
          //     HeaderUI(),
          //     // SearchBarUI()
          //   ],
          // ),
          ),
      bottomNavigationBar: BottomTabs(scale: screenScale.clamp(0.8, 1.7)),
      // bottomNavigationBar: buildCustomBottomTabs(context),
      // body: const VoiceBody(),
      body: StackedBody(scale: screenScale),
    );
  }

  Theme buildCustomBottomTabs(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    setState(() {
                      pageIndex = 0;
                    });
                  },
                  icon: pageIndex == 0
                      ? const Icon(
                          Icons.home_filled,
                          color: Colors.white70,
                          size: 35,
                        )
                      : const Icon(
                          Icons.home_outlined,
                          color: Colors.white70,
                          size: 35,
                        ),
                ),
                IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    setState(() {
                      pageIndex = 1;
                    });
                  },
                  icon: pageIndex == 1
                      ? const Icon(
                          Icons.work_rounded,
                          color: Colors.white70,
                          size: 35,
                        )
                      : const Icon(
                          Icons.work_outline_outlined,
                          color: Colors.white70,
                          size: 35,
                        ),
                ),
                IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    setState(() {
                      pageIndex = 2;
                    });
                  },
                  icon: pageIndex == 2
                      ? const Icon(
                          Icons.widgets_rounded,
                          color: Colors.white70,
                          size: 35,
                        )
                      : const Icon(
                          Icons.widgets_outlined,
                          color: Colors.white70,
                          size: 35,
                        ),
                ),
                IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    setState(() {
                      pageIndex = 3;
                    });
                  },
                  icon: pageIndex == 3
                      ? const Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 35,
                        )
                      : const Icon(
                          Icons.person_outline,
                          color: Colors.white70,
                          size: 35,
                        ),
                ),
              ],
            ),
            // InputChat(
            //     userNotifier: _userNotifier, messageFormKey: _messageFormKey)
          ],
        ),
      ),
    );
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

  // var _debugLolaState = '';
  // var _debugLolaAudioState = '';
  // var _scale = Constants.scale;

  @override
  void initState() {
    super.initState();
    // _loadUserPreferences();

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
    return Stack(
      children: [
        // SafeArea(child: LolaServerMessagePad(scale: 1.0, stream: _lolaStream)),
        SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  MessagesBuilder(stream: _lolaStream, scale: widget._scale),
                  SizedBox(height: _INPUT_H * 2.2 * widget._scale)
                ]))),
        InputMessageForm(
          messageFormKey: _messageFormKey,
          userNotifier: _userNotifier,
          lolaController: _lolaController,
          lolaStream: _audioStream,
          scale: widget._scale.clamp(0.5, 2.5),
        )
      ],
    );
  }
}

class MessagesBuilder extends StatelessWidget {
  const MessagesBuilder({
    super.key,
    required double scale,
    required Stream<LolaServiceState>? stream,
  })  : _scale = scale,
        _stream = stream;

  final double _scale;
  final Stream<LolaServiceState>? _stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          final service = snapshot.data;
          return switch (service) {
            null => respuestaLola([
                ChatMessage(msgContent: "null", msgType: "sender"),
                ChatMessage(msgContent: "null", msgType: "receiver"),
              ]),
            IdleService(payload: final _) => respuestaLola([
                ChatMessage(
                    msgContent:
                        "Bienvenido/a. Puedes comenzar la conversación cuando lo desees, estoy aquí para ayudarte y responderé a todos tus mensajes.",
                    msgType: "sender"),
                // ChatMessage(msgContent: message.reply, msgType: "receiver"),
              ]),
            Loading(payload: final payload) => respuestaLola([
                ChatMessage(
                    msgContent: payload.userQuestion, msgType: "sender"),
                ChatMessage(msgContent: payload.reply, msgType: "receiver"),
              ]),
            Data(payload: final payload) => respuestaLola([
                ChatMessage(
                    msgContent: payload.userQuestion, msgType: "sender"),
                ChatMessage(msgContent: payload.reply, msgType: "receiver"),
              ]),
            Error(payload: final message) => respuestaLola([
                ChatMessage(
                    msgContent: message.userQuestion, msgType: "sender"),
                ChatMessage(msgContent: message.reply, msgType: "receiver"),
              ]),
          };
        });
  }

  ListView respuestaLola(List<ChatMessage> messages) {
    return ListView.builder(
        itemCount: messages.length,
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
              // padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: LayoutBuilder(builder: (_, constrains) {
                // return Align(
                //   alignment: (messages[index].msgType == "receiver"
                //       ? Alignment.topLeft
                //       : Alignment.topRight),``
                //   child: Container(
                //     decoration: BoxDecoration(``
                //       borderRadius: BorderRadius.circular(20),
                //       color: (messages[index].msgType == "receiver"
                //           ? Colors.grey.shade800
                //           : Colors.blue[800]),
                //     ),
                //     padding: EdgeInsets.all(16),
                //     child: Text(
                //       messages[index].msgContent,
                //       style: TextStyle(fontSize: 35),
                //     ),
                //   ),
                // );
                return Row(children: [
                  if (messages[index].msgType == "sender") const Spacer(),
                  ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: constrains.maxWidth),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: (messages[index].msgType == "receiver"
                                // ? Colors.grey.shade900
                                ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainer),
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(messages[index].msgContent,
                                style: TextStyle(
                                    color: messages[index].msgType == "receiver"
                                        ? Colors.white70
                                        : Theme.of(context).colorScheme.primary,
                                    fontSize: 15 * _scale))),
                      )),
                  if (messages[index].msgType != "sender") const Spacer()
                ]);
              }));
        });
  }
}

class InputMessageForm extends StatelessWidget {
  const InputMessageForm({
    super.key,
    required VozController userNotifier,
    required GlobalKey<FormState> messageFormKey,
    required LolaController lolaController,
    required Stream<AudioState>? lolaStream,
    required double scale,
    // TODO: preguntar sobre este patron de init
  })  : _userNotifier = userNotifier,
        _lolaController = lolaController,
        _lolaStream = lolaStream,
        _messageFormKey = messageFormKey,
        _scale = scale;

  final VozController _userNotifier;
  final GlobalKey<FormState> _messageFormKey;
  final LolaController _lolaController;
  final Stream<AudioState>? _lolaStream;
  final double _scale;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomLeft,
        child: Container(
            padding: const EdgeInsets.only(left: 0, bottom: 0, top: 0),
            color: Colors.black87,
            // color: Colors.amber,
            height: _INPUT_H * 2.2,
            width: double.infinity,
            child: Column(children: [
              Expanded(
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Expanded(
                    flex: 1,
                    child: ListenableBuilder(
                        listenable: _userNotifier,
                        builder: (_, __) {
                          return Form(
                              key: _messageFormKey,
                              child: TextFormField(

                                  // style: ,
                                  style: TextStyle(
                                    fontSize: 16.0 * _scale,
                                  ),
                                  maxLength: 2048,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  // expands: true,
                                  validator: (value) {
                                    debugPrint('input valido? $value');
                                    // TODO: como hacer mas prolijo ese is String?
                                    if (value is String) {
                                      if (value.isEmpty) {
                                        return 'Field required';
                                      } else {
                                        return null;
                                      }
                                    }
                                    return 'Field Required';
                                  },
                                  minLines: null,
                                  maxLines: 3,
                                  controller: TextEditingController(
                                      text: _userNotifier.content()),
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.unspecified,
                                  decoration: InputDecoration(
                                    // constraints: const BoxConstraints.expand(height: 100),
                                    // enabledBorder: const OutlineInputBorder(),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        debugPrint(_messageFormKey.currentState
                                            .toString());
                                        _messageFormKey.currentState?.reset();
                                        _userNotifier.updateContent("");
                                      },
                                      child: Icon(
                                        Icons.delete_forever,
                                        color: Colors.white70,
                                        size: 24 * _scale,
                                      ),
                                    ),
                                    // fillColor: Colors.grey[900],
                                    filled: true,
                                    fillColor: Colors.grey[900],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),

                                    // alignLabelWithHint: true,

                                    hintText: "Escribe a Lola",
                                    hintStyle: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 16 * _scale,
                                    ),

                                    // border: InputBorder.none,
                                  ),
                                  onFieldSubmitted: (value) {
                                    debugPrint(
                                        '>> on-field-sbt: ${_messageFormKey.currentContext?.size}');
                                    var sk = SnackBar(
                                        content: Text('Hello: $value'));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(sk);
                                  },
                                  onSaved: (value) {
                                    debugPrint('>> on-saved-value: $value');
                                    if (value == null) return;

                                    _userNotifier.updateContent(value);
                                  },
                                  onTapOutside: (event) {
                                    debugPrint('>> unfocusing: $event');
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  }));
                        })),
                SizedBox(
                    width: 122,
                    // color: Colors.amber,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RecordingAction(
                                    userNotifier: _userNotifier,
                                    messageFormKey: _messageFormKey,
                                    lolaController: _lolaController,
                                    scale: _scale.clamp(0.5, 1.50)),
                                // const SizedBox(width: 16),
                                SendAction(
                                    userNotifier: _userNotifier,
                                    messageFormKey: _messageFormKey,
                                    lolaController: _lolaController,
                                    scale: _scale.clamp(0.5, 1.50)),

                                // const SizedBox(width: 4),
                              ]),
                          const SizedBox(height: 10),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                LolaAudioHandler(
                                  stream: _lolaStream,
                                  lolaController: _lolaController,
                                  scale: _scale.clamp(0.5, 1.20),
                                )
                                // const SizedBox(width: 4),
                              ])
                        ]))
              ]))
            ])));
  }
}

class SendAction extends StatelessWidget {
  const SendAction({
    super.key,
    required VozController userNotifier,
    required GlobalKey<FormState> messageFormKey,
    required LolaController lolaController,
    required double scale,
  })  : _userNotifier = userNotifier,
        _lolaController = lolaController,
        _scale = scale,
        _messageFormKey = messageFormKey;

  final VozController _userNotifier;
  final GlobalKey<FormState> _messageFormKey;
  final LolaController _lolaController;
  final double _scale;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: _userNotifier,
        builder: (_, __) {
          return Material(
            elevation: 0,
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () async {
                _messageFormKey.currentState?.save();
                await _lolaController.queryReply(
                    userQuestion: _userNotifier.content(), debug: true);
              },
              child: Ink(
                height: 40 * _scale,
                width: 40 * _scale,
                decoration: BoxDecoration(
                  // color: Colors.lightBlue,
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.send,
                  color: Colors.white70,
                  size: 22 * _scale,
                ),
              ),
            ),
          );
          // return ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       fixedSize: const Size.fromWidth(5),
          //       shape: const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.all(Radius.circular(20))),
          //     ),
          //     onPressed: () async {
          //       _messageFormKey.currentState?.save();
          //       await _lolaController.queryReply(
          //           userQuestion: _userNotifier.content(), debug: true);
          //     },
          //     child: Icon(Icons.send, size: 22 * _scale));
        });
  }
}

class RecordingAction extends StatelessWidget {
  const RecordingAction({
    super.key,
    required VozController userNotifier,
    required GlobalKey<FormState> messageFormKey,
    required LolaController lolaController,
    required double scale,
  })  : _userNotifier = userNotifier,
        _lolaController = lolaController,
        _scale = scale,
        _messageFormKey = messageFormKey;

  final VozController _userNotifier;
  final GlobalKey<FormState> _messageFormKey;
  final LolaController _lolaController;
  final double _scale;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: _userNotifier,
        builder: (_, __) {
          if (_userNotifier.currentStatus == RecordState.recording) {
            // return ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //         shape: const CircleBorder(),
            //         fixedSize: Size.fromHeight(40 * _scale)),
            //     onPressed: () async {
            //       _messageFormKey.currentState?.save();
            //       await _lolaController.queryReply(
            //           userQuestion: _userNotifier.content(), debug: true);
            //     },
            //     child: Icon(Icons.send, size: 22 * _scale));

            // return GestureDetector(
            //   onTap: () {
            //     _handleUserRecording();
            //     _messageFormKey.currentState?.save();
            //   },
            //   child: Container(
            //     height: 40 * _scale,
            //     width: 40 * _scale,
            //     decoration: BoxDecoration(
            //       color: Colors.green,
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     child: Icon(
            //       Icons.mic,
            //       color: Colors.white,
            //       size: 24 * _scale,
            //     ),
            //   ),
            // );

            return Material(
              elevation: 0,
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  _handleUserRecording();
                  _messageFormKey.currentState?.save();
                },
                child: Ink(
                  height: 40 * _scale,
                  width: 40 * _scale,
                  decoration: BoxDecoration(
                    // color: Colors.lightBlue,
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.mic,
                    color: Colors.green,
                    size: 24 * _scale,
                  ),
                ),
              ),
            );
          } else {
            return Material(
              elevation: 0,
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  _handleUserRecording();
                  _messageFormKey.currentState?.save();
                },
                child: Ink(
                  height: 40 * _scale,
                  width: 40 * _scale,
                  decoration: BoxDecoration(
                    // color: Colors.lightBlue,
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.mic,
                    color: Colors.white70,
                    size: 24 * _scale,
                  ),
                ),
              ),
            );
            // return GestureDetector(
            //   onTap: () {
            //     _handleUserRecording();
            //     _messageFormKey.currentState?.save();
            //   },
            //   child: Container(
            //     height: 40 * _scale,
            //     width: 40 * _scale,
            //     decoration: BoxDecoration(
            //       color: Colors.lightBlue,
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     child: Icon(
            //       Icons.mic,
            //       color: Colors.white,
            //       size: 24 * _scale,
            //     ),
            //   ),
            // );

            // return ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       fixedSize: const Size.fromWidth(5),
            //       shape: const RoundedRectangleBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(20))),
            //     ),
            //     onPressed: () async {
            //       _messageFormKey.currentState?.save();
            //       await _lolaController.queryReply(
            //           userQuestion: _userNotifier.content(), debug: true);
            //     },
            //     child: Icon(Icons.send, size: 22 * _scale));
          }
        });
  }

  Future<void> _handleUserRecording() async {
    if (_userNotifier.currentStatus
        case RecordState.idle ||
            RecordState.recordingOk ||
            RecordState.stopRecording ||
            RecordState.stopRecordingError ||
            RecordState.playingError ||
            RecordState.playingCompleted) {
      await _lolaController.stopAudio();
      await _userNotifier.startRecording();
    } else if (_userNotifier.currentStatus case RecordState.recording) {
      await _userNotifier.stopRecording();
      await _lolaController.queryReply(
          userQuestion: _userNotifier.content(), debug: true);
    } else if (_userNotifier.currentStatus case _) {
      debugPrint('noop');
    }
  }
}

class BottomTabs extends StatefulWidget {
  const BottomTabs({
    super.key,
    required double scale,
  }) : _scale = scale;

  final double _scale;

  @override
  State<BottomTabs> createState() => _BottomTabsState();
}

class _BottomTabsState extends State<BottomTabs> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        elevation: 0.0,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        // TODO: shifted will not work since you need to tap the icon itself
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        unselectedFontSize: 14 * widget._scale,
        selectedFontSize: 14 * widget._scale,
        items: [
          BottomNavigationBarItem(
              label: "Mensajes",
              icon: IconButton(
                  // padding: EdgeInsets.all(20),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/opciones/mensajes');
                  },
                  icon: Badge(
                      label: Text("24",
                          style: TextStyle(fontSize: 12 * widget._scale)),
                      backgroundColor: Colors.orangeAccent,
                      textColor: Colors.black87,
                      child: const Icon(Icons.message)))),
          BottomNavigationBarItem(
              label: "Lola",
              icon: IconButton(
                  onPressed: () {},
                  icon: const Badge(
                      // label: Text("24"),
                      backgroundColor: Colors.orangeAccent,
                      textColor: Colors.black87,
                      child: Icon(Icons.auto_awesome_mosaic))))
        ]);
  }
}

class VoiceBody extends StatefulWidget {
  const VoiceBody({
    super.key,
  });

  @override
  State<VoiceBody> createState() => _VoiceBodyState();
}

class _VoiceBodyState extends State<VoiceBody> {
  final _userNotifier = VozController();
  // final _lola = LolaController();
  final _messageFormKey = GlobalKey<FormState>();

  ///////////// KEYBOARD ACTIONS ////////////////
  // final _nameFocus = FocusNode();
  // final _cardNumberFocus = FocusNode();
  // final _cardPinFocus = FocusNode();

  /// Creates the [KeyboardActionsConfig] to hook up the fields
  /// and their focus nodes to our [FormKeyboardActions].
  // KeyboardActionsConfig _buildKeyboardActionsConfig(BuildContext context) {
  //   return KeyboardActionsConfig(
  //     keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
  //     keyboardBarColor: Colors.grey,
  //     actions: [
  //       KeyboardActionsItem(
  //         focusNode: _nameFocus,
  //       ),
  //       KeyboardActionsItem(
  //         focusNode: _cardNumberFocus,
  //       ),
  //       KeyboardActionsItem(
  //         focusNode: _cardPinFocus,
  //       ),
  //     ],
  //   );
  // }
  ///////////// KEYBOARD ACTIONS END ////////////////

  @override
  void dispose() {
    _userNotifier.dispose();
    // _lola.dispose();
    super.dispose();
    debugPrint('disposing voice screen');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SafeArea(
          child: ListView.builder(
            itemCount: messages.length,
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                // padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: LayoutBuilder(
                  builder: (_, constrains) {
                    // return Align(
                    //   alignment: (messages[index].msgType == "receiver"
                    //       ? Alignment.topLeft
                    //       : Alignment.topRight),``
                    //   child: Container(
                    //     decoration: BoxDecoration(``
                    //       borderRadius: BorderRadius.circular(20),
                    //       color: (messages[index].msgType == "receiver"
                    //           ? Colors.grey.shade800
                    //           : Colors.blue[800]),
                    //     ),
                    //     padding: EdgeInsets.all(16),
                    //     child: Text(
                    //       messages[index].msgContent,
                    //       style: TextStyle(fontSize: 35),
                    //     ),
                    //   ),
                    // );
                    return Row(
                      children: [
                        if (messages[index].msgType == "sender") const Spacer(),
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: constrains.maxWidth),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: (messages[index].msgType == "receiver"
                                    ? Colors.grey.shade800
                                    : Colors.blue[800]),
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                messages[index].msgContent,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                        if (messages[index].msgType != "sender") const Spacer(),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
        // child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        // const Expanded(
        //   child: SingleChildScrollView(
        //     child: !true
        //         ? Icon(
        //             Icons.multitrack_audio,
        //             size: 72,
        //           )
        //         : Text("jamon"),
        //   ),
        // ),
        InputChat(userNotifier: _userNotifier, messageFormKey: _messageFormKey)
      ]),
    );
  }
}

class SearchBarUI extends StatelessWidget {
  const SearchBarUI({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search...",
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.all(8),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade100)),
        ),
      ),
    );
  }
}

class HeaderUI extends StatelessWidget {
  const HeaderUI({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Voz',
            style: GoogleFonts.satisfy(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 28,
              fontWeight: FontWeight.w200,
              fontStyle: FontStyle.italic,
            ),
          ),
          // const Text(
          //   "Conversations",
          //   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          // ),
          Container(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.grey[800],
            ),
            child: const Row(
              children: <Widget>[
                Icon(
                  Icons.add,
                  color: Colors.pink,
                  size: 20,
                ),
                SizedBox(
                  width: 2,
                ),
                Text(
                  "Add New",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class InputChat extends StatelessWidget {
  const InputChat({
    super.key,
    required VozController userNotifier,
    required GlobalKey<FormState> messageFormKey,
  })  : _userNotifier = userNotifier,
        _messageFormKey = messageFormKey;

  final VozController _userNotifier;
  final GlobalKey<FormState> _messageFormKey;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Row(children: [
          Flexible(
              flex: 4,
              // TODO: que es mejor un listener con varios componentes ó varios listener con un componente?
              child: InputChatMessage(
                  userNotifier: _userNotifier,
                  messageFormKey: _messageFormKey)),
          // const SizedBox(width: 12),
          Flexible(
              flex: 1,
              // TODO: probar LayoutBuilder para obtener dinamicamente el heigth?
              // height: _messageFormKey.currentContext?.size?.height,
              // height: 200,
              // color: Colors.greenAccent[700],
              child: InputChatActions(
                  userNotifier: _userNotifier, messageFormKey: _messageFormKey))
        ]));
  }
}

class InputChatActions extends StatelessWidget {
  const InputChatActions({
    super.key,
    required VozController userNotifier,
    required GlobalKey<FormState> messageFormKey,
    // TODO: preguntar sobre este patron de init
  })  : _userNotifier = userNotifier,
        _messageFormKey = messageFormKey;

  final VozController _userNotifier;
  final GlobalKey<FormState> _messageFormKey;

  Future<void> _handleUserRecording() async {
    if (_userNotifier.currentStatus
        case RecordState.idle ||
            RecordState.recordingOk ||
            RecordState.stopRecording ||
            RecordState.stopRecordingError ||
            RecordState.playingError ||
            RecordState.playingCompleted) {
      // await lolaController.stopAudio();
      await _userNotifier.startRecording();
    } else if (_userNotifier.currentStatus case RecordState.recording) {
      await _userNotifier.stopRecording();
      // await lolaController.queryReply(
      // userQuestion: _userController.content(), debug: debug);
    } else if (_userNotifier.currentStatus case _) {
      debugPrint('noop');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      ListenableBuilder(
          listenable: _userNotifier,
          builder: (_, __) {
            return _userNotifier.currentStatus == RecordState.recording
                ? IconButton(
                    color: Colors.redAccent,
                    // onPressed: () {},
                    onPressed: _handleUserRecording,
                    icon: const Icon(Icons.mic))
                : IconButton.filledTonal(
                    color: Colors.white70,
                    // onPressed: () {},
                    onPressed: _handleUserRecording,
                    icon: const Icon(Icons.mic));
          }),
      // TODO: dejar para otra ocasión la feature de copiar
      // IconButton.filledTonal(
      //     color: Colors.white70,
      //     onPressed: () async {
      //       await Clipboard.setData(
      //           ClipboardData(text: _userNotifier.content()));

      //       var snackBar =
      //           const SnackBar(content: Text('copied!'));
      //       ScaffoldMessenger.of(context)
      //           .showSnackBar(snackBar);
      //     },
      //     icon: const Icon(Icons.save)),

      IconButton.filledTonal(
          color: Colors.white70,
          // onPressed: () {},
          onPressed: () {
            // TODO: probar bien el reset!
            debugPrint(_messageFormKey.currentState.toString());
            _messageFormKey.currentState?.reset();
          },
          icon: const Icon(Icons.delete_forever)),
      IconButton.filledTonal(
          color: Colors.white70,
          // onPressed: () {},
          onPressed: () {
            debugPrint('preguntando a lola!');
            var isValid = _messageFormKey.currentState?.validate();

            if (isValid == null) return;
            if (isValid) {
              _messageFormKey.currentState?.save();
            }
          },
          icon: const Icon(Icons.send_outlined)),
    ]);
  }
}

class InputChatMessage extends StatelessWidget {
  const InputChatMessage({
    super.key,
    required VozController userNotifier,
    required GlobalKey<FormState> messageFormKey,
    // TODO: preguntar sobre este patron de init
  })  : _userNotifier = userNotifier,
        _messageFormKey = messageFormKey;

  final VozController _userNotifier;
  final GlobalKey<FormState> _messageFormKey;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: _userNotifier,
        builder: (_, __) {
          // debugPrint("size: ${ctx.size?.height}");
          return Form(
            key: _messageFormKey,
            child: TextFormField(
                validator: (value) {
                  debugPrint('input valido? $value');
                  // TODO: como hacer mas prolijo ese is String?
                  if (value is String) {
                    if (value.isEmpty) {
                      return 'Field required';
                    } else {
                      return null;
                    }
                  }
                  return 'Field Required';
                },
                minLines: null,
                maxLines: 1,
                controller:
                    TextEditingController(text: _userNotifier.content()),
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.unspecified,

                // decoration: InputDecoration(
                //   filled: true,
                //   // fillColor: Colors.grey[900],
                //   border: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(30.0),
                //     borderSide: BorderSide.none,
                //   ),
                //   enabledBorder: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(30.0),
                //     borderSide: BorderSide.none,
                //   ),
                //   focusedBorder: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(30.0),
                //     borderSide: BorderSide.none,
                //   ),
                //   contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                //   // border: state == VozMessageState.editing
                //   // ? const OutlineInputBorder()
                //   // : InputBorder.none,
                //   // labelText: 'Presiona para grabar mensaje',
                //   labelStyle: const TextStyle(
                //       color: Colors.white70,
                //       fontStyle: FontStyle.normal,
                //       fontSize: 36),
                // ),
                style: const TextStyle(
                  fontSize: 36.0,
                  color: Colors.white70,
                ),
                onFieldSubmitted: (value) {
                  debugPrint(
                      '>> on-field-sbt: ${_messageFormKey.currentContext?.size}');
                  var sk = SnackBar(content: Text('Hello: $value'));
                  ScaffoldMessenger.of(context).showSnackBar(sk);
                },
                onSaved: (value) {
                  debugPrint('>> on-saved-value: $value');
                  if (value == null) return;

                  _userNotifier.updateContent(value);

                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (ctx) => LolaMessageScreen(
                      // TODO: input lola stream
                      text: _userNotifier.content(),
                      scale: 1.0,
                    ),
                  );
                },
                onTapOutside: (event) {
                  debugPrint('>> ev: $event');
                  FocusManager.instance.primaryFocus?.unfocus();
                }),
          );
        });
  }
}
