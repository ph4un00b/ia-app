import 'dart:async';
import 'package:flutter/material.dart';
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
  double screenScale = Constants.scale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const MessagesTitle(),

        flexibleSpace: SafeArea(
            child: Container(
                padding: const EdgeInsets.only(right: 66, left: 40),
                child: Row(children: [
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 8,
                    child: MessagesTitle()
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
                                                'screen-messages',
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
                                                'screen-messages',
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
                              backgroundColor: Colors.orangeAccent,
                              textColor: Colors.black87,
                              child: const Icon(Icons.text_fields))))
                ]))),
      ),
      body: Container(
        padding: const EdgeInsets.all(18),
        child: MessageChildren(controller: controller, scale: screenScale),
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
      'Mensajes',
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
    required this.controller, required double scale,
  }): _scale = scale;

  final double _scale;

  @override
  State<MessageChildren> createState() => _MessageChildrenState();
}

class _MessageChildrenState extends State<MessageChildren> {
  Stream<MessagesScreenState>? screenState;

  @override
  void initState() {
    super.initState();
    screenState = widget.controller.messagesState.stream;
    widget.controller.loadInitialMessages();
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
          child: MessagesSearch(controller: widget.controller, scale: widget._scale),
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
                    scale: widget._scale,
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
