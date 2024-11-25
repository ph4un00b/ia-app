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
//! normalmente es cuando el mensaje esta vacio.
class LolaResponse {
  static Future<LolaResult> query({
    required bool debug,
    required String userQuery,
    required VoiceLola voiceModel,
  }) async {
    final userIntent = await StructuredAgent.classification.query(userQuery);

    if (AppStatus.isCreatingReminder() && userIntent.isConversational) {
      return AppStatus.isOnboarding()
          ? await OnboardingReminderHandler.handle(userQuery, voiceModel)
          : await CreateReminderHandler.handle(userQuery, voiceModel);
    }

    if (AppStatus.isOnboarding() && userIntent.isConversational) {
      const message =
          "Hola! Para poder usar mi inteligencia primero debes crear un recordatorio."
          " Cuando grabes un mensaje puedes mencionar algo como: 'Recuerdame preparar yogurt los sabados por la mañana.'";

      return AppStatus.instance.reminderStatus == ReminderState.idle
          ? LolaResult(
              p.normalize((await voiceModel.synthesize(text: message)).path),
              message,
            )
          : await OnboardingReminderHandler.handle(userQuery, voiceModel);
    }

    final shouldHandleReminder =
        AppStatus.instance.lolaStatus == LolaState.creatingReminder ||
            userIntent == IntentKind.createReminder;

    return switch (AppStatus.instance.currentUserStatus) {
      UserState.active => shouldHandleReminder
          ? CreateReminderHandler.handle(userQuery, voiceModel)
          : AskLola.query(userQuery, voiceModel),
      UserState.onboarding =>
        OnboardingReminderHandler.handle(userQuery, voiceModel),
      UserState.idle || UserState.auth => throw StateError(
          "${AppStatus.instance.currentUserStatus} state not implmented"),
    };
  }
}
