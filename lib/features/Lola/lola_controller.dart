import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/queries/response.dart';
import 'package:lola_ai_app/features/Lola/queries/summary.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Mensajes/mutations/save_conversation.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:just_audio/just_audio.dart' as audio;

final class LolaController with QueryContent {
  final audio.AudioPlayer _player = audio.AudioPlayer();
  final serviceState = StreamController<LolaServiceState>()
    ..add(const IdleService());
  final audioState = StreamController<LolaAudioState$>()..add(NonePath());
  VoiceLola voice = VoiceLola.nova;
  String _output = '';
  String _path = '';

  LolaController() {
    _player.playbackEventStream.listen((event) {
      debugPrint('== LOLA PAYER >> ${event.processingState}');
      switch (event.processingState) {
        case audio.ProcessingState.idle:
          // debugPrint('>> $event');
          // _emit(SpeakingIdle(output: _output));
          break;
        case audio.ProcessingState.loading:
          // debugPrint('>> $event');
          break;
        case audio.ProcessingState.buffering:
          // debugPrint('>> $event');
          break;
        case audio.ProcessingState.ready:
          // debugPrint('>> $event');
          break;
        case audio.ProcessingState.completed:
          // debugPrint('>> $event');
          audioState.add(PlayingAudioOk());
          debugPrint('play lola completed!');
      }
    }, onError: (e, stack) {
      debugPrint('>>>> play lola error!');
      debugPrint(e.toString());
      debugPrint(stack.toString());
      audioState.add(PlayingAudioErr());
    });
  }

  @override
  String content() {
    return _output;
  }

  // no queremos que suban las exceptiones
  // por ahora, que no pase nada.
  // en debug:
  // se muestra el error en pad y en
  // la vista de "Ver Mensaje"
  Future<void> loadInitialSummary({bool debug = false}) async {
    if (debug) serviceState.add(const IdleService(payload: 'loading summary'));
    try {
      serviceState.add(Loading());
      final result = await LolaSummary.query(voice: voice, debug: debug);
      _path = result.path;
      _output = result.reply;
      serviceState.add(Data(payload: result.reply));
      await _playAudio(result.path);
    } catch (e) {
      if (debug) {
        serviceState.add(Error(payload: e.toString()));
      } else {
        serviceState.add(Data(payload: _output));
      }
      debugPrint('loadShortMemory: error: $e');
    }
  }

  loadReply({required String question, bool debug = false}) async {
    if (debug) serviceState.add(const IdleService(payload: 'loading response'));
    try {
      serviceState.add(Loading());
      final result = await LolaResponse.query(
        question: question,
        voice: voice,
        debug: debug,
      );
      _path = result.path;
      _output = result.reply;

      serviceState.add(Data(payload: result.reply));
      await Conversation.save(
        user: question,
        lola: result.reply,
        audioPath: result.path,
      );
      await _playAudio(result.path);
    } catch (e) {
      if (debug) {
        serviceState.add(Error(payload: e.toString()));
      } else {
        serviceState.add(Data(payload: _output));
      }
      debugPrint('loadReply: error: $e');
    }
  }

  Future<void> _playAudio(String path) async {
    debugPrint('play lola from path: $path');
    // await _player.setAudioSource(audio.AudioSource.file(path));
    await _player.setFilePath(path);
    audioState.add(PlayingAudio());
    await _player.play();
  }

  Future<void> stopSpeech() async {
    if (!_player.playing) {
      return;
    }

    try {
      await _player.stop();
      audioState.add(Stopped());
    } catch (e) {
      debugPrint(e.toString());
      audioState.add(StoppedErr());
    }
  }

  Future<void> playSpeech() async {
    try {
      audioState.add(PlayingAudio());
      await _player.setFilePath(_path);
      await _player.play();
    } catch (e) {
      debugPrint(e.toString());
      audioState.add(PlayingAudioErr());
    }
  }

  void dispose() {
    _player.dispose();
    audioState.close();
    serviceState.close();
  }
}
