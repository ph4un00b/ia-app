import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/queries/response.dart';
import 'package:lola_ai_app/features/Lola/queries/summary.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Mensajes/mutations/save_conversation.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:just_audio/just_audio.dart' as audio;

final class LolaController with QueryContent {
  final audio.AudioPlayer _audioplayer = audio.AudioPlayer();
  final serviceState = StreamController<LolaServiceState>()
    ..add(const IdleService());
  final audioState = StreamController<LolaAudioState$>()..add(NonePath());
  VoiceLola currentVoice = VoiceLola.nova;
  String _currentOutput = '';
  String _currentAudioPath = '';

  LolaController() {
    _audioplayer.playbackEventStream.listen((event) {
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
    return _currentOutput;
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
      final result = await LolaSummary.query(voice: currentVoice, debug: debug);
      _currentAudioPath = result.path;
      _currentOutput = result.reply;
      serviceState.add(Data(payload: result.reply));
      await _playAudio(result.path);
    } catch (e) {
      if (debug) {
        serviceState.add(Error(payload: e.toString()));
      } else {
        serviceState.add(Data(payload: _currentOutput));
      }
      debugPrint('loadShortMemory: error: $e');
    }
  }

  Future<void> loadReply(
      {required String userQuestion, bool debug = false}) async {
    if (debug) serviceState.add(const IdleService(payload: 'loading response'));
    try {
      serviceState.add(Loading());

      final result = await LolaResponse.query(
        userQuery: userQuestion,
        voiceModel: currentVoice,
        debug: debug,
      );
      _currentAudioPath = result.path;
      _currentOutput = result.reply;

      serviceState.add(Data(payload: result.reply));
      await Conversation.save(
        user: userQuestion,
        lola: result.reply,
        audioPath: result.path,
      );
      await _playAudio(result.path);
    } catch (e) {
      if (debug) {
        serviceState.add(Error(payload: e.toString()));
      } else {
        serviceState.add(Data(payload: _currentOutput));
      }
      debugPrint('loadReply: error: $e');
    }
  }

  Future<void> _playAudio(String audioPath) async {
    debugPrint('play lola from path: $audioPath');
    // await _player.setAudioSource(audio.AudioSource.file(path));
    await _audioplayer.setFilePath(audioPath);
    audioState.add(PlayingAudio());
    await _audioplayer.play();
  }

  Future<void> stopSpeech() async {
    if (!_audioplayer.playing) {
      return;
    }

    try {
      await _audioplayer.stop();
      audioState.add(Stopped());
    } catch (e) {
      debugPrint(e.toString());
      audioState.add(StoppedErr());
    }
  }

  Future<void> playSpeech() async {
    try {
      audioState.add(PlayingAudio());
      await _audioplayer.setFilePath(_currentAudioPath);
      await _audioplayer.play();
    } catch (e) {
      debugPrint(e.toString());
      audioState.add(PlayingAudioErr());
    }
  }

  void dispose() {
    _audioplayer.dispose();
    audioState.close();
    serviceState.close();
  }
}
