import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Agents/llm.dart';
import 'package:lola_ai_app/features/Agents/text_agent.prompt.dart';
import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/Memory/queries/short_memory_messages.dart';
import 'package:lola_ai_app/features/core/write_file.dart';

class TextAgent {
  static Future<LLMResponse> query(String input, {required LLM llm}) async {
    debugPrint("init textAgent $llm: $input");
    if (input.isEmpty) {
      return const NoneResponse();
    }

    String? responseText = switch (llm) {
      LLM.openaiAssistant => throw UnimplementedError(),
      LLM.openaiChat => await _openaiChat(input, llm),
      LLM.openaiCompletion => await _openaiCompletion(input, llm),
      LLM.openaiStructuredOutput => throw UnimplementedError(),
    };

    return responseText == null
        ? const NoneResponse()
        : TextResponse(payload: responseText);
  }

  static Future<String?> _openaiChat(
    String input,
    LLM llm,
  ) async {
    String messages = await ShortMemoryMessages.generate();

    await WriteDebugFile.execute(
      content: textAgentPrompt(strMessages: messages),
      filename: 'Debug-textAgentPrompt',
    );

    OpenAI.apiKey = Env.openAiKey;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut = const Duration(seconds: 10);
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    var response = await OpenAI.instance.chat.create(
      // model: "gpt-3.5-turbo",
      model: "gpt-4o-mini",
      messages: [
        llm.system(message: _masterPrompt2(strMessages: messages)),
        llm.user(message: input),
      ],
      maxTokens: 185,
      temperature: 1,
      topP: 1,
      n: 1,
    );

    var responseText = response.choices.first.message.content?.first.text;
    return responseText;
  }

  static String _masterPrompt2({
    String strContexts = '',
    String strMessages = '',
  }) {
    var result = textAgentPrompt(
      strContexts: strContexts,
      strMessages: strMessages,
    );
    debugPrint('textAgentPrompt: $result');
    return result;
  }

  static Future<String?> _openaiCompletion(String input, LLM llm) async {
    OpenAI.apiKey = Env.openAiKey;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut = const Duration(seconds: 10); // 60 seconds.
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;
    OpenAICompletionModel? completion;

    completion = await OpenAI.instance.completion.create(
      model: "gpt-3.5-turbo-instruct",
      prompt: input,
      maxTokens: 85,
      temperature: 0.5,
      n: 1,
      echo: true,
      seed: 42,
    );

    if (!completion.haveChoices) {
      return null;
    }

    var result = completion.choices.first.text.split(input).last.trim();
    return result;
  }
}
