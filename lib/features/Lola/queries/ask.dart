import 'dart:io';

import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/App/status.dart';
import 'package:lola_ai_app/features/Reminders/types.dart';
import 'package:path/path.dart' as p;

import '../types.dart';

final class AskLola {
    static Future<LolaResult> query(
    userQuery,
    VoiceLola voiceModel,
  ) async {
    AppStatus.instance.lolaStatus = LolaState.running;
    // TODO: remover classifier?
    final userIntent = await StructuredAgent.classification.query(userQuery);

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

}
