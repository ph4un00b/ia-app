import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/Lola/lola_controller.dart';
import 'package:lola_ai_app/features/Voz/voz_controller.dart';
import 'package:lola_ai_app/screens/voz/lola_message/lola_message_screen.dart';

// import 'package:keyboard_actions/keyboard_actions.dart';
// import 'package:keyboard_actions/keyboard_actions_config.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
        actions: [
          GestureDetector(
            onTap: () => _showFormatTypographyBottomSheet(context),
            child: const Icon(Icons.text_fields),
          )
        ],
      ),
      body: const VoiceBody(),
    );
  }

  void _showFormatTypographyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      barrierColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {},
                  child: const Icon(Icons.text_decrease, size: 16),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {},
                  child: const Icon(Icons.text_increase, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: FilledButton.tonal(
                  onPressed: () {},
                  child: const Icon(Icons.format_clear, size: 22),
                ),
              ),
            ],
          ),
        );
      },
    );
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
  final _lola = LolaController();
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
    return SafeArea(
        child: Column(children: [
      // child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      const Expanded(
        child: SingleChildScrollView(
          child: true
              ? Icon(
                  Icons.multitrack_audio,
                  size: 72,
                )
              : Text("lorem"),
        ),
      ),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Row(children: [
            Flexible(
              // TODO: que es mejor un listener con varios componentes ó varios listener con un componente?
              child: ListenableBuilder(
                  listenable: _userNotifier,
                  builder: (_ctx, __) {
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
                          maxLines: 4,
                          controller: TextEditingController(
                              text: _userNotifier.content()),
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.unspecified,
                          decoration: InputDecoration(
                            // filled: !true,
                            // isDense: !true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none),
                            // border: state == VozMessageState.editing
                            // ? const OutlineInputBorder()
                            // : InputBorder.none,
                            // labelText: 'Presiona para grabar mensaje',
                            labelStyle: const TextStyle(
                                color: Colors.white70,
                                fontStyle: FontStyle.normal,
                                fontSize: 36),
                          ),
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
                  }),
            ),
            const SizedBox(width: 12),
            Container(
                // TODO: probar LayoutBuilder para obtener dinamicamente el heigth?
                height: 200,
                // height: _messageFormKey.currentContext?.size?.height,
                color: Colors.greenAccent[700],
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ListenableBuilder(
                          listenable: _userNotifier,
                          builder: (_, __) {
                            return _userNotifier.currentStatus ==
                                    RecordState.recording
                                ? IconButton(
                                    color: Colors.redAccent,
                                    onPressed: _handleUserRecording,
                                    icon: const Icon(Icons.mic))
                                : IconButton.filledTonal(
                                    color: Colors.white70,
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
                          onPressed: () {
                            // TODO: probar bien el reset!
                            debugPrint(_messageFormKey.currentState.toString());
                            _messageFormKey.currentState?.reset();
                          },
                          icon: const Icon(Icons.delete_forever)),
                      IconButton.filledTonal(
                          color: Colors.white70,
                          onPressed: () {
                            debugPrint('preguntando a lola!');
                            var isValid =
                                _messageFormKey.currentState?.validate();

                            if (isValid == null) return;
                            if (isValid) {
                              _messageFormKey.currentState?.save();
                              // _messageFormKey.currentState?.reset();
                            }
                          },
                          icon: const Icon(Icons.send_outlined)),
                    ]))
          ]))
    ]));
  }

  void _handleUserRecording() async {
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
}
