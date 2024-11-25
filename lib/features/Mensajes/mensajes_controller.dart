import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/App/status.dart';
import 'package:lola_ai_app/features/Mensajes/types.dart';
import 'package:lola_ai_app/features/core/logger.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_audio/just_audio.dart' as audio;

sealed class MessagesScreenState {}

final class Initial implements MessagesScreenState {}

final class Fetching implements MessagesScreenState {}

final class Success implements MessagesScreenState {
  List<SingleMessage> messages;
  String text;
  Success({required this.text, required this.messages});
}

final class Error implements MessagesScreenState {
  final dynamic err;
  Error({required this.err});
}

final class MessagesController {
  final _player = audio.AudioPlayer();
  final messagesState = StreamController<MessagesScreenState>()..add(Initial());

  Future<void> loadInitialMessages() async {
    messagesState.add(Fetching());

    try {
      List<Map<String, dynamic>> result = await Supabase.instance.client
          .from('conversation')
          .select()
          .eq('user_id', AppStatus.instance.userId)
          .order('created_at', ascending: false);

      messagesState
          .add(Success(text: 'Success', messages: _messagesFrom(result)));

      unawaited(
          AppEvent.messagesDisplayed.track(params: {"count": result.length}));
    } on PostgrestException catch (e) {
      //! manejamos el error de PostgrestException de Supabase por que
      //! se pierde el stacktrace de la excepcion en el logger
      messagesState.add(Error(err: e.toString()));

      debugPrint('Error occurred: ${e.toJson().toString()}');
      ErrorLogger.logException(e, StackTrace.current);
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      messagesState.add(Error(err: e));
    }
  }

  Future<void> playSpeech({required String path}) async {
    File file = File(path);
    if (await file.exists()) {
      _player.setFilePath(path);
      _player.play();
    } else {
      throw StateError('audio file not found: $path');
    }
  }

  List<SingleMessage> _messagesFrom(
    List<Map<String, dynamic>> data,
  ) {
    return List<SingleMessage>.generate(data.length, (i) {
      final msg = data[i];
      final title = msg['title'];
      final content = msg['content'];
      final from = msg['system'];
      final String? path = msg['path'];
      // TODO(app.messages): manage timezones.
      final createdAt = DateTime.parse(msg['created_at']);
      return SingleMessage(title, content, from, path, createdAt);
    });
  }

  void search(String query) async {
    unawaited(AppEvent.searchMessageUsed.track());
    messagesState.add(Fetching());

    if (query.isEmpty) {
      await loadInitialMessages();
      return;
    }

    try {
      List<Map<String, dynamic>> result = await Supabase.instance.client
          .from("conversation")
          .select()
          .eq('user_id', AppStatus.instance.userId)
          // TODO(app.message): find out an strategy for accents.
          // .textSearch("content", "'eggs' & 'ham'", config: "english");
          .textSearch(
            "content",
            query,
            config: "english",
            type: TextSearchType.websearch,
          )
          .order('created_at', ascending: false);

      messagesState
          .add(Success(text: 'Success', messages: _messagesFrom(result)));
    } on PostgrestException catch (e) {
      //! manejamos el error de PostgrestException de Supabase por que
      //! se pierde el stacktrace de la excepcion en el logger
      messagesState.add(Error(err: e.toString()));

      debugPrint('Error occurred: ${e.toJson().toString()}');
      ErrorLogger.logException(e, StackTrace.current);
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      messagesState.add(Error(err: e));
    }
  }

  void dispose() {
    _player.dispose();
    messagesState.close();
  }
}
