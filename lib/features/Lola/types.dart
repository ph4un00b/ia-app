import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/core/components/action_btn.dart';
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

sealed class LolaOutState$ {}

final class LolaEmpty implements LolaOutState$ {
  Widget actionDisabled({required double scale}) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: ActionButton(
              icon: const Icon(Icons.expand_less),
              text: 'Ver Mensaje',
              scale: scale,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

final class LolaMessage implements LolaOutState$ {
  final String message;
  const LolaMessage({required this.message});

  Widget actionEnabled({required double scale, required Function action}) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: ActionButton(
              icon: const Icon(Icons.expand_less),
              text: 'Ver Mensaje',
              scale: scale,
              onPressed: () => action(),
            ),
          ),
        ],
      ),
    );
  }
}

sealed class LolaAudioState$ {}

final class NonePath implements LolaAudioState$ {
  Widget actionDisabled({required double scale}) {
    return ActionButton(
      icon: const Icon(Icons.play_arrow_rounded),
      text: 'Repetir',
      scale: scale,
      color: Colors.grey,
    );
  }
}

final class Playing implements LolaAudioState$ {
  Widget stop(
      {required double scale, required Future<void> Function() action}) {
    return ActionButton(
      icon: const Icon(Icons.stop),
      text: 'Parar',
      scale: scale,
      onPressed: () => action(),
    );
  }
}

final class PlayingErr implements LolaAudioState$ {
  Widget replay(
      {required double scale, required Future<void> Function() action}) {
    return ActionButton(
      icon: const Icon(Icons.play_arrow_rounded),
      text: 'Repetir',
      scale: scale,
      color: Colors.green,
      onPressed: () => action(),
    );
  }
}

final class PlayingCompleted implements LolaAudioState$ {
  Widget replay(
      {required double scale, required Future<void> Function() action}) {
    return ActionButton(
      icon: const Icon(Icons.play_arrow_rounded),
      text: 'Repetir',
      scale: scale,
      color: Colors.green,
      onPressed: () => action(),
    );
  }
}

final class Stopped implements LolaAudioState$ {
  Widget play(double scale, {required Future<void> Function() action}) {
    return ActionButton(
      icon: const Icon(Icons.play_arrow_rounded),
      text: 'Repetir',
      scale: scale,
      onPressed: () => action(),
    );
  }
}

final class StoppedErr implements LolaAudioState$ {
  Widget play(double scale, {required Future<void> Function() action}) {
    return ActionButton(
      icon: const Icon(Icons.play_arrow_rounded),
      text: 'Repetir',
      scale: scale,
      onPressed: () => action(),
    );
  }
}

sealed class LolaState$ {}

mixin None {
  Widget empty();
}
mixin Some {
  Widget withMessage({required double scale});
}

final class Idle with None implements LolaState$ {
  @override
  Widget empty() {
    return Empty(state: toString());
  }
}

final class FetchingCompletion with None implements LolaState$ {
  @override
  Widget empty() {
    return Empty(state: toString());
  }
}

final class CompletionOK with Some implements LolaState$ {
  final String output;
  const CompletionOK({required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class CompletionErr with None implements LolaState$ {
  final String cause;
  const CompletionErr({required this.cause});

  @override
  Widget empty() {
    return Empty(state: toString());
  }
}

final class FetchingSpeech with Some implements LolaState$ {
  final String output;
  const FetchingSpeech({required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class SpeechOk with Some implements LolaState$ {
  final String path;
  final String output;
  const SpeechOk({required this.path, required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class SpeechErr with Some implements LolaState$ {
  final String output;
  final String cause;
  const SpeechErr({required this.cause, required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class SpeakingIdle with Some implements LolaState$ {
  final String output;
  const SpeakingIdle({required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class SpeakingOK with Some implements LolaState$ {
  final String output;
  const SpeakingOK({required this.output});

  @override
  Widget withMessage({required double scale}) {
    return WithMessage(state: toString(), message: output, scale: scale);
  }
}

final class SpeakingErr with Some implements LolaState$ {
  final String output;
  final String cause;
  const SpeakingErr({required this.cause, required this.output});

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
          Text(
            state,
            textScaler: TextScaler.linear(1.6 * scale),
          ),
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
    return Center(
      child: Column(
        children: [
          Text(
            state,
            textScaler: const TextScaler.linear(1.6),
          ),
          const Expanded(
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
