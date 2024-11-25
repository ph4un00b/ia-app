import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:lola_ai_app/config/env.dart';

final class Transcription {
  static Future<String> request({required String path}) async {
    OpenAI.apiKey = Env.openAiKey;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut =
        const Duration(seconds: Constants.maxTimeout); // 60 seconds.
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    final transcription = await OpenAI.instance.audio.createTranscription(
      file: File(path),
      model: "whisper-1",
      responseFormat: OpenAIAudioResponseFormat.json,
    );

    return transcription.text;
  }
}
