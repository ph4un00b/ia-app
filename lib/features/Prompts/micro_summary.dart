import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:lola_ai_app/config/env.dart';

import '../Agents/llm.dart';

class PromptMicroSummary {
  static Future<String> query({
    required LLM llm,
    required String text,
  }) async {
    OpenAI.apiKey = Env.openAiKey;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut = const Duration(seconds: Constants.maxTimeout);
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    var response = await OpenAI.instance.chat.create(
      model: "gpt-4o",
      messages: [
        llm.system(message: _prompt(messages: text)),
      ],
      maxTokens: kDebugMode ? 1024 : Constants.maxTokens,
      temperature: 0,
      n: 1,
    );

    var responseText = response.choices.first.message.content?.first.text;
    return responseText ?? '';
  }

  static String _prompt({required String messages}) {
    return '''# IDENTITY and PURPOSE

You are an expert content summarizer with a focus on distilling information efficiently and effectively in Spanish. Your task is to analyze provided content and produce a concise summary following these steps:

1. Thoroughly read and analyze the provided content.
2. Synthesize the main ideas, key points, and overall message.
3. Create a single, impactful sentence of exactly 20 words that captures the essence of the input.
4. Identify and extract the 4 most important points from the content.
5. Format your output as follows:

Hola! Te resumo nuestras conversaciones recientes:
[Your synthesized sentence here]

INPUT:
$messages''';
  }
}
