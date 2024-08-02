import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/App/components/setting_text.dart';
import 'package:lola_ai_app/features/Mensajes/components/messages_list.dart';
import 'package:lola_ai_app/features/Mensajes/components/messages_search.dart';
import 'package:lola_ai_app/features/Mensajes/mensajes_controller.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagesScreen extends StatefulWidget {
  final List<String> items;
  const MessagesScreen({super.key, required this.items});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final controller = MessagesController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MessagesTitle(),
      ),
      body: Container(
        padding: const EdgeInsets.all(18),
        child: MessageChildren(controller: controller),
      ),
    );
  }
}

class MessagesTitle extends StatelessWidget {
  const MessagesTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Mensajes - Sr. Luis',
      style: GoogleFonts.satisfy(
        textStyle: Theme.of(context).textTheme.displayLarge,
        fontSize: 28,
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ),
    );
  }
}

class MessageChildren extends StatefulWidget {
  final MessagesController controller;

  const MessageChildren({
    super.key,
    required this.controller,
  });

  @override
  State<MessageChildren> createState() => _MessageChildrenState();
}

class _MessageChildrenState extends State<MessageChildren> {
  Stream<MessagesScreenState>? screenState;
  var scale = Constants.scale;

  @override
  void initState() {
    super.initState();
    _loadUserPrefereces();
    screenState = widget.controller.messagesState.stream;
    widget.controller.loadInitialMessages();
  }

  Future<void> _loadUserPrefereces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      scale = prefs.getDouble('app-setting-messages') ?? Constants.scale;
    });
  }

  @override
  void dispose() {
    debugPrint('disposing messages screen');
    super.dispose();
    widget.controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: SettingAppText(
            scale: scale,
            onChangedValue: (value) async {
              setState(() => scale = value);
              final prefs = await SharedPreferences.getInstance();
              prefs.setDouble(
                'app-setting-messages',
                value,
              );
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: MessagesSearch(controller: widget.controller, scale: scale),
        ),
        const SizedBox(height: 18),
        // Expanded(
        //   flex: 1,
        //   child: MessagesCalendar(),
        // ),
        // const SizedBox(height: 18),
        Expanded(
          flex: 8,
          child: StreamBuilder(
            stream: screenState,
            builder: (_, snap) {
              final state = snap.data;
              return switch (state) {
                null => Container(),
                Initial() => Container(),
                Fetching() => const Center(child: CircularProgressIndicator()),
                Success() => MessagesList(
                    controller: widget.controller,
                    items: state.messages,
                    scale: scale,
                  ),
                Error() => Center(child: Text(state.err.toString())),
              };
            },
          ),
        ),
      ],
    );
  }
}
