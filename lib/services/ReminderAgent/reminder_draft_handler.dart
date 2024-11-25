import 'package:lola_ai_app/features/Agents/llm.dart';
import 'package:lola_ai_app/features/App/status.dart';
import 'package:lola_ai_app/features/Reminders/types.dart';
import 'package:lola_ai_app/services/llm_utils.dart';
import 'package:openai_dart/openai_dart.dart';

const llm = LLM.openaiStructuredOutput;

const addReminderPrompt = """# Role: Reminder Assistant

You are a helpful reminder assistant designed to create clear, specific, and actionable reminders for users. Your goal is to ensure each reminder is comprehensive and easy to understand when reviewed later.

## Current State: DRAFT_REMINDER

In the DRAFT_REMINDER state, your main task is to politely inquire if the user would like to continue to NEW_REMINDER state or to edit EDIT_REMINDER state for any changes.
If the user uses some kind of exit sentence go to FILLED state.

## Instructions:

1. When a user adds a reminder, present a summary of the reminder to the user.
2. Ask the user if they want to:
   a) Edit the current reminder
   b) Add a new reminder
   c) Finish the reminder creation process

3. Based on the user's response, transition to one of the following states:
   - EDIT_REMINDER: If the user wants to change or edit the current reminder
   - NEW_REMINDER: If the user expresses interest in creating a new reminder
   - FILLED: If the user declines to add or edit a reminder

4. Use clear, concise language and maintain a friendly, helpful tone throughout the interaction.

## Example Response:

- Great! I've added your reminder: "Call Mom on Sunday, May 14th at 2 PM to wish her a happy Mother's Day. Is there anything you'd like to add or change about this reminder? Or would you like to continue and add a new reminder?"
- Great! I've updated your reminder: "Call Mom on Sunday, May 14th at 2 PM to wish her a happy Mother's Day. Is there anything you'd like to add or change about this reminder? Or would you like to continue and add a new reminder?"
""";

const draftReminderSchema = ResponseFormat.jsonSchema(
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
            },
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

class ReminderDraftHandler {
  static Future<Map<String, dynamic>> query(resultInput) async {
    AppStatus.instance.reminderStatus = ReminderState.draft;

    Map<String, dynamic> resultContent = {
      "bot_reply": "",
      "next_state_key": "DRAFT_REMINDER"
    };

    var breakStates = ["FILLED", "NEW_REMINDER"];

    var messages = <ChatCompletionMessage>[
      llm.system(message: addReminderPrompt),
      llm.assistant(message: ""), // XXX: intentionally left as blank!
      llm.user(message: resultInput)
    ];

    while (!breakStates.contains(resultContent['next_state_key'])) {
      await LLMUtils.logMessages(messages);

      final response =
          await LLMUtils.requestAgent(messages, draftReminderSchema);
      resultContent = await LLMUtils.parseResponseContent(response);

      messages.add(llm.assistant(message: resultContent["bot_reply"]));

      if (breakStates.contains(resultContent['next_state_key'])) break;
      // coming from:
      // - DRAFT_REMINDER
      // awaiting user response for entering the next state:
      // - FILLED
      // - EDIT_REMINDER

      AppStatus.instance.currentReminderChat = messages;
      AppStatus.instance.currentReminder = resultContent;

      return resultContent;
    }

    return resultContent;
  }
}
