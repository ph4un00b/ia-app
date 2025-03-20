import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:lola_ai_app/features/AudioPlayer/components/audio_handler.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/Lola/lola_controller.dart';
import 'package:lola_ai_app/features/Voz/voz_controller.dart';

class InputMessageForm extends StatelessWidget {
  const InputMessageForm({
    super.key,
    required VozController userNotifier,
    required GlobalKey<FormState> messageFormKey,
    required LolaController lolaController,
    required Stream<AudioState>? lolaStream,
    required double scale,
    required TextEditingController queryController,
    // TODO: preguntar sobre este patron de init
  })  : _userNotifier = userNotifier,
        _lolaController = lolaController,
        _lolaStream = lolaStream,
        _messageFormKey = messageFormKey,
        _queryController = queryController,
        _scale = scale;

  final VozController _userNotifier;
  final GlobalKey<FormState> _messageFormKey;
  final TextEditingController _queryController;
  final LolaController _lolaController;
  final Stream<AudioState>? _lolaStream;
  final double _scale;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomLeft,
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                color: Colors.grey.shade900.withAlpha(225)),
            padding: const EdgeInsets.only(left: 0, bottom: 0, top: 0),
            // color: Colors.black45,
            // color: Colors.transparent,
            height: Constants.inputHeight,
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ListenableBuilder(
                        listenable: _userNotifier,
                        builder: (_, __) => Form(
                          key: _messageFormKey,
                          child: TextFormField(
                            controller: _queryController,
                            // key: _queryFieldKey,
                            initialValue: null,
                            style: TextStyle(fontSize: 16.0 * _scale),
                            maxLength: 2048,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            // expands: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.unspecified,
                            decoration: InputDecoration(
                              counterText: "",
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  debugPrint(_messageFormKey.currentState.toString());
                                  _messageFormKey.currentState?.reset();
                                  _userNotifier.updateContent("");
                                },
                                child: Icon(Icons.delete_forever, color: Colors.white70, size: 24 * _scale),
                              ),
                              // fillColor: Colors.grey[900],
                              filled: true,
                              fillColor: Colors.grey.shade900.withAlpha(0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40.0), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40.0), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40.0), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              hintText: "Escribe a Lola",
                              hintStyle: TextStyle(color: Colors.white54, fontSize: 16 * _scale),
                            ),
                            onFieldSubmitted: (value) {
                              debugPrint('>> on-field-sbt: ${_messageFormKey.currentContext?.size}');
                              var sk = SnackBar(content: Text('Hello: $value'));
                              ScaffoldMessenger.of(context).showSnackBar(sk);
                            },
                            onSaved: (value) {
                              debugPrint('>> on-saved-value: $value');
                              if (value == null) return;

                              _userNotifier.updateContent(value);
                            },
                            onTapOutside: (event) {
                              debugPrint('>> unfocusing: $event');
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const SizedBox(height: 10),
                            LolaAudioHandler(
                              stream: _lolaStream,
                              lolaController: _lolaController,
                              scale: _scale.clamp(0.5, 1.10),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // const SizedBox(height: 10),
                            RecordingAction(
                              userNotifier: _userNotifier,
                              messageFormKey: _messageFormKey,
                              lolaController: _lolaController,
                              scale: _scale.clamp(0.5, 1.50),
                            ),
                            const SizedBox(width: 10),
                            SendAction(
                              userNotifier: _userNotifier,
                              messageFormKey: _messageFormKey,
                              lolaController: _lolaController,
                              scale: _scale.clamp(0.5, 1.50),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        // const SizedBox(height: 10),
                      ],
                    ),
                    const SizedBox(height: 2),
                  ],
                ))
              ],
            )));
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
                _lolaController.stopAudio();
                _messageFormKey.currentState?.save();

                // TODO: check how not awaiting affects errors
                // we are not awaiting in order to clear out the text-field asap
                _lolaController.queryReply(userQuestion: _userNotifier.content(), debug: !true);
                _messageFormKey.currentState?.reset();
                _userNotifier.updateContent("");
              },
              child: Ink(
                height: 40 * _scale,
                width: 40 * _scale,
                decoration: BoxDecoration(
                  // color: Colors.lightBlue,
                  color: Colors.deepPurple.shade700,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.arrow_upward_outlined,
                  color: Colors.white70,
                  size: 22 * _scale,
                ),
              ),
            ),
          );
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
          return Material(
            elevation: 0,
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTapDown: (details) async {
                // print('tapDown');
                await _lolaController.stopAudio();
                await _userNotifier.startRecording();
                // await _handleUserRecording();
              },
              onTapUp: (details) async {
                // print('onTapUp');
                // await _handleUserRecording();
                await _userNotifier.stopRecordingAndTranscribe();
                _lolaController.queryReply(userQuestion: _userNotifier.content(), debug: !true);

                _messageFormKey.currentState?.reset();
                _userNotifier.updateContent("");
              },
              onTapCancel: () async {
                // print('cancel');
                await _userNotifier.stopRecording();
              },
              child: Ink(
                height: 40 * _scale,
                width: 40 * _scale,
                decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(30)),
                child: Icon(Icons.mic, color: Colors.white70, size: 24 * _scale),
              ),
            ),
          );
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
      await _userNotifier.stopRecordingAndTranscribe();
      await _lolaController.queryReply(userQuestion: _userNotifier.content(), debug: true);
    } else if (_userNotifier.currentStatus case _) {
      debugPrint('noop');
    }
  }
}
