import 'dart:async';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Memory/query_reply.dart' as memory;
import 'package:lola_ai_app/features/core/types.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

final class Lola$ with QueryContent {
  final state = StreamController<LolaState$>()..add(Idle());
  final audioState = StreamController<LolaAudioState$>()..add(NonePath());
  final replyState = StreamController<LolaReplyState$>()..add(LolaEmpty());
  String _output = '';
  String _path = '';
  final audio.AudioPlayer _player = audio.AudioPlayer();
  VoiceLola voice = VoiceLola.nova;

  Lola$() {
    _player.playbackEventStream.listen((event) async {
      debugPrint('== LOLA PAYER >> ${event.processingState}');
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

  @override
  String content() {
    return _output;
  }

  loadReply({required String input}) async {
    var completion = '';
    replyState.add(LolaEmpty());
    _emit(FetchingCompletion());
    try {
      completion = await memory.fetchAsistantResponse(input: input);
      _output = completion;
      _emit(CompletionOK(output: completion));
      replyState.add(LolaMessage(message: completion));
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

    var debug = true;
    if (debug) {
      await _saveConversation(
        userInput: input,
        lolaCompletion: completion,
        lolaPath: path,
      );
    } else {
      try {
        // todo: quiza en debug mode, hacer que falle, es decir quitar el try catch!
        // todo: retry on fail
        await _saveConversation(
          userInput: input,
          lolaCompletion: completion,
          lolaPath: path,
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> _saveConversation({
    required String userInput,
    required String lolaCompletion,
    required String lolaPath,
  }) async {
    await Supabase.instance.client.from('conversation').insert([
      {
        'title': '',
        'content': userInput,
        'system': 'user',
        // TODO: use user id from auth
        'user_id': 1,
        'created_at': DateTime.now().toIso8601String()
      },
      {
        'title': '',
        'content': lolaCompletion,
        'system': 'lola',
        // TODO: use user id from auth
        'user_id': 1,
        'created_at':
            DateTime.now().add(const Duration(seconds: 1)).toIso8601String(),
        'path': lolaPath,
      },
    ]);
  }

  void _emit(LolaState$ ev) {
    state.add(ev);
  }

  Future<void> _playSpeech({required String path}) async {
    debugPrint('play lola: $path');
    _player.setFilePath(path);
    _player.play();
  }

  Future<String> _fetchSpeech(
      {required VoiceLola voice, required String text}) async {
    File speechFile;
    speechFile = await voice.synthesize(text: text);
    // debugPrint(p.normalize(speechFile.path));
    return p.normalize(speechFile.path);
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
    state.close();
    audioState.close();
    replyState.close();
  }
}
