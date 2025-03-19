import 'dart:async';

import 'package:lola_ai_app/features/Agents/reminder_agent.dart';
import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/App/status.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Reminders/types.dart';
import 'package:lola_ai_app/features/core/types.dart';

import '../reminder_draft_handler.dart';
import '../reminder_edit_handler.dart';
import '../reminder_edited_handler.dart';
import '../reminder_filled_handler.dart';
import '../reminder_input_checker.dart';

final class OnboardingReminderHandler {
  /// CASO 1. Onboarding:
  /// 1. user: recuerdame comer pizza el lunes a la mañana
  /// 2. user: cambia a martes
  /// 3. user: todo perfecto
  ///  - guarda el recordatorio
  /// 4. user: quien fue el primer presidente de argentina?
  ///
  /// CASO 2. Onboarding:
  /// 1. user: recuerdame comer pollo todos los dias por un mes
  /// 2. user: todo perfecto
  ///  - guarda el recordatorio
  /// 3. user: quien fue el primer presidente de mexico?
  ///
  /// CASO 3. Onboarding: te lleva hasta llegar a status "filled"
  /// 1. user: recuerdame comer tacos el sabado a media noche
  /// 2. user: quien fue el primer presidente de peru?
  /// - no contesta (esperado)
  static Future<LolaTextResult> handle(
    String userQuery,
    VoiceLola voiceModel,
  ) async {
    AppStatus.instance.lolaStatus = LolaState.creatingReminder;
    final reminderStatus = AppStatus.instance.reminderStatus;

    ReminderResponse response = switch (reminderStatus) {
      ReminderState.idle => await (String userInput) async {
          final draftResult = await ReminderDraftHandler.query(userInput);
          final botReply = draftResult['bot_reply'];
          final otherProperties = Map.from(draftResult)..remove('bot_reply');

          unawaited(AppEvent.reminderDraft.track(
              params: {"from": "idle", "userStatus": AppStatus.instance.currentUserStatus.name, ...otherProperties}));
          return ReminderResponse(
            payload: botReply,
            status: ReminderState.draft,
          );
        }(userQuery),
      ReminderState.create => await (String userInput) async {
          final draftResult = await ReminderDraftHandler.query(userInput);
          final botReply = draftResult['bot_reply'];
          final otherProperties = Map.from(draftResult)..remove('bot_reply');

          unawaited(AppEvent.reminderDraft.track(
              params: {"from": "create", "userStatus": AppStatus.instance.currentUserStatus.name, ...otherProperties}));
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
                final otherProperties = Map.from(editResult)..remove('bot_reply');

                AppStatus.instance.reminderStatus = ReminderState.edited;
                unawaited(AppEvent.reminderEdited
                    .track(params: {"userStatus": AppStatus.instance.currentUserStatus.name, ...otherProperties}));
                return ReminderResponse(
                  payload: botReply,
                  status: ReminderState.edited,
                );
              }(),
            UserInputIntent.approved || UserInputIntent.other => () async {
                final filledResult = await ReminderFilledHandler.query(userQuery);
                final botReply = filledResult['bot_reply'];
                final otherProperties = Map.from(filledResult)..remove('bot_reply');

                AppStatus.instance.reminderStatus = ReminderState.filled;
                unawaited(AppEvent.reminderFilled
                    .track(params: {"userStatus": AppStatus.instance.currentUserStatus.name, ...otherProperties}));
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
      ReminderResponse(payload: final payload, status: ReminderState.edited) =>
        LolaTextResult(text: payload),
      ReminderResponse(payload: final payload, status: ReminderState.filled) => handle(payload, voiceModel),
      ReminderResponse(payload: final payload) when payload.isEmpty => throw LolaResponseException('Empty response'),
      _ => throw LolaResponseException('Unexpected response'),
    };
  }

  static Future<ReminderResponse> editedReminder(String userInput) async {
    final reminderIntent = await ReminderInputChecker.query(userInput);

    return switch (reminderIntent) {
      UserInputIntent.change => () async {
          final editedResult = await ReminderEditedHandler.query(userInput);
          final botReply = editedResult['bot_reply'];
          final otherProperties = Map.from(editedResult)..remove('bot_reply');

          AppStatus.instance.reminderStatus = ReminderState.edited;
          unawaited(AppEvent.reminderEdited
              .track(params: {"userStatus": AppStatus.instance.currentUserStatus.name, ...otherProperties}));
          return ReminderResponse(
            payload: botReply,
            status: ReminderState.edited,
          );
        }(),
      UserInputIntent.approved || UserInputIntent.other => () async {
          final filledResult = await ReminderFilledHandler.query(userInput);
          final botReply = filledResult['bot_reply'];
          final otherProperties = Map.from(filledResult)..remove('bot_reply');

          AppStatus.instance.reminderStatus = ReminderState.filled;
          unawaited(AppEvent.reminderFilled
              .track(params: {"userStatus": AppStatus.instance.currentUserStatus.name, ...otherProperties}));
          return ReminderResponse(
            payload: botReply,
            status: ReminderState.filled,
          );
        }(),
    };
  }
}
