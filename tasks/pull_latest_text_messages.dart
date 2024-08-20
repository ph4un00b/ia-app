import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Agents/llm.dart';
import 'package:lola_ai_app/features/Memory/queries/short_memory_messages.dart';
import 'package:lola_ai_app/features/Prompts/micro_summary.dart';
import 'package:lola_ai_app/features/core/write_file.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main(List<String> args) async {
  await dotenv.load(fileName: ".env");
  assert(Env.dbUrl.isNotEmpty, "DB_URL not defined");
  assert(Env.dbKey.isNotEmpty, "DB_KEY not defined");
  await Supabase.initialize(
    url: Env.dbUrl,
    anonKey: Env.dbKey,
  );

  String messages = await ShortMemoryMessages.generate();
  debugPrint('>> $messages');

  await WriteDebugFile.execute(
    content: messages,
    filename: 'Debug-ShortMemoryMessages',
  );

  String response = await PromptMicroSummary.query(
    llm: LLM.openaiChat,
    text: messages,
  );
  debugPrint('>> $response');
}
