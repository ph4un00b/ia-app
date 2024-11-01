import 'dart:io';

import 'package:lola_ai_app/features/Agents/reminder_agent.dart';
import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/main.dart';
import 'package:lola_ai_app/services/ReminderAgent/reminder_draft_handler.dart';
import 'package:lola_ai_app/services/ReminderAgent/reminder_edit_handler.dart';
import 'package:lola_ai_app/services/ReminderAgent/reminder_edited_handler.dart';
import 'package:lola_ai_app/services/ReminderAgent/reminder_filled_handler.dart';
import 'package:lola_ai_app/services/ReminderAgent/reminder_input_checker.dart';
import 'package:path/path.dart' as p;

// TODO: checar que hacer cuando la intention es none
class LolaResponse {
  static Future<LolaResult> query({
    required bool debug,
    required String userQuery,
    required VoiceLola voiceModel,
  }) async {
    final userIntent = await StructuredAgent.classification.query(userQuery);

    if (_midReminderInterruption()) {
      final _ = switch (userIntent) {
        IntentKind.text ||
        IntentKind.none ||
        IntentKind.greeting =>
          _handleReminderCreation(userQuery, voiceModel),
        // TODO: mecionar en algun lado que se guardo el recordatorio
        IntentKind.createReminder || IntentKind.reminder => {},
      };
    }

    if (AppStatus.instance.currentStatus == AppState.onboarding &&
        userIntent != IntentKind.createReminder &&
        userIntent != IntentKind.reminder) {
      return AppStatus.instance.reminderStatus == ReminderState.idle
          ? await _reminderExampleResponse(voiceModel)
          : await _handleOnboarding(userQuery, voiceModel);
    }

    return switch (AppStatus.instance.currentStatus) {
      AppState.active => _handleUserQuery(userQuery, voiceModel, userIntent),
      AppState.onboarding => _handleOnboarding(userQuery, voiceModel),
      AppState.idle || AppState.auth => throw StateError(
          "${AppStatus.instance.currentStatus} state not implmented"),
    };
  }

  static Future<LolaResult> _reminderExampleResponse(
      VoiceLola voiceModel) async {
    const message = "Hola! Necesitas crear un recordatorio primero. "
        "Puedes mencionar algo como: 'Recuerdame preparar yogurt los sabados por la mañana.'";
    final speechFile = await voiceModel.synthesize(text: message);
    return LolaResult(
      p.normalize(speechFile.path),
      message,
    );
  }

  static bool _midReminderInterruption() {
    return AppStatus.instance.lolaStatus == LolaState.creatingReminder &&
        AppStatus.instance.reminderStatus != ReminderState.filled;
  }

  static Future<LolaResult> _handleUserQuery(
    String userQuery,
    VoiceLola voiceModel,
    IntentKind userIntent,
  ) async {
    final lolaStatus = AppStatus.instance.lolaStatus;
    final isCreateReminder = userIntent == IntentKind.createReminder;
    final isAskReminder = userIntent == IntentKind.reminder;

    return switch (lolaStatus) {
      LolaState.idle ||
      LolaState.running when isCreateReminder =>
        await _handleReminderCreation(userQuery, voiceModel),
      LolaState.idle ||
      LolaState.running when isAskReminder =>
        await _askLola(userQuery, voiceModel),
      LolaState.idle ||
      LolaState.running =>
        await _askLola(userQuery, voiceModel),
      LolaState.creatingReminder => await _handleReminderCreation(userQuery, voiceModel),
    };
  }

  /**
   * CASO 1. Onboarding:
   * 1. user: recuerdame beber soda lunes en la noche
   * 2. user: cambia a viernes
   * 3. user: todo perfecto
   *  - guarda el recordatorio
   * 4. user: quien es el presidente de argentina?
   *
   * CASO 2. Onboarding:
   * 1. user: recuerdame beber soda lunes en la noche
   * 2. user: todo perfecto
   *  - guarda el recordatorio
   * 3. user: quien es el presidente de argentina?
   *
   * CASO 3. Onboarding: te lleva hasta llegar a status "filled"
   * 1. user: recuerdame beber soda lunes en la noche
   * 2. user: quien es el presidente de argentina?
   */
  static Future<LolaResult> _handleOnboarding(
    String userQuery,
    VoiceLola voiceModel,
  ) async {
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
      ReminderState.draft => await () async {
          final reminderIntent = await ReminderInputChecker.query(userQuery);
          print('Input type: $reminderIntent');

          return switch (reminderIntent) {
            UserInputIntent.change => () async {
                final editResult = await ReminderEditHandler.query(userQuery);
                final botReply = editResult['bot_reply'];

                AppStatus.instance.reminderStatus = ReminderState.edited;
                return ReminderResponse(
                  payload: botReply,
                  status: ReminderState.edited,
                );
              }(),
            UserInputIntent.approved || UserInputIntent.other => () async {
                final filledResult =
                    await ReminderFilledHandler.query(userQuery);
                print('Reminder change result: $filledResult');
                final botReply = filledResult['bot_reply'];

                AppStatus.instance.reminderStatus = ReminderState.filled;
                return ReminderResponse(
                  payload: botReply,
                  status: ReminderState.filled,
                );
              }(),
          };
        }(),
      ReminderState.edited => await editedReminder(userQuery),
      ReminderState.filled => await () async {
          await ReminderAgent.updateReminders();

          return ReminderResponse(
            payload: userQuery,
            status: ReminderState.idle,
          );
        }(),
      // throw StateError("filled reminder status not imp%lemented"),
    };

