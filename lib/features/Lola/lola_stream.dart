import 'dart:async';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/secrets.dart' as secrets;
import 'package:just_audio/just_audio.dart' as audio;

final class Lola$ {
  final state = StreamController<LolaState$>()..add(Idle());
  final audioState = StreamController<LolaAudioState$>()..add(NonePath());
  final outputState = StreamController<LolaOutState$>()..add(NoMessage());
  String _output = '';
  String _path = '';
  final audio.AudioPlayer _player = audio.AudioPlayer();

  Lola$() {
    _player.playbackEventStream.listen((event) async {
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
          _emit(SpeakingOK(output: _output));
          audioState.add(PlayingCompleted());
          debugPrint('play lola completed!');
      }
    });
  }

  Widget empty() {
    return Container();
  }

  loadReply({required String input, required VoiceLola voice}) async {
    var completion = '';
    outputState.add(NoMessage());
    _emit(FetchingCompletion());
    try {
      completion = await _fetchCompletion(input: input);
      _output = completion;
      _emit(CompletionOK(output: completion));
      outputState.add(HasMessage(message: completion));
    } catch (e) {
      _emit(CompletionErr(cause: e.toString()));
    }

    if (completion.isEmpty) {
      _emit(const CompletionErr(cause: 'empty'));
      return;
    }

    var path = '';
    _emit(FetchingSpeech(output: completion));
    try {
      path = await _fetchSpeech(text: completion, voice: voice);
      _emit(SpeechOk(path: path, output: completion));
    } catch (e) {
      _emit(SpeechErr(cause: e.toString(), output: completion));
    }

    if (path.isEmpty) {
      _emit(SpeechErr(cause: 'empty path', output: completion));
      return;
    }
    _path = path;
    try {
      audioState.add(Playing());
      await _playSpeech(path: path);
    } catch (e) {
      _emit(SpeakingErr(cause: e.toString(), output: completion));
      audioState.add(PlayingErr());
    }
  }

  void _emit(LolaState$ ev) {
    state.add(ev);
  }

  Future<void> _playSpeech({required String path}) async {
    debugPrint('play lola');
    _player.setFilePath(path);
    await _player.play();
  }

  Future<String> _fetchSpeech(
      {required VoiceLola voice, required String text}) async {
    File speechFile;
    speechFile = await voice.synthesize(text: text);
    debugPrint(speechFile.path);
    return speechFile.path;
  }

  Future<String> _fetchCompletion({
    required String input,
  }) async {
    debugPrint("init fecthAIEnfermeraCompletion: $input");
    if (input.isEmpty) {
      debugPrint("lola input empty: $input");
      return '';
    }

    OpenAI.apiKey = secrets.OPENAI_API_KEY;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut = const Duration(seconds: 10); // 60 seconds.
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;
    OpenAICompletionModel? completion;

    var pregunta = input;

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
    if (!completion.haveChoices) {
      return '';
    }

    var result = completion.choices.first.text.split(input).last.trim();
    debugPrint('done: lola fetchingCompletion: $result');
    return result;
  }

  Future<void> stopSpeech() async {
    if (!_player.playing) {
      return;
    }

    try {
      await _player.stop();
      audioState.add(Stopped());
    } catch (e) {
      debugPrint(e.toString());
      audioState.add(StoppedErr());
    }
  }

  Future<void> playSpeech() async {
    try {
      audioState.add(Playing());
      _player.setFilePath(_path);
      await _player.play();
    } catch (e) {
      debugPrint(e.toString());
      audioState.add(PlayingErr());
    }
  }

  void dispose() {
    _player.dispose();
  }
}
