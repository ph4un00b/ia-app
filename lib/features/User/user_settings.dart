import 'package:flutter/material.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Agents/reminder_agent.dart';
import 'package:lola_ai_app/features/LocalStore/local_store.dart';
import 'package:lola_ai_app/features/User/types.dart';
import 'package:lola_ai_app/main.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class UserMetadata {
  final String reminderFileId;
  final String vectorId;
  final String assistantId;
  final AppUserState appStatus;

  const UserMetadata({
    required this.reminderFileId,
    required this.vectorId,
    required this.assistantId,
    required this.appStatus,
  });

  factory UserMetadata.fromJson(Map<String, dynamic> json) {
    return UserMetadata(
        reminderFileId: json['reminder_file_id'],
        vectorId: json['vector_id'],
        assistantId: json['assistant_id'],
        appStatus: AppUserState.values
            .firstWhere((v) => v.name == json['app_status']));
  }
}

class UserSettings {
  static Future<UserMetadata> initialize() async {
    OpenAIClient client = OpenAIClient(apiKey: Env.openAiKey);

    AssistantObject assistant = await client.createAssistant(
      request: CreateAssistantRequest(
        model: const AssistantModel.model(AssistantModels.gpt35Turbo),
        name: 'lola-recuerdos-${AppStatus.flavor().name}',
        // description: 'Help students with math homework',
        instructions:
            '''Actuarás como una enfermera. Tu objetivo es ser sociable, preocuparte por la salud de tus pacientes
y recordar cualquier pendiente registrado en los archivos.
Mantendrás siempre un tono amable y respetuoso, y responderás de manera consistente al dirigirte a tu paciente.
Si te preguntan algo que no está en los archivos, responderás: "Lo siento, no tengo información sobre eso".

Aquí hay algunas recomendaciones para ayudarte a ser más efectiva:

- Mantén siempre el personaje de enfermera, con una comunicación de la forma más natural como de amistad.
- Si no estás segura de cómo responder, dirás: "Lo siento, no entiendo. ¿Puedes repetir la pregunta?"
- Si te preguntan algo que no está en los archivos de pendientes, responderás: "Lo siento, no tengo información sobre eso".
''',
        // tools: [AssistantTools.codeInterpreter()],
      ),
    );

    debugPrint(assistant.toString());

    final vectorStore = await client.createVectorStore(
      request: CreateVectorStoreRequest(
        name: 'reminders-store-${AppStatus.flavor().name}',
      ),
    );

    debugPrint(vectorStore.toString());

    await LocalStore.save("jamon.md");

    final remindersFile = await ReminderAgent.uploadLocalRemindersFile();

    final result = await Supabase.instance.client
        .from('person_metadata')
        .insert({
          'assistant_id': assistant.id,
          'vector_id': vectorStore.id,
          'reminder_file_id': remindersFile.id,
          'user_id': AppStatus.instance.userId,
        })
        .select()
        .limit(1)
        .single();

    debugPrint('metadata: $result');

    final meta = UserMetadata.fromJson(result);
    AppStatus.instance.currentStatus = meta.appStatus;
    return meta;
  }

  static Future<UserMetadata?> metadata() async {
    final res = await Supabase.instance.client
        .from('person_metadata')
        .select('assistant_id, reminder_file_id, vector_id, app_status')
        .eq('user_id', AppStatus.instance.userId)
        .limit(1)
        .maybeSingle();

    return res == null ? null : UserMetadata.fromJson(res);
  }
}
