import 'dart:io';

import 'package:lola_ai_app/features/Agents/reminder_agent.dart';
import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/main.dart';
import 'package:lola_ai_app/services/ReminderAgent/reminder_draft_handler.dart';
import 'package:lola_ai_app/services/ReminderAgent/reminder_edit_handler.dart';
import 'package:lola_ai_app/services/ReminderAgent/reminder_agent.dart';
import 'package:lola_ai_app/services/ReminderAgent/reminder_input_checker.dart';
import 'package:path/path.dart' as p;

class LolaResponse {
  static Future<LolaResult> query({
    required String userQuery,
    required VoiceLola voiceModel,
    required bool debug,
  }) async {
    final userIntent = await StructuredAgent.classification.query(userQuery);

    if (AppStatus.instance.lolaStatus == LolaState.creatingReminder) {
      final _ = switch (userIntent) {
        IntentKind.text ||
        IntentKind.greeting ||
        IntentKind.none =>
          await ReminderAgent.updateReminders(),
        IntentKind.createReminder || IntentKind.reminder => {},
      };
    }

    return switch (AppStatus.instance.lolaStatus) {
      LolaState.creatingReminder ||
      LolaState.idle ||
      LolaState.running =>
        _handle(userIntent, userQuery, voiceModel),
      LolaState.auth => throw StateError("lola auth not implemented"),
      LolaState.onboarding => throw StateError("onboarding not implemented"),
    };
  }

  static Future<LolaResult> _handle(
    IntentKind userIntent,
    String userQuery,
    VoiceLola voiceModel,
  ) {
    return switch (userIntent) {
      IntentKind.createReminder => _setReminder(userQuery, voiceModel),
      IntentKind.text ||
      IntentKind.greeting ||
      IntentKind.reminder ||
      IntentKind.none =>
        _askLola(userQuery, voiceModel),
    };
  }

  // TODO: look for flutter feedback loop implementations
  static Future<LolaResult> _setReminder(
    String userQuery,
    VoiceLola voiceModel,
  ) async {
    AppStatus.instance.lolaStatus = LolaState.creatingReminder;
    final reminderStatus = AppStatus.instance.reminderStatus;

    ReminderResponse response = switch (reminderStatus) {
      ReminderState.idle => await (String userInput) async {
          final draftResult = await ReminderDraftHandler.query(userInput);
          final botReply = draftResult['bot_reply'];

          return ReminderResponse(
            payload: botReply,
            status: ReminderState.draft,
          );
        }(userQuery),
      ReminderState.create => await (String userInput) async {
          final draftResult = await ReminderDraftHandler.query(userInput);
          final botReply = draftResult['bot_reply'];

          return ReminderResponse(
            payload: botReply,
            status: ReminderState.draft,
          );
        }(userQuery),
      ReminderState.draft => await (String resultInput) async {
          final editResult = await ReminderEditHandler.query(resultInput);
          final botReply = editResult['bot_reply'];

          return ReminderResponse(
            payload: botReply,
            status: ReminderState.edited,
          );
        }(userQuery),
      ReminderState.edited => await editedReminder(userQuery),
      ReminderState.filled =>
        throw StateError("filled reminder status not implemented"),
    };

    return switch (response) {
      ReminderResponse(payload: final payload, status: ReminderState.draft) ||
      ReminderResponse(payload: final payload, status: ReminderState.edited) =>
        LolaResult(
          p.normalize((await voiceModel.synthesize(text: payload)).path),
          payload,
        ),
      ReminderResponse(payload: final payload, status: ReminderState.filled) =>
        await _askLola(payload, voiceModel),
      ReminderResponse(payload: final payload) when payload.isEmpty =>
        throw LolaResponseException('Empty response'),
      _ => throw LolaResponseException('Unexpected response'),
    };
  }

  static Future<LolaResult> _askLola(
    userQuery,
    VoiceLola voiceModel,
  ) async {
    AppStatus.instance.lolaStatus = LolaState.running;
    // TODO: remover classifier?
    AppStatus.instance.lolaStatus = LolaState.running;
    final userIntent = await StructuredAgent.classification.query(userQuery);
    print('agentKind: $userIntent');

    LLMResponse response = switch (userIntent) {
      IntentKind.none => const NoneResponse(),
      IntentKind.createReminder => await (userQuery) async {
          AppStatus.instance.lolaStatus = LolaState.creatingReminder;
          AppStatus.instance.reminderStatus = ReminderState.create;
          print('reminder: currentState: ${AppStatus.instance.lolaStatus}');
          return Agent.reminder.query(userQuery);
        }(userQuery),
      IntentKind.reminder => await Agent.reminder.query(userQuery),
      IntentKind.text => await Agent.text.query(userQuery),
      IntentKind.greeting =>
        throw StateError("greeting response not implemented"),
    };

    if (response.payload.isEmpty) {
      throw LolaResponseException('empty response');
    }

    File speechFile = await voiceModel.synthesize(text: response.payload);
    String path = p.normalize(speechFile.path);

    return LolaResult(path, response.payload);
  }

  static Future<ReminderResponse> editedReminder(String userInput) async {
    final reminderIntent = await ReminderInputChecker.query(userInput);
    print('Input type: $reminderIntent');

    return switch (reminderIntent) {
      UserInputIntent.change => () async {
          final editedResult = await ReminderEditedHandler.query(userInput);
          print('Reminder change result: $editedResult');
          final botReply = editedResult['bot_reply'];

          AppStatus.instance.reminderStatus = ReminderState.edited;
          return ReminderResponse(
            payload: botReply,
            status: ReminderState.edited,
          );
        }(),
      UserInputIntent.approved || UserInputIntent.other => () {
          AppStatus.instance.reminderStatus = ReminderState.filled;
          return ReminderResponse(
            payload: userInput,
            status: ReminderState.filled,
          );
        }(),
    };
  }
}
