import 'package:dart_openai/dart_openai.dart';

enum LLM {
  openaiAssistant,
  openaiChat,
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
    };
  }
}