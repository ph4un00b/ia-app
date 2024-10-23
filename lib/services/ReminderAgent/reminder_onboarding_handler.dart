import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Agents/llm.dart';
import 'package:openai_dart/openai_dart.dart';

import '../../features/Agents/types.dart';
import '../llm_utils.dart';

const llm = LLM.openaiStructuredOutput;

const _prompt = """# SYSTEM

You are a helpful assistant designed to manage reminders for users. Your primary function is to offer reminder services and guide users through the process of setting reminders.

## Current State: START

In this state, your main task is to politely inquire if the user would like to add a reminder.

## State Transitions

Based on the user's response, you can transition to the following states:

1. ADD_REMINDER: If the user expresses interest in adding a reminder.
2. DECLINED: If the user declines to add a reminder.
3. START: If this is the first interaction.

## Instructions

1. Greet the user warmly and introduce yourself as Lola.
2. Ask if they would like to add a reminder today.
3. Listen to their response and determine the appropriate next state.
4. If transitioning to a new state, indicate this at the end of your message using the format: [NEXT_STATE: state_name]
5. If remaining in the current state, do not include a state transition indicator.
In response, add the state you want to transition to (or leave blank to stay in the current state).

## Response Format

Your response should follow this structure:
1. Greeting
2. Offer to add a reminder

Remember to maintain a friendly and helpful tone throughout the interaction.""";

const reminderEditSchema = ResponseFormat.jsonSchema(
  jsonSchema: JsonSchemaObject(
    name: 'onboarding_reminders',
    description: 'a bot asking for onboarding reminders',
    strict: true,
    schema: {
      "type": "object",
      "properties": {
        "bot_reply": {"type": "string"},
        "next_state_key": {
          "type": "string",
          "enum": ["START", "ADD_REMINDER", "DECLINED"]
        }
      },
      "required": ["bot_reply", "next_state_key"],
      "additionalProperties": false,
    },
  ),
);

class ReminderOnboardingHandler {
  static Future<LLMResponse> query(resultInput) async {
    Map<String, dynamic> resultContent = {
      "bot_reply": "",
      "next_state_key": "START"
    };

    // var breakStates = ["FILLED", "NEW_REMINDER"];

    var messages = <ChatCompletionMessage>[];
    messages.add(llm.system(message: _prompt));
    messages.add(llm.user(message: resultInput));

    final client = OpenAIClient(apiKey: Env.openAiKey);

    // TODO: retry, logs, timeout, etc.
    final response = await client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: const ChatCompletionModel.model(ChatCompletionModels.gpt4oMini),
        messages: messages,
        temperature: 0,
        responseFormat: reminderEditSchema,
      ),
    );

    resultContent = await LLMUtils.parseResponseContent(response);

    return resultContent["bot_reply"].isEmpty
        ? const NoneResponse()
        : ReminderResponse(payload: resultContent["bot_reply"]);
  }
}
