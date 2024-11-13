import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/core/logger.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:path/path.dart' as p;
import 'package:lola_ai_app/features/Agents/reminder_agent.dart';
import 'package:lola_ai_app/features/Lola/queries/summary.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/main.dart';
import 'package:lola_ai_app/services/ReminderAgent/reminder_onboarding_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

extension ProcessingStateX on audio.ProcessingState {
  bool get isCompleted => this == audio.ProcessingState.completed;

  AudioState toAudioState() => switch (this) {
        audio.ProcessingState.completed => PlayingAudioOk(),
        audio.ProcessingState.idle ||
        audio.ProcessingState.ready ||
        audio.ProcessingState.loading ||
        audio.ProcessingState.buffering =>
          NoAudioPath(),
      };
}

extension StreamControllerX<TEvent> on StreamController<TEvent> {
  void addIfStreamOpen(TEvent event) {
    if (!isClosed) add(event);
  }
}

extension DateTimeX on DateTime {
  String get dayName => switch (weekday) {
        1 => 'Lunes',
        2 => 'Martes',
        3 => 'Miercoles',
        4 => 'Jueves',
        5 => 'Viernes',
        6 => 'Sabado',
        7 => 'Domingo',
        _ => throw ArgumentError('Invalid weekday: $weekday'),
      };
}

enum InitialState { idle, loadingReminders, loadingSummary }

final class InitialVozController with AudioPlayerHandlers {
  final _audioplayer = audio.AudioPlayer();
  final serviceState = StreamController<LolaServiceState>()
    ..add(const IdleService());
  final audioState = StreamController<AudioState>()..add(NoAudioPath());

  VoiceLola currentVoice = VoiceLola.nova;
  InitialState currentState = InitialState.idle;
  bool _isHttpCancelled = false;
  String _currentOutput = '';
  String _currentAudioPath = '';

  InitialVozController() {
    _audioplayer.playbackEventStream.listen((event) {
      if (event.processingState.isCompleted) {
        final appEvent = switch (currentState) {
          InitialState.loadingSummary => AppEvent.summaryFinished,
          InitialState.loadingReminders => AppEvent.remindersFinished,
          InitialState.idle => null,
        };

        if (appEvent != null) {
          unawaited(appEvent.track());
        }

        audioState.addIfStreamOpen(event.processingState.toAudioState());
      }
    }, onError: (e, st) {
      ErrorLogger.logException(e, st);
      audioState.add(PlayingAudioErr());
    });
  }

  Future<void> loadInitialSummary({bool debug = false}) async {
    currentState = InitialState.loadingSummary;

    if (debug) {
      serviceState.add(const IdleService(payload: 'loading summary'));
    } else {
      serviceState.add(Loading());
    }

    try {
      final result = await LolaSummary.query(voice: currentVoice, debug: debug);
      if (currentState != InitialState.loadingSummary) return;

      unawaited(AppEvent.summaryFetched.track());

      _currentAudioPath = result.path;
      _currentOutput = result.reply;

      serviceState.add(Data(payload: result.reply));
      await _playAudio(result.path);
    } on PostgrestException catch (e) {
      _handleDbError(debug, e);
    } catch (e, st) {
      if (_isHttpCancelled) {
        debugPrint('😡 Summary request was cancelled');
        return;
      }

      ErrorLogger.logException(e, st);

      if (debug) {
        serviceState.add(Error(payload: e.toString()));
      } else {
        serviceState.add(Data(payload: _currentOutput));
      }
    }
  }

  void _handleDbError(bool debug, PostgrestException e) {
    //! manejamos el error de PostgrestException de Supabase por que
    //! se pierde el stacktrace de la excepcion en el logger
    // TODO: buscar otra mejor opcion
    if (debug) {
      serviceState.addIfStreamOpen(Error(payload: e.toString()));
    } else {
      serviceState.addIfStreamOpen(const Data(payload: "Presiona Continuar"));
    }
    debugPrint('Error occurred: ${e.toJson().toString()}');
    throw StateError(e.toJson().toString());
  }

  Future<void> loadReminders({required bool debug}) async {
    currentState = InitialState.loadingReminders;
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
      final reminderResponse = await ReminderAgent.query(
        'hoy es ${now.dayName} $today, cuales son mis recordatorios para hoy?',
      );

      if (currentState != InitialState.loadingReminders) return;
      if (reminderResponse.payload.isEmpty) {
        throw LolaResponseException('Empty response from ReminderAgent');
      }

      unawaited(AppEvent.remindersFetched.track());

      await _processAndPlayResponse(reminderResponse.payload);
    } on PostgrestException catch (e) {
      _handleDbError(debug, e);
    } catch (e, st) {
      if (_isHttpCancelled) {
        debugPrint('😡 reminders request was cancelled');
        return;
      }

      ErrorLogger.logException(e, st);

      if (debug) {
        serviceState.addIfStreamOpen(Error(payload: e.toString()));
      } else {
        serviceState.addIfStreamOpen(Data(payload: _currentOutput));
      }
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

      // TODO: test first time reminders skipping
      unawaited(AppEvent.remindersFirstTime.track());
      await _processAndPlayResponse(onboardingResponse.payload);
    } catch (e, st) {
      ErrorLogger.logException(e, st);

      if (debug) {
        serviceState.addIfStreamOpen(Error(payload: e.toString()));
      } else {
        serviceState.addIfStreamOpen(Data(payload: _currentOutput));
      }
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
    _isHttpCancelled = true;
    _audioplayer.dispose();
    audioState.close();
    serviceState.close();
  }
}
