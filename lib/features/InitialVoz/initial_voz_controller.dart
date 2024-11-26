import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:lola_ai_app/features/App/init.dart';
import 'package:lola_ai_app/features/App/status.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/User/user_settings.dart';
import 'package:lola_ai_app/features/core/logger.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:path/path.dart' as p;
import 'package:lola_ai_app/features/Agents/reminder_agent.dart';
import 'package:lola_ai_app/features/Lola/queries/summary.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
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
  Map<String, dynamic>? result;

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

  Future<void> loadSummary({bool debug = false}) async {
    currentState = InitialState.loadingSummary;

    if (debug) {
      serviceState.add(const IdleService(payload: 'loading summary'));
    } else {
      serviceState.add(Loading());
    }

    try {
      final result = await LolaSummaryGenerator.generate(
          voice: currentVoice, debug: debug);
      if (currentState != InitialState.loadingSummary) return;

      unawaited(AppEvent.summaryFetched
          .track(params: {'userStatus': AppStatus.instance.currentUserStatus}));

      _currentAudioPath = result.path;
      _currentOutput = result.reply;

      serviceState.add(Data(payload: result.reply));
      await _playAudio(result.path);
    } on PostgrestException catch (e) {
      _handleDbError(debug, e);
    } on TimeoutException catch (e) {
      ErrorLogger.logException(e, StackTrace.current);

      if (debug) {
        serviceState.add(Error(payload: e.toString()));
      } else {
        serviceState.add(Data(payload: _currentOutput));
      }
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
    if (debug) {
      serviceState.addIfStreamOpen(Error(payload: e.toString()));
    } else {
      serviceState.addIfStreamOpen(const Data(payload: "Presiona Continuar"));
    }
    debugPrint('Error occurred: ${e.toJson().toString()}');
    ErrorLogger.logException(e, StackTrace.current);
  }

  Future<void> loadReminders({required bool debug}) async {
    currentState = InitialState.loadingReminders;

    if (AppStatus.isActive()) {
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

      unawaited(AppEvent.remindersFetched
          .track(params: {'userStatus': AppStatus.instance.currentUserStatus}));

      await _processAndPlayResponse(reminderResponse.payload);
    } on PostgrestException catch (e) {
      _handleDbError(debug, e);
    } on TimeoutException catch (e) {
      ErrorLogger.logException(e, StackTrace.current);

      if (debug) {
        serviceState.addIfStreamOpen(Error(payload: e.toString()));
      } else {
        serviceState.addIfStreamOpen(Data(payload: _currentOutput));
      }
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
      unawaited(AppEvent.remindersFirstTime.track());

      await _processAndPlayResponse(
          "Hola!, Soy Lola, tu asistente para recordatorios. Cuando tengas recordatorios aquí te ayudaré a recordarlos.");
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

  Future<void> loadUserMetadata() async {
    try {
      final userMetadata = await UserSettings.metadata();

      final decisionResult = AppInitDecision.from(
          userState: AppStatus.instance.currentUserStatus,
          userMetadata: userMetadata);

      final _ = switch (decisionResult) {
        AppInitDecision.createUserMetadata => await UserSettings.initialize(),
        AppInitDecision.updateUserStatus =>
          AppStatus.instance.currentUserStatus = userMetadata!.appStatus,
        AppInitDecision.none => {},
      };
    } on PostgrestException catch (e) {
      //! manejamos el error de PostgrestException de Supabase por que
      //! se pierde el stacktrace de la excepcion en el logger
      ErrorLogger.logException(e, StackTrace.current);
    } on TimeoutException catch (e) {
      ErrorLogger.logException(e, StackTrace.current);
    } catch (e, st) {
      ErrorLogger.logException(e, st);
    }
  }

  void dispose() {
    _isHttpCancelled = true;
    _audioplayer.dispose();
    audioState.close();
    serviceState.close();
  }
}