    return switch (response) {
      ReminderResponse(payload: final payload, status: ReminderState.idle) ||
      ReminderResponse(payload: final payload, status: ReminderState.draft) ||
      ReminderResponse(payload: final payload, status: ReminderState.edited) =>
        LolaResult(
          p.normalize((await voiceModel.synthesize(text: payload)).path),
          payload,
        ),
      ReminderResponse(payload: final payload, status: ReminderState.filled) =>
        _handleOnboarding(payload, voiceModel),
      ReminderResponse(payload: final payload) when payload.isEmpty =>
        throw LolaResponseException('Empty response'),
      _ => throw LolaResponseException('Unexpected response'),
    };
  }

  /**
   * CASO 1. Active:
   * 1. user: recuerdame beber soda lunes en la noche
   * 2. user: cambia a viernes
   * 3. user: quien es el presidente de argentina?
   *  - guarda el recordatorio
   *
   * CASO 2. Active:
   * 1. user: recuerdame beber soda lunes en la noche
   * 2. user: que es el presidente de argentina?
   *  - guarda el recordatorio
   *
   * CASO 3. Active: todo
   * 1. user: recuerdame beber soda lunes en la noche
   * 2. user: cambia a viernes
   * 3. user: todo perfecto
   *  - guarda el recordatorio
   * 3. user: quien es el presidente de argentina?
   *
   * CASO 4. Active:
   * 1. user: recuerdame beber soda lunes en la noche
   * 2. user: todo perfecto
   *  - guarda el recordatorio
   * 3. user: que es el presidente de argentina?
   */
  static Future<LolaResult> _handleReminderCreation(
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
      ReminderState.draft => await () async {
          final reminderIntent = await ReminderInputChecker.query(userQuery);
          print('Input type: $reminderIntent');

          return switch (reminderIntent) {
            UserInputIntent.change => () async {
                final editResult = await ReminderEditHandler.query(userQuery);
                final botReply = editResult['bot_reply'];

                AppStatus.instance.reminderStatus = ReminderState.edited;
                return ReminderResponse(
                  payload: botReply,
                  status: ReminderState.edited,
                );
              }(),
            UserInputIntent.approved || UserInputIntent.other => () async {
                final filledResult =
                    await ReminderFilledHandler.query(userQuery);
                print('Reminder change result: $filledResult');
                final botReply = filledResult['bot_reply'];

                AppStatus.instance.reminderStatus = ReminderState.filled;
                return ReminderResponse(
                  payload: botReply,
                  status: ReminderState.filled,
                );
              }(),
          };
        }(),
      ReminderState.edited => await editedReminder(userQuery),
      ReminderState.filled => await () async {
          await ReminderAgent.updateReminders();

          return ReminderResponse(
            payload: userQuery,
            status: ReminderState.idle,
          );
        }(),
    };

    return switch (response) {
      ReminderResponse(payload: final payload, status: ReminderState.idle) ||
      ReminderResponse(payload: final payload, status: ReminderState.draft) ||
      ReminderResponse(payload: final payload, status: ReminderState.edited)  =>
        LolaResult(
          p.normalize((await voiceModel.synthesize(text: payload)).path),
          payload,
        ),
       ReminderResponse(payload: final payload, status: ReminderState.filled) =>
        _handleReminderCreation(payload, voiceModel),
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
    final userIntent = await StructuredAgent.classification.query(userQuery);
    print('agentKind: $userIntent');

    if (userIntent == IntentKind.createReminder &&
        AppStatus.instance.reminderStatus == ReminderState.idle) {
      final response = await Agent.text.query(userQuery);

      AppStatus.instance.reminderStatus = ReminderState.create;
      AppStatus.instance.lolaStatus = LolaState.creatingReminder;

      if (response.payload.isEmpty) {
        throw LolaResponseException('empty response');
      }

      File speechFile = await voiceModel.synthesize(text: response.payload);
      String path = p.normalize(speechFile.path);

      return LolaResult(path, response.payload);
    }

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
      UserInputIntent.approved || UserInputIntent.other => () async {
          final filledResult = await ReminderFilledHandler.query(userInput);
          print('Reminder change result: $filledResult');
          final botReply = filledResult['bot_reply'];

          AppStatus.instance.reminderStatus = ReminderState.filled;
          return ReminderResponse(
            payload: botReply,
            status: ReminderState.filled,
          );
        }(),
    };
  }
}
