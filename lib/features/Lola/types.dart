import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/core/time.dart';
import 'package:path_provider/path_provider.dart';

import '../core/elevenlabs/api.dart';
import '../core/elevenlabs/types.dart';

enum LolaState { idle, running, creatingReminder }

class LolaAudioException implements Exception {
  final String? message;

  LolaAudioException(this.message);
}

class LolaResponseException implements Exception {
  final String message;
  LolaResponseException(this.message);

  @override
  String toString() => 'LolaResponseException: $message';
}

class LolaResult {
  final String path;
  final String reply;

  LolaResult(this.path, this.reply);
}

enum Ai {
  openai,
  elevenlabs,
}

enum VoiceLola {
  nova(label: 'Nova', voice: 'nova', ai: Ai.openai),
  shimmer(label: 'shimmer', voice: 'shimmer', ai: Ai.openai),
  caro(label: 'caro', voice: 'UOIqAnmS11Reiei1Ytkc', ai: Ai.elevenlabs),
  valeria(label: 'valeria', voice: '9oPKasc15pfAbMr7N6Gs', ai: Ai.elevenlabs),
  maria(label: 'maria', voice: '5K2SjAdgoClKG1acJ17G', ai: Ai.elevenlabs),
  // low
  // cristina(label: 'cristina', voice: '8ftlfIEYnEkYY6iLanUO', ai: Ai.elevenlabs),
  isabela(label: 'isabela', voice: '1BxAZWANeDIxeyHKSJF2', ai: Ai.elevenlabs),
  gabriela(label: 'gabriela', voice: 'hHjbwzYZW17oh0p05AKv', ai: Ai.elevenlabs),
  mady(label: 'mady', voice: '4v7HtLWqY9rpQ7Cg2GT4', ai: Ai.elevenlabs),
  ligia(label: 'ligia', voice: 'szJ1F5SgxGkjGanyygoW', ai: Ai.elevenlabs),
  // elena(label: 'elena', voice: '4VDZLGtT3KMPG6CtDKCT', ai: Ai.elevenlabs),
  sofi(label: 'sofi', voice: 'vqoh9orw2tmOS3mY7D2p', ai: Ai.elevenlabs),
  rosa(label: 'rosa', voice: 'ypIbR1aohyRSdDv25DPr', ai: Ai.elevenlabs),
  alia(label: 'alia', voice: 'yrTLAnTx4cVYEuiqiOGI', ai: Ai.elevenlabs),
  loida(label: 'loida', voice: 'HYlEvvU9GMan5YdjFYpg', ai: Ai.elevenlabs);
  //low
  // angie(label: 'angie', voice: '6yaxfNs1EwgOLYsNHlcf', ai: Ai.elevenlabs);

  const VoiceLola({
    required this.label,
    required this.ai,
    required this.voice,
  });

  final String label;
  final Ai ai;
  final String voice;

  Future<File> synthesize({required String text}) async {
    switch (ai) {
      case Ai.openai:
        OpenAI.apiKey = Env.openAiKey;
        OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
        OpenAI.requestsTimeOut = const Duration(seconds: 25);
        OpenAI.showLogs = false;
        OpenAI.showResponsesLogs = !true;

        debugPrint('>>> openaiReply: $voice');
        return await OpenAI.instance.audio.createSpeech(
          model: "tts-1",
          input: text,
          voice: voice,
          responseFormat: OpenAIAudioSpeechResponseFormat.aac,
          outputDirectory: await getTemporaryDirectory(),
          outputFileName: 'lola_tmp_${formatTimestamp(DateTime.now())}',
        );
      case Ai.elevenlabs:
        var api = ElevenLabsAPI();
        api.init(
          config: ElevenLabsConfig(apiKey: Env.elevenApiKey),
        );
        return await api.synthesize(TextToSpeechRequest(
          text: text,
          voiceId: voice,
          // best model at the moment 06/16/2024
          modelId: 'eleven_multilingual_v2',
        ));
      default:
        return throw UnimplementedError();
    }
  }
}

sealed class LolaServiceState {}

final class IdleService implements LolaServiceState {
   final Payload payload;
  const IdleService({this.payload = const Payload()});

  @override
  String toString() {
    return 'IdleService: $payload';
  }
}

final class Loading implements LolaServiceState {
  final Payload payload;
  const Loading({this.payload = const Payload()});

  @override
  String toString() {
    return 'Loading Lola Response';
  }
}

class Payload {
  final String userQuestion;
  final String reply;

  const Payload({this.userQuestion = "", this.reply = ""});
}

final class Data implements LolaServiceState {
  final Payload payload;
  const Data({this.payload = const Payload()});

  @override
  String toString() {
    return 'Data Loaded';
  }
}

final class Error implements LolaServiceState {
  final Payload payload;
  const Error({this.payload = const Payload()});

  @override
  String toString() {
    return 'Error';
  }
}

sealed class LolaState$ {}

mixin None {
  Widget empty();
}
mixin Some {
  Widget withMessage({required double scale});
}

final class Idle with Some implements LolaState$ {
  final String output;
  const Idle({this.output = ''});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class FetchingResponse with None implements LolaState$ {
  @override
  Widget empty() {
    return Empty(state: toString());
  }
}

final class ResponseOk with Some implements LolaState$ {
  final String output;
  const ResponseOk({required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class ResponseErr with None implements LolaState$ {
  final String cause;
  const ResponseErr({required this.cause});

  @override
  Widget empty() {
    return Empty(state: toString());
  }
}

final class FetchingAudio with Some implements LolaState$ {
  final String output;
  const FetchingAudio({required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class AudioOk with Some implements LolaState$ {
  final String path;
  final String output;
  const AudioOk({required this.path, required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class AudioErr with Some implements LolaState$ {
  final String output;
  final String cause;
  const AudioErr({required this.cause, required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class LolaSilent with Some implements LolaState$ {
  final String output;
  const LolaSilent({required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class LolaSpoken with Some implements LolaState$ {
  final String output;
  const LolaSpoken({required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class LolaSpeechErr with Some implements LolaState$ {
  final String output;
  final String cause;
  const LolaSpeechErr({required this.cause, required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

class WithMessage extends StatelessWidget {
  const WithMessage({
    super.key,
    required this.scale,
    required this.state,
    required this.message,
  });

  final double scale;
  final String state;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Text(
              message,
              textScaler: TextScaler.linear(2.6 * scale),
              maxLines: 4,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class Empty extends StatelessWidget {
  final String state;

  const Empty({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Expanded(
            child: Text(
              '',
              textScaler: TextScaler.linear(2.6),
              maxLines: 4,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
