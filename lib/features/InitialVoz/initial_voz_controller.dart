import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:path/path.dart' as p;
import 'package:lola_ai_app/features/Agents/reminder_agent.dart';
import 'package:lola_ai_app/features/Lola/queries/summary.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/main.dart';
import 'package:lola_ai_app/services/ReminderAgent/reminder_onboarding_handler.dart';
import 'package:path_provider/path_provider.dart';

extension StreamControllerX<TEvent> on StreamController<TEvent> {
  void addIfStreamOpen(TEvent event) {
    if (!isClosed) add(event);
  }
}

final class InitialVozController with AudioPlayerHandlers {
  bool _httpToken = false;
  final audio.AudioPlayer _audioplayer = audio.AudioPlayer();
  final serviceState = StreamController<LolaServiceState>()
    ..add(const IdleService());
  final audioState = StreamController<AudioState>()..add(NoAudioPath());
  VoiceLola currentVoice = VoiceLola.nova;
  String _currentOutput = '';
  String _currentAudioPath = '';

  InitialVozController() {
    _audioplayer.playbackEventStream.listen((event) {
      debugPrint('== INITIAL PLAYER >> ${event.processingState}');

      final newState = switch (event.processingState) {
        audio.ProcessingState.completed => PlayingAudioOk(),
        audio.ProcessingState.idle ||
        audio.ProcessingState.ready ||
        audio.ProcessingState.loading ||
        audio.ProcessingState.buffering =>
          NoAudioPath(),
      };

      if (event.processingState == audio.ProcessingState.completed) {
        debugPrint('play INITIAL completed!');
        audioState.addIfStreamOpen(newState);
      }
    }, onError: (error, stackTrace) {
      debugPrint('>>>> play INITIAL error: $error\n$stackTrace');
      audioState.add(PlayingAudioErr());
    });
  }
  // en debug:
  // se muestra el error en pad y en
  // la vista de "Ver Mensaje"
  Future<void> loadInitialSummary({bool debug = false}) async {
    AppStatus.instance.currentInitialState = InitialState.loadingSummary;
    if (debug) serviceState.add(const IdleService(payload: 'loading summary'));

    try {
      serviceState.add(Loading());
      final result = await LolaSummary.query(voice: currentVoice, debug: debug);
      _currentAudioPath = result.path;
      _currentOutput = result.reply;
      serviceState.add(Data(payload: result.reply));
      await _playAudio(result.path);
    } catch (e, st) {
      if (_httpToken) {
        debugPrint('😡 Summary request was cancelled');
        return;
      }

      if (debug) {
        serviceState.add(Error(payload: e.toString()));
      } else {
        serviceState.add(Data(payload: _currentOutput));
      }
      debugPrint('loadShortMemory: error: $e, $st');
    }
  }

  Future<void> loadReminders({required bool debug}) async {
    AppStatus.instance.currentInitialState = InitialState.loadingReminders;
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
      if (_httpToken) {
        debugPrint('😡 reminders request was cancelled');
        return;
      }

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
      debugPrint("stopSpeech: error: $e, $st");
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
      debugPrint("playSpeech: error: $e, $st");
      audioState.add(PlayingAudioErr());
    }
  }

  void dispose() {
    _httpToken = true;
    _audioplayer.dispose();
    audioState.close();
    serviceState.close();
  }
}
