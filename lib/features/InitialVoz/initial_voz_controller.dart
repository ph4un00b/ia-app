import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:lola_ai_app/features/Agents/reminder_agent.dart';
import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/App/init.dart';
import 'package:lola_ai_app/features/App/status.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/Lola/queries/summary.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/User/user_settings.dart';
import 'package:lola_ai_app/features/core/logger.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:path/path.dart' as p;
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
        3 => 'Miércoles',
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
  final serviceState = StreamController<LolaServiceState>()..add(const IdleService());
  final audioState = StreamController<AudioState>()..add(NoAudioPath());

  VoiceLola currentVoice = VoiceLola.alia;
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
      serviceState.add(const IdleService(payload: Payload(reply: 'loading summary')));
    } else {
      serviceState.add(const Loading(intent: IntentKind.text));
    }

    try {
      final result = await LolaSummaryGenerator.generate(voice: currentVoice, debug: debug);
      if (currentState != InitialState.loadingSummary) return;

      unawaited(AppEvent.summaryFetched.track(params: {'userStatus': AppStatus.instance.currentUserStatus}));

      serviceState.add(Loading(intent: IntentKind.text, payload: Payload(userQuestion: "", reply: result.text)));

      _currentOutput = result.text;

      String path = p.normalize((await currentVoice.synthesize(text: result.text)).path);
      _currentAudioPath = path;

      serviceState.add(Data(payload: Payload(reply: result.text)));
      await _playAudio(path);
    } on PostgrestException catch (e) {
      _handleDbError(debug, e);
    } on TimeoutException catch (e) {
      ErrorLogger.logException(e, StackTrace.current);

      if (debug) {
        serviceState.add(Error(payload: Payload(reply: e.toString())));
      } else {
        serviceState.add(Data(payload: Payload(reply: _currentOutput)));
      }
    } catch (e, st) {
      if (_isHttpCancelled) {
        debugPrint('😡 Summary request was cancelled');
        return;
      }

      ErrorLogger.logException(e, st);

      if (debug) {
        serviceState.add(Error(payload: Payload(reply: e.toString())));
      } else {
        serviceState.add(Data(payload: Payload(reply: _currentOutput)));
      }
    }
  }

  void _handleDbError(bool debug, PostgrestException e) {
    //! manejamos el error de PostgrestException de Supabase por que
    //! se pierde el stacktrace de la exception en el logger
    if (debug) {
      serviceState.addIfStreamOpen(Error(payload: Payload(reply: e.toString())));
    } else {
      serviceState.addIfStreamOpen(const Data(payload: Payload(reply: "Presiona Continuar")));
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
      serviceState.add(const IdleService(payload: Payload(reply: 'loading reminders')));
    }

    try {
      serviceState.add(const Loading(intent: IntentKind.reminder));

      final now = DateTime.now();
      final today = now.toIso8601String().split('T').first;
      final reminderResponse = await ReminderAgent.query(
        'hoy es ${now.dayName} $today, cuales son mis recordatorios para hoy?',
      );

      if (currentState != InitialState.loadingReminders) return;
      if (reminderResponse.payload.isEmpty) {
        throw LolaResponseException('Empty response from ReminderAgent');
      }

      unawaited(AppEvent.remindersFetched.track(params: {'userStatus': AppStatus.instance.currentUserStatus}));

      serviceState.add(Loading(intent: IntentKind.reminder, payload: Payload(reply: reminderResponse.payload)));

      await _processAndPlayResponse(reminderResponse.payload);
    } on PostgrestException catch (e) {
      _handleDbError(debug, e);
    } on TimeoutException catch (e) {
      ErrorLogger.logException(e, StackTrace.current);

      if (debug) {
        serviceState.addIfStreamOpen(Error(payload: Payload(reply: e.toString())));
      } else {
        serviceState.addIfStreamOpen(Data(payload: Payload(reply: _currentOutput)));
      }
    } catch (e, st) {
      if (_isHttpCancelled) {
        debugPrint('😡 reminders request was cancelled');
        return;
      }

      ErrorLogger.logException(e, st);

      if (debug) {
        serviceState.addIfStreamOpen(Error(payload: Payload(reply: e.toString())));
      } else {
        serviceState.addIfStreamOpen(Data(payload: Payload(reply: _currentOutput)));
      }
    }
  }

  Future<void> _handleFirstTimeReminders(bool debug) async {
    if (debug) {
      serviceState.add(const IdleService(payload: Payload(reply: 'creating first reminders')));
    }

    try {
      unawaited(AppEvent.remindersFirstTime.track());

      const text =
          "Hola!, Soy Lola, tu asistente para recordatorios. Cuando tengas recordatorios aquí te ayudaré a recordarlos.";

      serviceState.add(const Loading(intent: IntentKind.reminder, payload: Payload(reply: text)));
      await _processAndPlayResponse(text);
    } catch (e, st) {
      ErrorLogger.logException(e, st);

      if (debug) {
        serviceState.addIfStreamOpen(Error(payload: Payload(reply: e.toString())));
      } else {
        serviceState.addIfStreamOpen(Data(payload: Payload(reply: _currentOutput)));
      }
    }
  }

  Future<void> _processAndPlayResponse(String payload) async {
    final path = p.normalize((await currentVoice.synthesize(text: payload)).path);
    _currentAudioPath = path;
    _currentOutput = payload;

    serviceState.add(Data(payload: Payload(reply: payload)));
    await _playAudio(path);
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

      final decisionResult =
          AppInitDecision.from(userState: AppStatus.instance.currentUserStatus, userMetadata: userMetadata);

      final _ = switch (decisionResult) {
        AppInitDecision.createUserMetadata => await UserSettings.initialize(),
        AppInitDecision.updateUserStatus => AppStatus.instance.currentUserStatus = userMetadata!.appStatus,
        AppInitDecision.none => {},
      };
    } on PostgrestException catch (e) {
      //! manejamos el error de PostgrestException de Supabase por que
      //! se pierde el stacktrace de la exception en el logger
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
