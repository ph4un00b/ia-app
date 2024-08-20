import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/lola_controller.dart';
import 'package:lola_ai_app/features/Voz/voz.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserMessageScreen extends StatefulWidget {
  const UserMessageScreen({
    super.key,
    required this.scale,
    required this.controller,
    required this.parentContext,
    required this.lolaController,
  });

  final double scale;
  final BuildContext parentContext;
  final ContentHandler controller;
  final LolaController lolaController;

  @override
  State<UserMessageScreen> createState() => _UserMessageScreenState();
}

class _UserMessageScreenState extends State<UserMessageScreen> {
  bool debug = !true;
  double screenScale = 1.0;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  VozMessageState state = VozMessageState.loaded;
  final messageController = TextEditingController(text: '');

  @override
  initState() {
    super.initState();
    _loadUserPrefereces();
    messageController.text = widget.controller.content();
  }

  Future<void> _loadUserPrefereces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      screenScale =
          prefs.getDouble('app-setting-full-message-text') ?? widget.scale;
    });
  }

  @override
  Widget build(BuildContext _) {
    return StatefulBuilder(builder: (_, setState) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Slider(
                value: screenScale,
                // value: 1.0,
                min: 0.5,
                max: 3.0,
                // divisions: 5,
                label: screenScale.toString(),
                onChanged: (double value) async {
                  setState(() => screenScale = value);
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setDouble(
                    'app-setting-full-message-text',
                    value,
                  );
                },
              ),
              Text(
                "Message",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0 * screenScale,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: switch (state) {
                    VozMessageState.empty => Container(),
                    VozMessageState.loaded => MessageForm(
                        formkey: formkey,
                        message: messageController,
                        screenScale: screenScale,
                      ),
                    VozMessageState.editing => MessageEditingForm(
                        formkey: formkey,
                        controller: widget.controller,
                        message: messageController,
                        screenScale: screenScale,
                        onSaved: () async => {
                          // TODO: handle debug
                          await widget.lolaController.loadReply(
                            question: widget.controller.content(),
                            debug: false,
                          )
                        },
                      ),
                    VozMessageState.edited => MessageForm(
                        formkey: formkey,
                        message: messageController,
                        screenScale: screenScale,
                      ),
                  },
                ),
              ),
              if (debug) const SizedBox(height: 40),
              if (debug) _debugMessageState(),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    // foregroundColor: Color.
                  ),
                  onPressed: () {
                    Navigator.pop(widget.parentContext);
                  },
                  child: Text(
                    'Cerrar',
                    textScaler: TextScaler.linear(1.4 * screenScale),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                      // backgroundColor: Colors.deepPurple,
                      // foregroundColor: Color.
                    ),
                  ),
                  onPressed: () {
                    return switch (state) {
                      VozMessageState.empty => setState(() {
                          state = VozMessageState.editing;
                        }),
                      VozMessageState.loaded => setState(() {
                          state = VozMessageState.editing;
                        }),
                      VozMessageState.edited => setState(() {
                          state = VozMessageState.edited;
                        }),
                      VozMessageState.editing => saveMessage(setState),
                    };
                  },
                  child: Text(
                    switch (state) {
                      VozMessageState.empty => 'Editar',
                      VozMessageState.loaded => 'Editar',
                      VozMessageState.editing => 'Guardar',
                      VozMessageState.edited => 'Editar',
                    },
                    textScaler: TextScaler.linear(1.4 * screenScale),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _debugMessageState() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          // foregroundColor: Color.
        ),
        onPressed: () {
          Navigator.pop(widget.parentContext);
        },
        child: Text(
          state.toString(),
          textScaler: TextScaler.linear(1 * screenScale),
        ),
      ),
    );
  }

  void saveMessage(StateSetter setState) {
    setState(() {
      state = VozMessageState.edited;
    });
    formkey.currentState?.save();
  }
}

final class MessageEditingForm extends StatelessWidget {
  const MessageEditingForm({
    super.key,
    required this.formkey,
    required this.message,
    required this.screenScale,
    required this.controller,
    required this.onSaved,
  });

  final GlobalKey<FormState> formkey;
  final TextEditingController message;
  final ContentHandler controller;
  final double screenScale;
  final Function onSaved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkey,
      child: TextFormField(
        enabled: true,
        minLines: 4,
        maxLines: 30,
        controller: message,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        style: TextStyle(fontSize: 36.0 * screenScale),
        onSaved: (value) {
          debugPrint('message-editing-form >> value: $value');
          // onMessageEdited(value);
          if (value != null) {
            controller.updateContent(value);
            onSaved();
          }
        },
      ),
    );
  }
}

class MessageForm extends StatelessWidget {
  const MessageForm({
    super.key,
    required this.formkey,
    required this.message,
    required this.screenScale,
  });

  final GlobalKey<FormState> formkey;
  final TextEditingController message;
  final double screenScale;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkey,
      child: TextFormField(
        enabled: false,
        minLines: 4,
        maxLines: 30,
        controller: message,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(border: InputBorder.none),
        style: TextStyle(
          fontSize: 36.0 * screenScale,
          color: Colors.white70,
        ),
        onSaved: (value) {
          debugPrint('edited >> value: $value');
          // onMessageEdited(value);
          // setState
          // _message = value ?? '';
        },
      ),
    );
  }
}
