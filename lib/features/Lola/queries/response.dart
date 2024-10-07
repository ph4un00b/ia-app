import 'dart:io';

import 'package:lola_ai_app/features/Agents/classification_agent.dart';
import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/main.dart';
import 'package:path/path.dart' as p;

class LolaResponse {
  static Future<LolaResult> query({
    required question,
    required VoiceLola voice,
    required bool debug,
  }) async {
    AppStatus.instance.lolaStatus = LolaState.running;
    const classify = StructuredAgent.classification;
    const reminder = Agent.reminder;
    const text = Agent.text;
    final userIntention = await classify.query(question);

    print('agentKind: $userIntention');

    LLMResponse response = switch (userIntention) {
      ResponseType.none => const NoneResponse(),
      ResponseType.createReminder => await _createReminder(reminder, question),
      ResponseType.reminder => await reminder.query(question),
      ResponseType.text => await text.query(question),
    };

    if (response.payload.isEmpty) {
      throw LolaResponseException('empty response');
    }

    File speechFile = await voice.synthesize(text: response.payload);
    String path = p.normalize(speechFile.path);

    return LolaResult(path, response.payload);
  }

  static Future<LLMResponse> _createReminder(Agent reminder, question) async {

    print('create reminder: currentState: ${AppStatus.instance.lolaStatus}');
    return await reminder.query(question);
  }
}
