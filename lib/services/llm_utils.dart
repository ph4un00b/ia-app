import 'dart:convert';

import 'package:lola_ai_app/config/env.dart';
import 'package:openai_dart/openai_dart.dart';

const String resetColor = '\x1B[0m';
const String redColor = '\x1B[31m';
const String greenColor = '\x1B[32m';
const String yellowColor = '\x1B[33m';
const String blueColor = '\x1B[34m';

class LLMUtils {
  static Future<CreateChatCompletionResponse> requestAgent(
    List<ChatCompletionMessage> messages,
    ResponseFormat responseFormat,
  ) async {
    final client = OpenAIClient(apiKey: Env.openAiKey);

    return client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: const ChatCompletionModel.model(ChatCompletionModels.gpt4oMini),
        messages: messages,
        temperature: 0,
        responseFormat: responseFormat,
      ),
    );
  }

  static Future<Map<String, dynamic>> parseResponseContent(
      CreateChatCompletionResponse response) async {
    await trace("$blueColor BEFORE message $resetColor");
    final ChatCompletionAssistantMessage? message = assistantMessage(response);
    await trace("$blueColor AFTER message $resetColor");

    return switch (message) {
      ChatCompletionAssistantMessage(content: final content?) => () async {
          await trace("\nParsed content:");
          final parsedContent = jsonDecode(content) as Map<String, dynamic>;
          await trace(prettify(parsedContent));
          return parsedContent;
        }(),
      ChatCompletionAssistantMessage(refusal: final refusal?) =>
        throw StateError("Request refused by the model: $refusal"),
      ChatCompletionAssistantMessage() => throw StateError(
          "Unexpected message format: content and refusal are both null"),
      null => throw StateError("No message available in the response"),
    };
  }

  static ChatCompletionAssistantMessage? assistantMessage(
      CreateChatCompletionResponse response) {
    return switch (response.choices.firstOrNull?.finishReason) {
      null => throw StateError("No choices in response"),
      ChatCompletionFinishReason.stop => response.choices.firstOrNull?.message,
      ChatCompletionFinishReason.length =>
        throw StateError("Max length reached"),
      ChatCompletionFinishReason.toolCalls =>
        throw StateError("Unexpected tool calls"),
      ChatCompletionFinishReason.contentFilter =>
        throw StateError("Content filtered"),
      ChatCompletionFinishReason.functionCall =>
        throw StateError("Unexpected function call"),
    };
  }

  static String prettify(dynamic data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<void> trace(String txt) async {
    // await sleep(const Duration(seconds: 0));
    print(txt);
  }

  static Future<void> sleep(Duration duration) async {
    await Future.delayed(duration);
  }

  static Future<void> logMessages(List<ChatCompletionMessage> messages) async {
    await trace('$blueColor MESSAGES $resetColor');
    for (final message in messages) {
      await trace('\n$redColor$message$resetColor');
    }
    await trace('$blueColor REQUESTING COMPLETION $resetColor');
  }
}
