import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Agents/reminder_agent.dart';
import 'package:lola_ai_app/features/Lola/queries/response.dart';
import 'package:lola_ai_app/features/Lola/queries/summary.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Mensajes/mutations/save_conversation.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:lola_ai_app/main.dart';
import 'package:lola_ai_app/services/ReminderAgent/reminder_onboarding_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
      debugPrint('== LOLA PLAYER >> ${event.processingState}');

      final newState = switch (event.processingState) {
        audio.ProcessingState.idle => NonePath(),
        audio.ProcessingState.loading => NonePath(),
        audio.ProcessingState.buffering => NonePath(),
        audio.ProcessingState.ready => NonePath(),
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
    } catch (e, st) {
      if (debug) {
        serviceState.add(Error(payload: e.toString()));
      } else {
        serviceState.add(Data(payload: _currentOutput));
      }
      debugPrint('loadShortMemory: error: $e, $st');
    }
  }

  Future<void> loadReply({
    required String userQuestion,
    bool debug = false,
  }) async {
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
    } catch (e, st) {
      if (debug) {
        serviceState.add(Error(payload: e.toString()));
      } else {
        serviceState.add(Data(payload: _currentOutput));
      }
      debugPrint('loadReply: error: $e, $st');
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
    } catch (e, st) {
      debugPrint("stopSpeech: error: $e, $st");
      audioState.add(StoppedErr());
    }
  }

  Future<void> playSpeech() async {
    try {
      audioState.add(PlayingAudio());
      await _audioplayer.setFilePath(_currentAudioPath);
      await _audioplayer.play();
    } catch (e, st) {
      debugPrint("playSpeech: error: $e, $st");
      audioState.add(PlayingAudioErr());
    }
  }

  void dispose() {
    _audioplayer.dispose();
    audioState.close();
    serviceState.close();
  }

  Future<void> loadReminders({required bool debug}) async {
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final remindersFile = File('${appDocumentsDirectory.path}/jamon.md');

    // TODO: verificar que exista al menos un recortatorio
    // y no solo que exista el archvito
    AppStatus.instance.currentStatus =
        remindersFile.existsSync() ? AppState.active : AppState.onboarding;

    if (AppStatus.instance.currentStatus case AppState.active) {
      await _handleExistingReminders(debug);
    } else {
      await _handleFirstTimeReminders(debug);
    }
  }

  Future<void> _handleExistingReminders(bool debug) async {
    if (debug) {
      serviceState.add(const IdleService(payload: 'loading reminders'));
    }

    try {
      serviceState.add(Loading());

      final now = DateTime.now();
      final today = now.toIso8601String().split('T').first;
      final dayName = const {
        1: 'Monday',
        2: 'Tuesday',
        3: 'Wednesday',
        4: 'Thursday',
        5: 'Friday',
        6: 'Saturday',
        7: 'Sunday',
      }[now.weekday];

      final reminderResponse = await ReminderAgent.query(
        'hoy es $dayName $today, cuales son mis recordatorios para hoy?',
      );

      if (reminderResponse.payload.isEmpty) {
        throw LolaResponseException('Empty response from ReminderAgent');
      }

      await _processAndPlayResponse(reminderResponse.payload);
    } catch (e, st) {
      if (debug) {
        serviceState.add(Error(payload: e.toString()));
      } else {
        serviceState.add(Data(payload: _currentOutput));
      }
      debugPrint('loadReminders: error: $e, $st');
    }
  }

  Future<void> _handleFirstTimeReminders(bool debug) async {
    if (debug) {
      serviceState.add(const IdleService(payload: 'creating first reminders'));
    }

    try {
      final onboardingResponse = await ReminderOnboardingHandler.query('hola');

      if (onboardingResponse.payload.isEmpty) {
        throw LolaResponseException(
            'Empty response from ReminderOnboardingHandler');
      }

      await _processAndPlayResponse(onboardingResponse.payload);
    } catch (e, st) {
      if (debug) {
        serviceState.add(Error(payload: e.toString()));
      } else {
        serviceState.add(Data(payload: _currentOutput));
      }
      debugPrint('create reminders: error: $e, $st');
    }
  }

  Future<void> _processAndPlayResponse(String payload) async {
    final speechFile = await currentVoice.synthesize(text: payload);
    final path = p.normalize(speechFile.path);

    final result = LolaResult(path, payload);

    _currentAudioPath = result.path;
    _currentOutput = result.reply;
    serviceState.add(Data(payload: result.reply));
    await _playAudio(result.path);
  }
}
