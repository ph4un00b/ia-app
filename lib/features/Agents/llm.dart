import 'package:dart_openai/dart_openai.dart';
import 'package:openai_dart/openai_dart.dart';

enum LLM {
  openaiAssistant,
  openaiChat,
  openaiStructuredOutput,
  openaiCompletion;

  const LLM();

  dynamic assistant({required String message}) {
    return switch (this) {
      LLM.openaiAssistant => throw UnimplementedError(),
      LLM.openaiChat => throw UnimplementedError(),
      LLM.openaiStructuredOutput =>
        ChatCompletionMessage.assistant(content: message),
      LLM.openaiCompletion => throw UnimplementedError(),
    };
  }

  dynamic system({required String message}) {
    return switch (this) {
      LLM.openaiAssistant ||
      LLM.openaiChat ||
      LLM.openaiCompletion =>
        _createOpenAIMessage(message, OpenAIChatMessageRole.system),
      LLM.openaiStructuredOutput => ChatCompletionMessage.system(
          content: message,
        ),
    };
  }

  dynamic user({required String message}) {
    return switch (this) {
      LLM.openaiAssistant ||
      LLM.openaiChat ||
      LLM.openaiCompletion =>
        _createOpenAIMessage(message, OpenAIChatMessageRole.user),
      LLM.openaiStructuredOutput => ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(
            message,
          ),
        ),
    };
  }
}

OpenAIChatCompletionChoiceMessageModel _createOpenAIMessage(
  String message,
  OpenAIChatMessageRole role,
) {
  return OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
    ],
    role: role,
  );
}
