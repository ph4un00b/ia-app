import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/AudioPlayer/types.dart';
import 'package:lola_ai_app/features/core/logger.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:lola_ai_app/services/Transcription/transcription.dart';
import 'package:lola_ai_app/services/Transcription/types.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:record/record.dart' as rec;

import 'utils.dart';

enum VozMessageState {
  empty,
  loaded,
  editing,
  edited,
}

final class VozController with ChangeNotifier, ContentHandler {
  final rec.AudioRecorder _recorder = rec.AudioRecorder();
  final audio.AudioPlayer _player = audio.AudioPlayer();
  RecordState currentStatus = RecordState.idle;
  TranscriptionState transcriptionStatus = TranscriptionState.idle;
  VozMessageState messageStatus = VozMessageState.empty;

  String _input = '';
  String _path = '';

  VozController() {
    _recorder.onStateChanged().listen((event) async {
      if (event case rec.RecordState.stop) {
        notifyListeners();
      } else if (event case _) {}
    });

    _player.playbackEventStream.listen((event) async {
      switch (event.processingState) {
        case audio.ProcessingState.idle:
          currentStatus = RecordState.idle;
          notifyListeners();
          break;
        case audio.ProcessingState.loading:
          break;
        case audio.ProcessingState.buffering:
          break;
        case audio.ProcessingState.ready:
          break;
        case audio.ProcessingState.completed:
          currentStatus = RecordState.playingCompleted;
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

    String transcription;
    try {
      transcriptionStatus = TranscriptionState.transcribing;
      notifyListeners();
      transcription = await Transcription.request(path: _path);
    } on TimeoutException catch (e) {
      ErrorLogger.logException(e, StackTrace.current);
      transcriptionStatus = TranscriptionState.transcribingError;
      notifyListeners();
      return '';
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      transcriptionStatus = TranscriptionState.transcribingError;
      notifyListeners();
      return '';
    }

    transcriptionStatus = TranscriptionState.transcribingOk;
    messageStatus = VozMessageState.loaded;
    notifyListeners();
    return transcription;
  }

  bool get hasPath => _path.isNotEmpty;

  Future<void> notifyPlayAudio() async {
    if (_path.isEmpty) {
      return;
    }

    try {
      _player.setFilePath(_path);
      await _player.play();

      currentStatus = RecordState.playing;
      notifyListeners();
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      currentStatus = RecordState.playingError;
      notifyListeners();
    }
  }

  Future<void> notifyStopAudio() async {
    try {
      currentStatus = RecordState.stopPlaying;
      notifyListeners();

      await _player.stop();
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      currentStatus = RecordState.stopPlayingError;
      notifyListeners();
    }
  }

  Future<void> startRecording() async {
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

        currentStatus = RecordState.recording;
        notifyListeners();

        await _recorder.start(config, path: path);
      }
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      currentStatus = RecordState.recordingError;
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    currentStatus = RecordState.stopRecording;
    notifyListeners();
    try {
      var path = await _recorder.stop() ?? '';
      assert(path == _path);

      updateContent(await _fetchAITranscription());
    } catch (e, st) {
      ErrorLogger.logException(e, st);
      currentStatus = RecordState.stopRecordingError;
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
