import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'types.dart';

enum LolaState {
  idle,
  playing,
  playingError,
  stopPlaying,
  stopPlayingError,
  playingCompleted,
}

enum LolaAI {
  idle,
  fetchingCompletion,
  fetchingCompletionOk,
  fetchingCompletionError,
  creatingSpeech,
  creatingSpeechOk,
  creatingSpeechError,
  thinkingStarted,
  error,
}

final class Lola with ChangeNotifier, QueryContent {
  String output = '';
  String _path = '';
  var fetchingCounter = 0;
  LolaState state = LolaState.idle;
  LolaAI aiState = LolaAI.idle;
  final audio.AudioPlayer _player = audio.AudioPlayer();

  Lola() {
    _player.playbackEventStream.listen((event) async {
      debugPrint('>> lola _audio ${event.processingState}');
      switch (event.processingState) {
        case audio.ProcessingState.idle:
          // debugPrint('>> $event');
          state = LolaState.idle;
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
          state = LolaState.playingCompleted;
          notifyListeners();
          debugPrint('play lola completed!');
      }
    });
  }

  @override
  String content() {
    return output;
  }

  Future<void> notifyStopSpeech() async {
    try {
      debugPrint('stop play');
      state = LolaState.stopPlaying;
      notifyListeners();
      await _player.stop();
    } catch (e) {
      state = LolaState.stopPlayingError;
      notifyListeners();
      debugPrint(e.toString());
    }
  }

  /// there is no notification signal
  Future<void> playSpeech() async {
    if (_path.isEmpty) {
      debugPrint('no path');
      return;
    }

    // try {
    debugPrint('play lola');
    // final source = DeviceFileSource(path);
    // debugPrint('source: $source');
    _player.setFilePath(_path);
    await _player.play();
    state = LolaState.playing;
    // notifyListeners();
    // await player.dispose();
    // } catch (e) {
    //   // setStatus((VozStatus.error, null));
    //   state = LolaTalksState.playingError;
    //   notifyListeners();
    //   debugPrint(e.toString());
    // }
  }

  Future<void> notifyPlaySpeech() async {
    if (_path.isEmpty) {
      debugPrint('no path');
      return;
    }

    debugPrint('play lola');
    _player.setFilePath(_path);
    await _player.play();
    state = LolaState.playing;
    notifyListeners();
  }

  Future<String> _fetchCompletion({
    required String input,
  }) async {
    debugPrint("init fecthAIEnfermeraCompletion: $input");
    if (input.isEmpty) {
      debugPrint("lola input empty: $input");
      return '';
    }

    OpenAI.apiKey = Env.openAiKey;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut = const Duration(seconds: 10); // 60 seconds.
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;
    OpenAICompletionModel? completion;

    // try {
    var pregunta = input;
    aiState = LolaAI.fetchingCompletion;
    // notifyListeners();
    completion = await OpenAI.instance.completion.create(
      model: "gpt-3.5-turbo-instruct",
      prompt: pregunta,
      maxTokens: 85,
      // maxTokens: 200,
      temperature: 0.5,
      n: 1,
      // stop: ["?"],
      // stop: ["\n"],
      echo: true,
      seed: 42,
      // bestOf: 2,
    );
    // } catch (e) {
    //   aiState = LolaAIState.fetchingCompletionError;
    //   notifyListeners();
    //   debugPrint(e.toString());
    // }

    if (!completion.haveChoices) {
      return '';
    }

    var result = completion.choices.first.text.split(input).last.trim();
    output = result;

    debugPrint('done: lola fetchingCompletion: $result');
    // debugPrint(completion.systemFingerprint);
    // debugPrint(completion.id);
    // aiState = LolaAIState.fetchingCompletionOk;
    // notifyListeners();
    // setStatus((VozStatus.responded, result));
    return result;
  }

  Future<String> _fetchSpeech({required VoiceLola voice}) async {
    File speechFile;
    // try {
    aiState = LolaAI.creatingSpeech;
    // notifyListeners();
    speechFile = await voice.synthesize(text: output);
    // } catch (e) {
    //   aiState = LolaAIState.creatingSpeechError;
    //   notifyListeners();
    //   debugPrint(e.toString());
    //   return '';
    // }

    debugPrint(speechFile.path);
    _path = speechFile.path;

    // aiState = LolaAIState.creatingSpeechOk;
    // notifyListeners();
    return speechFile.path;
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  Future<String> reply({
    required String input,
    required VoiceLola voice,
  }) async {
    // if (aiState == LolaAIState.creatingSpeech ||
    //     aiState == LolaAIState.fetchingCompletion) {
    //   return output;
    // } else {
    fetchingCounter += 1;
    // notifyListeners();
    var result = await _fetchCompletion(input: input);
    await _fetchSpeech(voice: voice);
    await playSpeech();
    return result;
    // }
  }

  void notifyStart() {
    debugPrint('>> lola start()');
    aiState = LolaAI.thinkingStarted;
    notifyListeners();
  }

  void error() {
    debugPrint('>> lola error()');
    aiState = LolaAI.error;
  }
}
