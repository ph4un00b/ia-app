import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:lola_ai_app/config/env.dart';

import '../Agents/llm.dart';

class PromptGetUserQuestions {
  static query({required LLM llm, required String messages}) async {
    OpenAI.apiKey = Env.openAiKey;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut = const Duration(seconds: Constants.maxTimeout);
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    var response = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        llm.system(message: _prompt(messages: messages)),
      ],
      maxTokens: kDebugMode ? 1024 : Constants.maxTokens,
      temperature: 0,
      n: 1,
    );

    var responseText = response.choices.first.message.content?.first.text;
    return responseText ?? '';
  }

  static String _prompt({required String messages}) {
    return '''# IDENTITY
You specialize in extracting the questions out of a piece of content, word for word, and then figuring out what made the questions so good.

# GOAL
- Extract all the questions from USER.

# OUTPUT
- In a section called QUESTIONS, list all questions as a series of bullet points.

# INPUT
$messages''';
  }
}
