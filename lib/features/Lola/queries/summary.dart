import 'dart:io';

import 'package:lola_ai_app/features/Agents/llm.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Memory/queries/short_memory_messages.dart';
import 'package:lola_ai_app/features/Prompts/micro_summary.dart';
import 'package:lola_ai_app/features/core/write_file.dart';
import 'package:path/path.dart' as p;

class LolaSummary {
  static Future<LolaResult> query({
    required VoiceLola voice,
    required bool debug,
  }) async {
    final userQuestions = await ShortMemoryMessages.userQuestions();

    if (debug) {
      await WriteDebugFile.execute(
        content: userQuestions,
        filename: 'debug-userQuestions',
      );
    }

    String summary = await PromptMicroSummary.query(
      llm: LLM.openaiChat,
      text: userQuestions,
    );

    if (summary.isEmpty) {
      throw LolaResponseException('empty response');
    }

    File speechFile = await voice.synthesize(text: summary);
    String path = p.normalize(speechFile.path);

    return LolaResult(path, summary);
  }
}
