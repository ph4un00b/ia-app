import 'dart:async';

import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/User/types.dart';
import 'package:lola_ai_app/main.dart';
import 'package:lola_ai_app/services/ReminderAgent/mutations/create_reminder.dart';
import 'package:lola_ai_app/services/ReminderAgent/mutations/onboarding_reminder.dart';
import 'package:path/path.dart' as p;

import 'ask.dart';

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
          CreateReminderHandler.handle(userQuery, voiceModel),
        IntentKind.createReminder || IntentKind.reminder => {},
      };
    }

    if (AppStatus.instance.currentStatus == AppUserState.onboarding &&
        userIntent != IntentKind.createReminder &&
        userIntent != IntentKind.reminder) {
      return AppStatus.instance.reminderStatus == ReminderState.idle
          ? await _reminderExampleResponse(voiceModel)
          : await OnboardingReminderHandler.handle(userQuery, voiceModel);
    }

    return switch (AppStatus.instance.currentStatus) {
      AppUserState.active =>
        _handleUserQuery(userQuery, voiceModel, userIntent),
      AppUserState.onboarding =>
        OnboardingReminderHandler.handle(userQuery, voiceModel),
      AppUserState.idle || AppUserState.auth => throw StateError(
          "${AppStatus.instance.currentStatus} state not implmented"),
    };
  }

  static Future<LolaResult> _reminderExampleResponse(
      VoiceLola voiceModel) async {
    const message =
        "Hola! Para poder usar mi inteligencia primero debes crear un recordatorio."
        " Cuando grabes un mensaje puedes mencionar algo como: 'Recuerdame preparar yogurt los sabados por la mañana.'";
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
        await CreateReminderHandler.handle(userQuery, voiceModel),
      LolaState.idle ||
      LolaState.running when isAskReminder =>
        await AskLola.query(userQuery, voiceModel),
      LolaState.idle ||
      LolaState.running =>
        await AskLola.query(userQuery, voiceModel),
      LolaState.creatingReminder =>
        await CreateReminderHandler.handle(userQuery, voiceModel),
    };
  }
}
