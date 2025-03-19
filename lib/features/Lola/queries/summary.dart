import 'package:lola_ai_app/features/Agents/llm.dart';
import 'package:lola_ai_app/features/App/status.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Memory/queries/short_memory_messages.dart';
import 'package:lola_ai_app/features/Prompts/micro_summary.dart';
import 'package:lola_ai_app/features/core/write_file.dart';

class LolaSummaryGenerator {
  static Future<LolaTextResult> generate({
    required VoiceLola voice,
    required bool debug,
  }) async {
    //! se pueden optimizar llamadas innecesarias, por ahora está bien.
    final userQuestions = await ShortMemoryMessages.userQuestions();

    if (debug) {
      await WriteDebugFile.execute(
        content: userQuestions,
        filename: 'debug-userQuestions',
      );
    }

    final summary = AppStatus.isActive()
        ? await PromptMicroSummary.query(
            llm: LLM.openaiChat,
            text: userQuestions,
          )
        : 'Hola! Aquí te mostraré un resumen de nuestras conversaciones recientes. Presiona continuar por ahora.';

    if (summary.isEmpty) {
      throw LolaResponseException('empty response');
    }

    return LolaTextResult(text: summary);
  }
}
