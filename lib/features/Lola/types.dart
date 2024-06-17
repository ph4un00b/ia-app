import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/core/time.dart';
import 'package:lola_ai_app/secrets.dart' as secrets;
import 'package:path_provider/path_provider.dart';

import '../core/elevenlabs/api.dart';
import '../core/elevenlabs/types.dart';

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
        OpenAI.apiKey = secrets.OPENAI_API_KEY;
        OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
        OpenAI.requestsTimeOut = const Duration(seconds: 10); // 60 seconds.
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
          config: const ElevenLabsConfig(apiKey: secrets.ELEVEN_API_KEY),
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
