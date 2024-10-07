import 'package:dart_openai/dart_openai.dart';
import 'package:openai_dart/openai_dart.dart';

enum LLM {
  openaiAssistant,
  openaiChat,
  openaiStructuredOutput,
  openaiCompletion;

  const LLM();

  dynamic system({required String message}) {
    return switch (this) {
      LLM.openaiAssistant => OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              message,
            ),
          ],
          role: OpenAIChatMessageRole.system,
        ),
      LLM.openaiChat => OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              message,
            ),
          ],
          role: OpenAIChatMessageRole.system,
        ),
      LLM.openaiCompletion => OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              message,
            ),
          ],
          role: OpenAIChatMessageRole.system,
        ),
      LLM.openaiStructuredOutput => ChatCompletionMessage.system(
          content: message,
        ),
    };
  }

  dynamic user({required String message}) {
    return switch (this) {
      LLM.openaiAssistant => OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              message,
            ),
          ],
          role: OpenAIChatMessageRole.user,
        ),
      LLM.openaiChat => OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              message,
            ),
          ],
          role: OpenAIChatMessageRole.user,
        ),
      LLM.openaiCompletion => OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              message,
            ),
          ],
          role: OpenAIChatMessageRole.user,
        ),
      LLM.openaiStructuredOutput => ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(
            message,
          ),
        ),
    };
  }
}
