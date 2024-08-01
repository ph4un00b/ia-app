import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/screens/opciones/messages/messages_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_audio/just_audio.dart' as audio;

sealed class MessagesScreenState {}

final class Initial implements MessagesScreenState {}

final class Fetching implements MessagesScreenState {}

final class Success implements MessagesScreenState {
  List<SingleMessage<String, String, String>> messages;
  String text;
  Success({required this.text, required this.messages});
}

final class Error implements MessagesScreenState {
  final dynamic err;
  Error({required this.err});
}

final class MessagesController {
  final audio.AudioPlayer _player = audio.AudioPlayer();
  final messagesState = StreamController<MessagesScreenState>()..add(Initial());

  // Future<PostgrestTransformBuilder<List<Map<String, dynamic>>>> loadData() async {
  void loadInitialMessages() async {
    messagesState.add(Fetching());
    await Future<void>.delayed(
        const Duration(seconds: 2)); // Fake 1 second delay

    try {
      List<Map<String, dynamic>> result = await Supabase.instance.client
          .from('countries')
          .select()
          .order('created_at', ascending: false);

      messagesState
          .add(Success(text: 'Success', messages: _messagesFrom(result)));
    } catch (e) {
      messagesState.add(Error(err: e));
    }
  }

  Future<void> playSpeech({required String path}) async {
    debugPrint('play lola: $path');
    _player.setFilePath(path);
    _player.play();
  }

  List<SingleMessage<String, String, String>> _messagesFrom(
    List<Map<String, dynamic>> data,
  ) {
    return List<SingleMessage<String, String, String>>.generate(data.length,
        (i) {
      final country = data[i];
      final title = country['title'];
      final content = country['content'];
      final from = country['system'];
      final String? path = country['path'];
      // TODO(app.messages): manage timezones.
      final createdAt = DateTime.parse(country['created_at']);
      return SingleMessage(title, content, from, path, createdAt);
    });
  }

  void search(String query) async {
    messagesState.add(Fetching());
    try {
      List<Map<String, dynamic>> result = await Supabase.instance.client
          .from("countries")
          .select()
          // TODO(app.message): find an strategy for accents.
          // .textSearch("content", "'eggs' & 'ham'", config: "english");
          .textSearch(
            "content",
            query,
            config: "english",
            type: TextSearchType.websearch,
          )
          .order('created_at', ascending: false);

      // print(result.toString());
      if (query.isEmpty) {
        loadInitialMessages();
      } else {
        messagesState
            .add(Success(text: 'Success', messages: _messagesFrom(result)));
      }
    } catch (e) {
      messagesState.add(Error(err: e));
    }
  }

  void dispose() {
    messagesState.close();
  }
}

class _FakeAPI {
  static const List<String> _kOptions = <String>[
    'aardvark  sda sad as dsa dasdsdsada ds d a flutter: **** onAuthStateChange: AuthChangeEvent.initialSession',
    'bobcat 3422  fds f ds fsd f fdf dsfdsfdsfd Restarted application in 559ms.',
    'chameleon 32 2 r 23 32  f  sd fd f d sf fds ffdsfds flutter: RouteSettings("/voz", null)',
  ];

  // Searches the options, but injects a fake "network" delay.
  static Future<Iterable<String>> search(String query) async {
    await Future<void>.delayed(
        const Duration(seconds: 1)); // Fake 1 second delay.
    if (query == '') {
      return const Iterable<String>.empty();
    }
    return _kOptions.where((String option) {
      return option.contains(query.toLowerCase());
    });
  }
}
