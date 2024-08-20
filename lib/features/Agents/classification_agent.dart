import 'package:dart_openai/dart_openai.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Agents/llm.dart';
import 'package:lola_ai_app/features/Agents/types.dart';

class ClassifyAgent {
  static Future<LLMResponse> query(String input, {required LLM llm}) async {
    if (input.isEmpty) {
      return const NoneResponse();
    }

    String? responseText = switch (llm) {
      LLM.openaiAssistant => throw UnimplementedError(),
      LLM.openaiChat => await _openaiChat(input, llm),
      LLM.openaiCompletion => throw UnimplementedError()
    };

    if (responseText == null) {
      return const NoneResponse();
    } else if (responseText.contains('reminder')) {
      return const ReminderResponse();
    } else {
      return const TextResponse();
    }
  }

  static Future<String?> _openaiChat(String input, LLM llm) async {
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

    var responseText = response.choices.first.message.content?.first.text;
    return responseText;
  }

  static String _prompt() {
    return '''
You are an AI agent responsible for identifying user intent. Your task is to analyze user input and determine whether the appropriate response should be "text" or "reminder".

Classification Rules:

Respond with "text" if:

- The input is a question (e.g., "How do I add a new address?", "What should I do?", "How much does it cost?")
- The input is a greeting (e.g., "Hello", "How are you?", "Hi there", "Como estas lola?")
- The input is a request for information or recommendations (e.g., "Recomiendame unos libros de terror")
- You are unsure about the classification

Respond with "reminder" if:
- The input indicate "weekly tasks" o "weekly duties" (e.g., "Que debo hacer los lunes?", "Que debo hacer los fines de semana?")
- The input indicates a need to remember or be reminded of something (e.g., "Cuándo debo ir al doctor?", "Help me remember my task for today", "What do I need to do on Wednesday?", "When do I need to go to the doctor?")
- The input explicitly mentions setting a reminder or scheduling (e.g., "Add a reminder for the meeting tomorrow at 10:30 am", "Schedule an appointment")

Important Notes:

- Always respond with ONLY "text" or "reminder" - no other words or explanations.
- If in doubt, default to "text".
- Consider the context and implied actions in the user's input.
- The classification should work across different languages.

Examples:

- "Explain how to add a new address" -> "text"
- "Como estas lola?" -> "text"
- "Recomiendame unos libros de terror" -> "text"
- "What's the weather like today?" -> "text"
- "Schedule an appointment" -> "reminder"
- "Remind me to call mom this weekend" -> "reminder"
- "que dia debo sacar a los gatos?" -> "reminder"
- "que debo hacer los lunes?" -> "reminder"
- "What's on my to-do list for tomorrow?" -> "reminder"
- "Can you tell me about the history of Rome?" -> "text"
    ''';
  }

  @override
  String toString() {
    return 'ClassificationAgent{}';
  }
}
