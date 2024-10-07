import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Agents/llm.dart';
import 'package:openai_dart/openai_dart.dart';

const String resetColor = '\x1B[0m';
const String redColor = '\x1B[31m';
const String greenColor = '\x1B[32m';
const String yellowColor = '\x1B[33m';
const String blueColor = '\x1B[34m';

enum ResponseType { none, createReminder, reminder, text }

final intentMap = {
  'text': ResponseType.text,
  'reminder': ResponseType.reminder,
  'create_reminder': ResponseType.createReminder,
};

class ClassifyAgent {
  static Future<ResponseType> query(String input, {required LLM llm}) async {
    if (input.isEmpty) {
      return ResponseType.none;
    }

    return switch (llm) {
      LLM.openaiAssistant => throw UnimplementedError(),
      LLM.openaiChat => await _openaiChat(input, llm),
      LLM.openaiCompletion => throw UnimplementedError(),
      LLM.openaiStructuredOutput => await _openaiStructuredOutput(input, llm),
    };
  }

  static Future<ResponseType> _openaiStructuredOutput(
    String input,
    LLM llm,
  ) async {
    Map<String, dynamic> result = {"user_intent": "TEXT"};
    final client = OpenAIClient(apiKey: Env.openAiKey);

    const responseFormat = ResponseFormat.jsonSchema(
      jsonSchema: JsonSchemaObject(
        name: 'Intent_Agent',
        description: 'AI agent responsible for identifying user intent.',
        strict: true,
        schema: {
          "type": "object",
          "properties": {
            "user_intent": {
              "type": "string",
              "enum": ["TEXT", "REMINDER", "CREATE_REMINDER"]
            },
          },
          "required": ["user_intent"],
          "additionalProperties": false,
        },
      ),
    );

    // TODO: retries, logs
    // OpenAI.apiKey = Env.openAiKey;
    // OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    // OpenAI.requestsTimeOut = const Duration(seconds: 10);
    // OpenAI.showLogs = true;
    // OpenAI.showResponsesLogs = true;

    final res = await client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: const ChatCompletionModel.model(
          ChatCompletionModels.gpt4oMini,
        ),
        messages: [
          llm.system(
            message: _prompt(),
          ),
          llm.user(
            message: input,
          ),
        ],
        temperature: 0,
        responseFormat: responseFormat,
      ),
    );

    print(res.choices.first.message.content);

    result = await extractContent(res);
    String intent = result['user_intent'];
    return intentMap[intent.trim().toLowerCase()] ?? ResponseType.none;
  }

  static Future<Map<String, dynamic>> extractContent(
      CreateChatCompletionResponse response) async {
    await trace("$blueColor BEFORE message $resetColor");
    final ChatCompletionAssistantMessage? message = extractMessage(response);
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

  static ChatCompletionAssistantMessage? extractMessage(
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

  static Future<ResponseType> _openaiChat(String input, LLM llm) async {
    OpenAI.apiKey = Env.openAiKey;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut = const Duration(seconds: 10);
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    var response = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        llm.system(message: _prompt()),
        llm.user(message: input),
      ],
      maxTokens: 10,
      temperature: 0,
      n: 1,
    );

    var responseText = response.choices.first.message.content?.first.text ?? "";
    return intentMap[responseText.trim().toLowerCase()] ?? ResponseType.none;
  }

  static String _prompt() {
    return '''# Intent Classification Agent

You are an AI agent specializing in user intent classification. Your task is to analyze user input and categorize it as either "text", "reminder", or "create_reminder" based on the following criteria:

## Classification Rules

### Respond with "text" if:
- The input is a question (e.g., "How do I add a new address?", "What should I do?")
- The input is a greeting (e.g., "Hello", "How are you?", "Hi there", "Como estas lola?")
- The input requests information or recommendations (e.g., "Recomiendame unos libros de terror")
- You are uncertain about the classification

### Respond with "reminder" if:
- The input refers to recurring tasks or duties (e.g., "Que debo hacer los lunes?", "What are my weekend responsibilities?")
- The input indicates a need to recall information (e.g., "Cuándo debo ir al doctor?", "Help me remember my task for today")
- The input asks about scheduled activities (e.g., "What do I need to do on Wednesday?", "When is my next appointment?")

### Respond with "create_reminder" if:
- The input explicitly mentions creating, adding, or setting a reminder (e.g., "quiero agregar un recordatorio", "Crear un recordatorio para el próximo lunes")
- The input refers to scheduling or creating an agenda (e.g., "Add a reminder for the meeting tomorrow at 10:30 am", "Schedule an appointment")

## Important Guidelines:
1. Respond ONLY with "text", "reminder", or "create_reminder" - no additional words or explanations.
2. If in doubt, classify as "text".
3. Consider context and implied actions in the user's input.
4. This classification system should work across multiple languages.
5. Pay attention to keywords that might indicate the need for a reminder or scheduling, even if not explicitly stated.
6. Distinguish between checking existing reminders ("reminder") and creating new ones ("create_reminder").

## Examples:
- "Explain how to add a new address" -> "text"
- "Como estas lola?" -> "text"
- "Recomiendame unos libros de terror" -> "text"
- "What's the weather like today?" -> "text"
- "Schedule an appointment" -> "create_reminder"
- "Remind me to call mom this weekend" -> "create_reminder"
- "que dia debo sacar a los gatos?" -> "reminder"
- "que debo hacer los lunes?" -> "reminder"
- "What's on my to-do list for tomorrow?" -> "reminder"
- "Can you tell me about the history of Rome?" -> "text"
- "Set a reminder for my dentist appointment" -> "create_reminder"
- "What time is my flight tomorrow?" -> "reminder"
- "I'm feeling anxious about my presentation" -> "text"
- "Don't let me forget to buy groceries" -> "create_reminder"
- "What reminders have I set for this month?" -> "reminder"
- "Je dois acheter du pain demain" -> "create_reminder"
- "Wann habe ich meinen nächsten Zahnarzttermin?" -> "reminder"

Remember: Always prioritize accuracy in intent classification to ensure appropriate responses to user queries across various contexts and languages.
    ''';
  }

  @override
  String toString() {
    return 'ClassificationAgent{}';
  }
}
