import 'dart:async';

import 'package:lola_ai_app/features/Agents/reminder_agent.dart';
import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/App/status.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Reminders/types.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:path/path.dart' as p;

import '../reminder_draft_handler.dart';
import '../reminder_edit_handler.dart';
import '../reminder_edited_handler.dart';
import '../reminder_filled_handler.dart';
import '../reminder_input_checker.dart';

final class CreateReminderHandler {
  /// CASO 1. Active:
  /// 1. user: recuerdame beber lechita caliente lunes en la tarde
  /// 2. user: cambia a martes
  /// 3. user: quien es el presidente de mexico?
  ///  - guarda el recordatorio
  ///  - no responde la pregunta (esperado)
  ///
  /// CASO 2. Active:
  /// 1. user: recuerdame beber vino lunes en la noche
  /// 2. user: quien es el presidente de venezuela?
  ///  - guarda el recordatorio
  ///  - no responde la pregunta (esperado)
  ///
  /// CASO 3. Active: todo
  /// 1. user: recuerdame preparar yogurt el sabado en la mañana
  /// 2. user: cambialo para domingo
  /// 3. user: todo bien
  ///  - guarda el recordatorio
  /// 4. user: quien es el presidente de argentina?
  ///
  /// CASO 4. Active:
  /// 1. user: recuerdame beber cerveza el jueves a mediodía
  /// 2. user: todo perfecto
  ///  - guarda el recordatorio
  /// 3. user: que es el presidente de peru?
  static Future<LolaResult> handle(
    String userQuery,
    VoiceLola voiceModel,
  ) async {
    AppStatus.instance.lolaStatus = LolaState.creatingReminder;
    final reminderStatus = AppStatus.instance.reminderStatus;

    ReminderResponse response = switch (reminderStatus) {
      ReminderState.idle => await (String userInput) async {
          final draftResult = await ReminderDraftHandler.query(userInput);
          final botReply = draftResult['bot_reply'];

          unawaited(AppEvent.reminderDraft.track(params: {"from": "idle"}));
          return ReminderResponse(
            payload: botReply,
            status: ReminderState.draft,
          );
        }(userQuery),
      ReminderState.create => await (String userInput) async {
          final draftResult = await ReminderDraftHandler.query(userInput);
          final botReply = draftResult['bot_reply'];

          unawaited(AppEvent.reminderDraft.track(params: {"from": "create"}));
          return ReminderResponse(
            payload: botReply,
            status: ReminderState.draft,
          );
        }(userQuery),
      ReminderState.draft => await () async {
          final reminderIntent = await ReminderInputChecker.query(userQuery);

          return switch (reminderIntent) {
            UserInputIntent.change => () async {
                final editResult = await ReminderEditHandler.query(userQuery);
                final botReply = editResult['bot_reply'];

                AppStatus.instance.reminderStatus = ReminderState.edited;
                unawaited(AppEvent.reminderEdited.track());
                return ReminderResponse(
                  payload: botReply,
                  status: ReminderState.edited,
                );
              }(),
            UserInputIntent.approved || UserInputIntent.other => () async {
                final filledResult =
                    await ReminderFilledHandler.query(userQuery);
                final botReply = filledResult['bot_reply'];

                AppStatus.instance.reminderStatus = ReminderState.filled;
                unawaited(AppEvent.reminderFilled.track());
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

          unawaited(AppEvent.reminderIdle.track());
          return ReminderResponse(
            payload: userQuery,
            status: ReminderState.idle,
          );
        }(),
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
        handle(payload, voiceModel),
      ReminderResponse(payload: final payload) when payload.isEmpty =>
        throw LolaResponseException('Empty response'),
      _ => throw LolaResponseException('Unexpected response'),
    };
  }

  static Future<ReminderResponse> editedReminder(String userInput) async {
    final reminderIntent = await ReminderInputChecker.query(userInput);

    return switch (reminderIntent) {
      UserInputIntent.change => () async {
          final editedResult = await ReminderEditedHandler.query(userInput);
          final botReply = editedResult['bot_reply'];

          AppStatus.instance.reminderStatus = ReminderState.edited;
          unawaited(AppEvent.reminderEdited.track());
          return ReminderResponse(
            payload: botReply,
            status: ReminderState.edited,
          );
        }(),
      UserInputIntent.approved || UserInputIntent.other => () async {
          final filledResult = await ReminderFilledHandler.query(userInput);
          final botReply = filledResult['bot_reply'];

          AppStatus.instance.reminderStatus = ReminderState.filled;
          unawaited(AppEvent.reminderFilled.track());
          return ReminderResponse(
            payload: botReply,
            status: ReminderState.filled,
          );
        }(),
    };
  }
}
