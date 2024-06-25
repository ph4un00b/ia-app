// do not resolve late variables in contructors

import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:record/record.dart' as rec;
import 'package:lola_ai_app/secrets.dart' as secrets;

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

final class Voz with ChangeNotifier {
  VozState state = VozState.idle;
  VozAI aiState = VozAI.idle;
  VozMessageState messageState = VozMessageState.empty;

  String input = '';
  final rec.AudioRecorder _recorder = rec.AudioRecorder();
  final audio.AudioPlayer _player = audio.AudioPlayer();
  String _path = '';

  Voz() {
    _recorder.onStateChanged().listen((event) async {
      debugPrint('>> from: $state');
      if (event case rec.RecordState.stop) {
        state = VozState.recordingOk;
        notifyListeners();
      } else if (event case _) {
        debugPrint('>> RECORDER EVENTS => _ : $event');
      }
    });

    _player.playbackEventStream.listen((event) async {
      switch (event.processingState) {
        case audio.ProcessingState.idle:
          // debugPrint('>> $event');
          state = VozState.idle;
          notifyListeners();
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
          state = VozState.playingCompleted;
          notifyListeners();
          debugPrint('play completed!');
      }
    });
  }

  Future<String> _fetchAITranscription() async {
    if (!hasPath) {
      return '';
    }

    debugPrint('init voz fetchAITranscription');
    OpenAI.apiKey = secrets.OPENAI_API_KEY;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut = const Duration(seconds: 10); // 60 seconds.
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = !true;

    OpenAIAudioModel transcription;
    try {
      aiState = VozAI.transcribing;
      notifyListeners();
      transcription = await OpenAI.instance.audio.createTranscription(
        file: File(_path),
        model: "whisper-1",
        responseFormat: OpenAIAudioResponseFormat.json,
      );
    } catch (e) {
      aiState = VozAI.transcribingError;
      notifyListeners();
      debugPrint('transcribing err: ${e.toString()}');
      return '';
    }

    // print the transcription.
    debugPrint('voz done:transcription: ${transcription.text}');
    // debugPrint(transcription.language);
    // debugPrint(transcription.duration.toString());
    // debugPrint(transcription.task);
    aiState = VozAI.transcribingOk;
    messageState = VozMessageState.loaded;
    notifyListeners();
    return transcription.text;
  }

  bool get hasPath => _path.isNotEmpty;

  Future<void> notifyPlayAudio() async {
    if (_path.isEmpty) {
      debugPrint('no path');
      return;
    }

    try {
      debugPrint('play');
      _player.setFilePath(_path);
      await _player.play();

      state = VozState.playing;
      notifyListeners();
    } catch (e) {
      state = VozState.playingError;
      notifyListeners();

      debugPrint(e.toString());
    }
  }

  Future<void> notifyStopAudio() async {
    try {
      debugPrint('stop play');

      state = VozState.stopPlaying;
      notifyListeners();

      await _player.stop();
    } catch (e) {
      state = VozState.stopPlayingError;
      notifyListeners();

      debugPrint(e.toString());
    }
  }

  Future<void> notifyStartRecording() async {
    try {
      var hasPermission = await _recorder.hasPermission();
      debugPrint('recording tiene permisos?: $hasPermission');

      if (hasPermission) {
        debugPrint('se tiene permiso');

        var encoder = rec.AudioEncoder.aacLc;
        bool isSupported = await _isEncoderSupportted(encoder);
        if (!isSupported) {
          return;
        }

        final devices = await _recorder.listInputDevices();
        debugPrint(">> devices: $devices");

        var config = rec.RecordConfig(encoder: encoder, numChannels: 2);
        String path = await buildPath(encoder: encoder, folder: FolderKind.temp);
        debugPrint(">> path: $path");
        _path = path;

        state = VozState.recording;
        notifyListeners();

        await _recorder.start(config, path: path);
      }
    } catch (e) {
      state = VozState.recordingError;
      notifyListeners();
      debugPrint(e.toString());
    }
  }

  Future<void> notifyStopRecording() async {
    state = VozState.stopRecording;
    notifyListeners();
    try {
      debugPrint('stop');
      var path = await _recorder.stop() ?? '';
      assert(path == _path);

      input = await _fetchAITranscription();
    } catch (e) {
      state = VozState.stopRecordingError;
      notifyListeners();

      debugPrint('stop-recording err: ${e.toString()}');
      debugPrint(e.toString());
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
