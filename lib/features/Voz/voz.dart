import 'dart:async';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/core/logger.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:record/record.dart' as rec;

import 'utils.dart';

enum VozState {
  idle,
  recording,
  recordingError,
  recordingOk,
  stopRecording,
  stopRecordingError,
  playing,
  playingError,
  stopPlaying,
  stopPlayingError,
  playingCompleted
}

enum VozAI { idle, transcribing, transcribingError, transcribingOk }

enum VozMessageState {
  empty,
  loaded,
  editing,
  edited,
}

final class Voz with ChangeNotifier, ContentHandler {
  final rec.AudioRecorder _recorder = rec.AudioRecorder();
  final audio.AudioPlayer _player = audio.AudioPlayer();
  VozState state = VozState.idle;
  VozAI aiState = VozAI.idle;
  VozMessageState messageState = VozMessageState.empty;

  String _input = '';
  String _path = '';

  Voz() {
    _recorder.onStateChanged().listen((event) async {
      if (event case rec.RecordState.stop) {
        notifyListeners();
      } else if (event case _) {}
    });

    _player.playbackEventStream.listen((event) async {
      switch (event.processingState) {
        case audio.ProcessingState.idle:
          state = VozState.idle;
          notifyListeners();
          break;
        case audio.ProcessingState.loading:
          break;
        case audio.ProcessingState.buffering:
          break;
        case audio.ProcessingState.ready:
          break;
        case audio.ProcessingState.completed:
          state = VozState.playingCompleted;
          notifyListeners();
      }
    });
  }

  @override
  void updateContent(String value) {
    _input = value;
    notifyListeners();
  }

  @override
  String content() {
    return _input;
  }

  Future<String> _fetchAITranscription() async {
    if (!hasPath) {
      return '';
    }

    OpenAI.apiKey = Env.openAiKey;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut =
        const Duration(seconds: Constants.maxTimeout); // 60 seconds.
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    OpenAIAudioModel transcription;
    try {
      aiState = VozAI.transcribing;
      notifyListeners();
      transcription = await OpenAI.instance.audio.createTranscription(
        file: File(_path),
        model: "whisper-1",
        responseFormat: OpenAIAudioResponseFormat.json,
      );
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      aiState = VozAI.transcribingError;
      notifyListeners();
      return '';
    }

    aiState = VozAI.transcribingOk;
    messageState = VozMessageState.loaded;
    notifyListeners();
    return transcription.text;
  }

  bool get hasPath => _path.isNotEmpty;

  Future<void> notifyPlayAudio() async {
    if (_path.isEmpty) {
      return;
    }

    try {
      _player.setFilePath(_path);
      await _player.play();

      state = VozState.playing;
      notifyListeners();
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      state = VozState.playingError;
      notifyListeners();
    }
  }

  Future<void> notifyStopAudio() async {
    try {
      state = VozState.stopPlaying;
      notifyListeners();

      await _player.stop();
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      state = VozState.stopPlayingError;
      notifyListeners();
    }
  }

  Future<void> notifyStartRecording() async {
    unawaited(AppEvent.questionByVoice.track());

    try {
      var hasPermission = await _recorder.hasPermission();

      if (hasPermission) {
        var encoder = rec.AudioEncoder.aacLc;
        bool isSupported = await _isEncoderSupportted(encoder);
        if (!isSupported) {
          return;
        }

        // final devices = await _recorder.listInputDevices();
        // debugPrint(">> devices: $devices");

        var config = rec.RecordConfig(encoder: encoder, numChannels: 2);
        String path =
            await buildPath(encoder: encoder, folder: FolderKind.temp);
        _path = path;

        state = VozState.recording;
        notifyListeners();

        await _recorder.start(config, path: path);
      }
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      state = VozState.recordingError;
      notifyListeners();
    }
  }

  Future<void> notifyStopRecording() async {
    state = VozState.stopRecording;
    notifyListeners();
    try {
      var path = await _recorder.stop() ?? '';
      assert(path == _path);

      updateContent(await _fetchAITranscription());
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      state = VozState.stopRecordingError;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _recorder.dispose();
    _player.dispose();
  }

  Future<bool> _isEncoderSupportted(rec.AudioEncoder encoder) async {
    final isSupported = await _recorder.isEncoderSupported(encoder);

    if (!isSupported) {
      debugPrint('${encoder.name} is not supported on this platform.');
      debugPrint('Supported encoders are:');

      for (final e in rec.AudioEncoder.values) {
        if (await _recorder.isEncoderSupported(e)) {
          debugPrint('- ${e.name}');
        }
      }
    }
    return isSupported;
  }
}
