import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Agents/llm.dart';
import 'package:openai_dart/openai_dart.dart';

import '../llm_utils.dart';

enum UserInputIntent { approved, change, other }

const _llm = LLM.openaiStructuredOutput;

const _intentMap = {
  'approved': UserInputIntent.approved,
  'change': UserInputIntent.change,
  'other': UserInputIntent.other,
};

const _classificationPrompt = """# Intent Classification Agent

You are an AI agent specializing in user intent classification. Your task is to analyze user input and categorize it into one of three categories: "APPROVED", "CHANGE", or "OTHER".

## Classification Criteria

1. Classify as "APPROVED" if the input:
   - The first part indicates approval.
   - Expresses agreement or approval in the first sentence.
   - Indicates willingness to proceed
   - Examples: "yes", "bien","okay", "sure", "that's fine", "proceed, what's the current time in mexico?", "go ahead", "sounds good"

2. Classify as "CHANGE" if the input:
   - Requests a modification to a setting, preference, or schedule
   - Expresses a desire to alter something
   - Examples: "reschedule to 3pm", "switch to weekly", "make it louder", "change the color"

3. Classify as "OTHER" if the input:
   - Expresses uncertainty or confusion
   - States a fact or personal preference
   - Asks a question or makes a joke
   - Doesn't clearly fit into the "APPROVED" or "CHANGE" categories
   - Examples: "I'm not sure", "what does that mean?", "I prefer blue", "tell me a joke"

## Instructions

1. Carefully analyze the user's input.
2. Separate different parts of the input.
3. Determine which category best fits the input based on the criteria above.
4. If you're unsure about the classification, err on the side of caution and choose "OTHER".

""";

const _checkerInputSchema = ResponseFormat.jsonSchema(
  jsonSchema: JsonSchemaObject(
    name: 'input_checker',
    description: 'AI agent responsible for classifying user input.',
    strict: true,
    schema: {
      "type": "object",
      "properties": {
        "classification": {
          "type": "string",
          "description": "APPROVED | CHANGE | OTHER",
          "enum": ["APPROVED", "CHANGE", "OTHER"]
        },
        "explanation": {
          "type": "string",
          "description":
              "Brief explanation of why this classification was chosen",
        },
        "additional_info": {
          "type": "string",
          "description":
              "Any extra information or observations about the sentence",
        },
        "language_detected": {
          "type": "string",
          "description": "The language of the input sentence",
        },
      },
      "required": [
        "classification",
        "explanation",
        "additional_info",
        "language_detected"
      ],
      "additionalProperties": false,
    },
  ),
);

class ReminderInputChecker {
  static Future<UserInputIntent> query(String userInput) async {
    if (userInput.isEmpty) {
      // TODO: Decide on default behavior for empty input
      return UserInputIntent.approved;
    }

    Map<String, dynamic> result = {};
    final client = OpenAIClient(apiKey: Env.openAiKey);

    // TODO: retries, logs
    // OpenAI.apiKey = Env.openAiKey;
    // OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    // OpenAI.requestsTimeOut = const Duration(seconds: Constants.maxTimeout);
    // OpenAI.showLogs = true;
    // OpenAI.showResponsesLogs = true;

    final response = await client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: const ChatCompletionModel.model(
          ChatCompletionModels.gpt4oMini,
        ),
        messages: [
          _llm.system(message: _classificationPrompt),
          _llm.user(message: userInput),
        ],
        temperature: 0,
        responseFormat: _checkerInputSchema,
      ),
    );

    result = await LLMUtils.parseResponseContent(response);
    String intentClassification = result['classification'];
    return _intentMap[intentClassification.trim().toLowerCase()] ??
        UserInputIntent.other;
  }
}
