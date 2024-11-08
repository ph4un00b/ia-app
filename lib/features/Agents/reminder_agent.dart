import 'dart:convert';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/LocalStore/local_store.dart';
import 'package:lola_ai_app/features/Reminders/json2reminder.dart';
import 'package:lola_ai_app/features/core/logger.dart';
import 'package:lola_ai_app/main.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserMetadata {
  final String reminderFileId;
  final String vectorId;
  final String assistantId;

  UserMetadata({
    required this.reminderFileId,
    required this.vectorId,
    required this.assistantId,
  });

  factory UserMetadata.fromJson(Map<String, dynamic> json) {
    return UserMetadata(
        reminderFileId: json['reminder_file_id'],
        vectorId: json['vector_id'],
        assistantId: json['assistant_id']);
  }
}

class ReminderAgent {
  static Future<LLMResponse> query(String userQuery) async {
    final client = OpenAIClient(apiKey: Env.openAiKey);
    final userMetadata = await fetchUserMetadata();

    final conversationThread = await _createThread(
      client,
      userQuery,
      userMetadata,
    );

    final messages = await client.listThreadMessages(
      threadId: conversationThread.id,
      order: 'desc',
    );

    for (var message in messages.data) {
      debugPrint(message.content.first.text);
    }

    return messages.data.isEmpty
        ? const NoneResponse()
        : ReminderResponse(
            payload: messages.data.first.content.first.text.trim());
  }

  static Future<UserMetadata> fetchUserMetadata() async {
    const userId = '1'; // TODO: Replace with actual user ID from auth
    final result = await Supabase.instance.client
        .from('person_metadata')
        .select('id, assistant_id, reminder_file_id, vector_id')
        .eq('id', userId)
        .limit(1)
        .single();

    // TODO: cover empty
    return UserMetadata.fromJson(result);
  }

  // TODO: crear reminder en la base de datos hasta definir bien la structura
  // TODO: remover jsonEncode? usando Map<String, dynamic> en lugar de String ??
  static Future<void> updateReminders() async {
    final userMetadata = await fetchUserMetadata();
    final reminderJson = jsonEncode(AppStatus.instance.currentReminder);

    await LocalStore.append("jamon.md", ReminderParser.parseJsonToReminderText(reminderJson));
    final updatedRemindersFile = await ReminderAgent.uploadLocalRemindersFile();

    // attach new file to vector store
    OpenAIClient client = OpenAIClient(apiKey: Env.openAiKey);
    VectorStoreFileObject addedFile = await client.createVectorStoreFile(
      vectorStoreId: userMetadata.vectorId,
      request: CreateVectorStoreFileRequest(
        fileId: updatedRemindersFile.id,
      ),
    );

    debugPrint('File attached to vector store: ${addedFile.toString()}');

    // TODO: Replace '1' with actual user ID from auth
    await Supabase.instance.client.from('person_metadata').update(
      {'reminder_file_id': updatedRemindersFile.id},
    ).eq('id', 1);

    try {
      // TODO: por ahora si hay problemas, comemos el error
      // possiblemente checar si existemas más de un archivo y borrarlos
      // en la siguiente interacion, sí y sólo sí, vemos que no afecta
      // en las queries siguientes.
      await OpenAI.instance.file.delete(userMetadata.reminderFileId);
      debugPrint('Successfully deleted file: ${userMetadata.reminderFileId}');
    } catch (e, st) {
      ErrorLogger.logException(e, st);
    }

    AppStatus.instance.reminderStatus = ReminderState.idle;
    AppStatus.instance.currentReminder = {};
    AppStatus.instance.currentReminderChat = [];
    AppStatus.instance.currentStatus = AppState.active;
    AppStatus.instance.lolaStatus = LolaState.idle;
  }

  static Future<OpenAIFileModel> uploadLocalRemindersFile() async {
    OpenAI.apiKey = Env.openAiKey;
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final filePath = '${appDocumentsDirectory.path}/jamon.md';

    final uploadedRemindersFile = await OpenAI.instance.file.upload(
      file: File(filePath),
      purpose: 'assistants',
    );

    return uploadedRemindersFile;
  }

  static Future<ThreadObject> _createThread(
    OpenAIClient client,
    String pregunta,
    UserMetadata userMetadata,
  ) async {
    ThreadObject hilo = await client.createThread(
      request: const CreateThreadRequest(),
    );

    debugPrint('\n${hilo.toolResources?.fileSearch}');

    MessageObject msg = await client.createThreadMessage(
      threadId: hilo.id,
      request: CreateMessageRequest(
        role: MessageRole.user,
        content: CreateMessageRequestContent.text(
          pregunta,
        ),
        attachments: [
          MessageAttachment(
            fileId: userMetadata.reminderFileId,
            tools: [const AssistantTools.fileSearch(type: "file_search")],
          )
        ],
      ),
    );

    debugPrint('\n$msg');

    RunObject run = await client.createThreadRun(
      threadId: hilo.id,
      request: CreateRunRequest(
        assistantId: userMetadata.assistantId,
        tools: [const AssistantTools.fileSearch(type: "file_search")],

        // instructions:
        //     'Please address the user as Jane Doe. The user has a premium account.',
      ),
    );

    final completedRun = await _waitForRunCompletion(run, hilo, client);
    debugPrint('Final status: ${completedRun.status}');

    return hilo;
  }

  static Future<void> addFileToVectorStore(
    String vectorStoreId,
    String fileId,
  ) async {
    OpenAIClient client = OpenAIClient(apiKey: Env.openAiKey);
    VectorStoreFileObject addedFile = await client.createVectorStoreFile(
      vectorStoreId: vectorStoreId,
      request: CreateVectorStoreFileRequest(
        fileId: fileId,
      ),
    );

    debugPrint('File added to vector store: ${addedFile.toString()}');
  }

  static Future<OpenAIFileModel?> uploadRemindersFile() async {
    OpenAIFileModel? uploadedFile;

    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/jamon.md';

    uploadedFile = await OpenAI.instance.file.upload(
      file: File(filePath),
      purpose: "assistants",
    );

    return uploadedFile;
  }

  static Future<VectorStoreObject?> createVectorStore(
    OpenAIClient client,
  ) async {
    VectorStoreObject? store;

    store = await client.createVectorStore(
      request: const CreateVectorStoreRequest(
        name: 'reminders store',
      ),
    );
    debugPrint(store.toString());

    return store;
  }

  static _waitForRunCompletion(
    RunObject run,
    ThreadObject hilo,
    OpenAIClient client,
  ) async {
    while (
        run.status == RunStatus.queued || run.status == RunStatus.inProgress) {
      run = await client.getThreadRun(threadId: hilo.id, runId: run.id);
      debugPrint(run.status.toString());
    }
    return run;
  }
}
