import 'dart:io';

import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:path/path.dart' as p;

class LolaResponse {
  static Future<LolaResult> query({
    required question,
    required VoiceLola voice,
    required bool debug,
  }) async {
    const classify = Agent.classification;
    const remind = Agent.reminder;
    const text = Agent.text;

    final agentKind = await classify.query(question);

    print('agentKind: $agentKind');

    LLMResponse response = switch (agentKind) {
      TextResponse() => await text.query(question),
      ReminderResponse() => await remind.query(question),
      NoneResponse() => const NoneResponse()
    };

    if (response.payload.isEmpty) {
      throw LolaResponseException('empty response');
    }

    File speechFile = await voice.synthesize(text: response.payload);
    String path = p.normalize(speechFile.path);

    return LolaResult(path, response.payload);
  }
}
