import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Agents/llm.dart';
import 'package:lola_ai_app/main.dart';
import 'package:lola_ai_app/services/llm_utils.dart';
import 'package:openai_dart/openai_dart.dart';

const llm = LLM.openaiStructuredOutput;

const schema = ResponseFormat.jsonSchema(
  jsonSchema: JsonSchemaObject(
    name: 'transient_answer',
    description: 'transient state model',
    strict: true,
    schema: {
      "type": "object",
      "properties": {
        "title": {"type": "string"},
        "description": {"type": "string"},
        "category": {"type": "string"},
        "kind": {
          "type": "string",
          "enum": ["DAILY", "WEEKLY", "MONTHLY", "ONE_TIME"]
        },
        "day": {
          "anyOf": [
            {
              "type": "string",
              "enum": [
                "MONDAY",
                "TUESDAY",
                "WEDNESDAY",
                "THURSDAY",
                "FRIDAY",
                "SATURDAY",
                "SUNDAY"
              ]
            },
            {"type": "null"}
          ]
        },
        "modifier": {
          "anyOf": [
            {
              "type": "string",
              "enum": ["FIRST", "SECOND", "THIRD", "FOURTH", "LAST", "EVERY"]
            },
            {"type": "null"}
          ]
        },
        "date": {
          "anyOf": [
            // {"type": "string", "format": "date"}, NOT PERMITTED
            {"type": "string"},
            {"type": "null"}
          ]
        },
        "endDate": {
          "anyOf": [
            // {"type": "string", "format": "date"},
            {"type": "string"},
            {"type": "null"}
          ]
        },
        "repeat": {
          "anyOf": [
            // {"type": "integer", "minimum": 1}, // NOT PERMITTED
            {"type": "integer"},
            {"type": "null"}
          ]
        },
        "time": {
          "anyOf": [
            {
              // "items": {"type": "string", "format": "time"} // NOT PERMITTED
              "type": "string",
              "enum": [
                "00:00",
                "01:00",
                "02:00",
                "03:00",
                "04:00",
                "05:00",
                "06:00",
                "07:00",
                "08:00",
                "09:00",
                "10:00",
                "11:00",
                "12:00",
                "13:00",
                "14:00",
                "15:00",
                "16:00",
                "17:00",
                "18:00",
                "19:00",
                "20:00",
                "21:00",
                "22:00",
                "23:00"
              ]
            },
            {"type": "null"}
          ]
        },
        "dayTime": {
          "anyOf": [
            {
              // "items": {"type": "string", "format": "time"} // NOT PERMITTED
              "type": "string",
              "enum": [
                "MORNING",
                "AFTERNOON",
                "EVENING",
                "EARLY_MORNING",
                "MIDDAY",
                "MIDNIGHT",
              ]
            },
            {"type": "null"}
          ]
        },
        "interval": {
          "anyOf": [
            {
              "type": "object",
              "properties": {
                // "value": {"type": "integer", "exclusiveMinimum": 0}, // NOT PERMITTED
                "value": {"type": "integer"},
                "unit": {
                  "type": "string",
                  "enum": ["MINUTES", "HOURS", "DAYS", "MONTH"]
                }
              },
              "required": ["value", "unit"],
              "additionalProperties": false
            },
            {"type": "null"}
          ]
        },
        "priority": {
          "type": "string",
          "enum": ["NORMAL", "HIGH"]
        },
        "notificationType": {
          "type": "string",
          "enum": ["APP", "EMAIL", "SMS"],
          "default": "APP"
        },
        // "isCompleted": {"type": "boolean", "default": false} // NOT PERMITTED
        "isCompleted": {"type": "boolean"},
        "bot_reply": {"type": "string"},
        "next_state_key": {
          "anyOf": [
            {
              "type": "string",
              "enum": [
                "DRAFT_REMINDER",
                "EDIT_REMINDER",
                "NEW_REMINDER",
                "FILLED"
              ]
            }
          ]
        }
      },
      "required": [
        "title",
        "description",
        "category",
        "kind",
        "day",
        "modifier",
        "date",
        "endDate",
        "repeat",
        "time",
        "dayTime",
        "interval",
        "priority",
        "notificationType",
        "isCompleted",
        "bot_reply",
        "next_state_key"
      ],
      "additionalProperties": false,
    },
  ),
);

class ReminderEditedHandler {
  static Future<Map<String, dynamic>> query(String input) async {
    var messages = AppStatus.instance.currentReminderChat;
    messages.add(llm.user(message: input));

    Map<String, dynamic> resultContent = {
      "bot_reply": "",
      "next_state_key": "DRAFT_REMINDER"
    };

    final client = OpenAIClient(apiKey: Env.openAiKey);

    // TODO: retry, logs, timeout, etc.
    // TODO: on error
    final response = await client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: const ChatCompletionModel.model(ChatCompletionModels.gpt4oMini),
        messages: messages,
        temperature: 0,
        responseFormat: schema,
      ),
    );

    resultContent = await LLMUtils.parseResponseContent(response);

    messages.add(llm.assistant(message: resultContent["bot_reply"]));
    AppStatus.instance.currentReminderChat = messages;
    AppStatus.instance.currentReminder = resultContent;

    return resultContent;
  }
}
