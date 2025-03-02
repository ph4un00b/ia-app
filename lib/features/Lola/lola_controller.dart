import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/Lola/queries/response.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Mensajes/mutations/save_conversation.dart';
import 'package:lola_ai_app/features/core/logger.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:supabase_flutter/supabase_flutter.dart';

final class LolaController with QueryContent, AudioPlayerHandlers {
  final audio.AudioPlayer _audioplayer = audio.AudioPlayer();
  final serviceState = StreamController<LolaServiceState>()
    ..add(const IdleService());
  final audioState = StreamController<AudioState>()..add(NoAudioPath());
  VoiceLola currentVoice = VoiceLola.nova;
  String _currentOutput = '';
  String _currentAudioPath = '';

  LolaController() {
    _audioplayer.playbackEventStream.listen((event) {
      debugPrint('== LOLA PLAYER >> ${event.processingState}');

      final newState = switch (event.processingState) {
        audio.ProcessingState.idle => NoAudioPath(),
        audio.ProcessingState.loading => NoAudioPath(),
        audio.ProcessingState.buffering => NoAudioPath(),
        audio.ProcessingState.ready => NoAudioPath(),
        audio.ProcessingState.completed => PlayingAudioOk(),
      };

      if (event.processingState == audio.ProcessingState.completed) {
        debugPrint('play lola completed!');
        audioState.add(newState);
      }
    }, onError: (error, stackTrace) {
      debugPrint('>>>> play lola error!');
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      audioState.add(PlayingAudioErr());
    });
  }

  @override
  String content() {
    return _currentOutput;
  }

  Future<void> queryReply({
    required String userQuestion,
    bool debug = false,
  }) async {
    if (debug) serviceState.add(const IdleService(payload: Payload(reply: 'loading response')));
    try {
      serviceState.add(Loading(payload: Payload(userQuestion: userQuestion, reply: "...")));

      final result = await LolaResponse.query(
        userQuery: userQuestion,
        voiceModel: currentVoice,
        debug: debug,
      );
      _currentAudioPath = result.path;
      _currentOutput = result.reply;

      serviceState.add(Data(
          payload: Payload(userQuestion: userQuestion, reply: result.reply)));

      await Conversation.save(
        user: userQuestion,
        lola: result.reply,
        audioPath: result.path,
      );
      await _playAudio(result.path);
    } on PostgrestException catch (e) {
      //! manejamos el error de PostgrestException de Supabase por que
      //! se pierde el stacktrace de la excepcion en el logger
      if (debug) {
        serviceState.add(Error(
            payload: Payload(userQuestion: userQuestion, reply: e.toString())));
      } else {
        serviceState.add(Data(
            payload:
                Payload(userQuestion: userQuestion, reply: _currentOutput)));
      }

      debugPrint('Error occurred: ${e.toJson().toString()}');
      ErrorLogger.logException(e, StackTrace.current);
    } on TimeoutException catch (e) {
      ErrorLogger.logException(e, StackTrace.current);

      if (debug) {
        serviceState.add(Error(
            payload: Payload(userQuestion: userQuestion, reply: e.toString())));
      } else {
        serviceState.add(Data(
            payload:
                Payload(userQuestion: userQuestion, reply: _currentOutput)));
      }
    } catch (e, st) {
      ErrorLogger.logException(e, st);

      if (debug) {
        serviceState.add(Error(
            payload: Payload(userQuestion: userQuestion, reply: e.toString())));
      } else {
        serviceState.add(Data(
            payload:
                Payload(userQuestion: userQuestion, reply: _currentOutput)));
      }
    }
  }

  Future<void> _playAudio(String audioPath) async {
    debugPrint('play lola from path: $audioPath');
    // await _player.setAudioSource(audio.AudioSource.file(path));
    await _audioplayer.setFilePath(audioPath);
    audioState.add(PlayingAudio());
    await _audioplayer.play();
  }

  @override
  Future<void> stopAudio() async {
    if (!_audioplayer.playing) {
      return;
    }

    try {
      await _audioplayer.stop();
      audioState.add(Stopped());
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      audioState.add(StoppedErr());
    }
  }

  @override
  Future<void> playAudio() async {
    try {
      audioState.add(PlayingAudio());
      await _audioplayer.setFilePath(_currentAudioPath);
      await _audioplayer.play();
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      audioState.add(PlayingAudioErr());
    }
  }

  void dispose() {
    _audioplayer.dispose();
    audioState.close();
    serviceState.close();
  }
}
