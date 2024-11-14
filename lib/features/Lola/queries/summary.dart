import 'dart:io';

import 'package:lola_ai_app/features/Agents/llm.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Memory/queries/short_memory_messages.dart';
import 'package:lola_ai_app/features/Prompts/micro_summary.dart';
import 'package:lola_ai_app/features/core/write_file.dart';
import 'package:lola_ai_app/main.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class LolaSummary {
  static Future<LolaResult> query({
    required VoiceLola voice,
    required bool debug,
  }) async {
    //! se pueden optimizar llamadas inncesarias, por ahora está bien.
    final userQuestions = await ShortMemoryMessages.userQuestions();

    if (debug) {
      await WriteDebugFile.execute(
        content: userQuestions,
        filename: 'debug-userQuestions',
      );
    }

    final result = await Supabase.instance.client
        .from('person_metadata')
        .select('reminder_file_id')
        .eq('user_id', AppStatus.instance.userId)
        .limit(1)
        .maybeSingle();

    final summary = result == null
        ? '!Hola! Aún no puedo encontrar un resumen para ti. Presiona continuar.'
        : await PromptMicroSummary.query(
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
