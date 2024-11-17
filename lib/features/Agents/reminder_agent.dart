import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/LocalStore/local_store.dart';
import 'package:lola_ai_app/features/Reminders/json2reminder.dart';
import 'package:lola_ai_app/features/User/types.dart';
import 'package:lola_ai_app/features/User/user_settings.dart';
import 'package:lola_ai_app/features/core/logger.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:lola_ai_app/main.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

extension AppStatusExtension on AppStatus {
  void resetToIdle() {
    reminderStatus = ReminderState.idle;
    lolaStatus = LolaState.idle;
    currentReminderChat = [];
    currentReminder = {};
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

    messages.data.forEach((message) => debugPrint(message.content.first.text));

    return messages.data.isEmpty
        ? const NoneResponse()
        : ReminderResponse(
            payload: messages.data.first.content.first.text.trim());
  }

  static Future<UserMetadata> fetchUserMetadata() async {
    final result = await Supabase.instance.client
        .from('person_metadata')
        .select('assistant_id, reminder_file_id, vector_id, app_status')
        .eq('user_id', AppStatus.instance.userId)
        .limit(1)
        .single();

    // TODO: cover empty
    return UserMetadata.fromJson(result);
  }

  // TODO: crear reminder en la base de datos hasta definir bien la structura
  static Future<void> updateReminders() async {
    final userMetadata = await fetchUserMetadata();
    // TODO: remover jsonEncode? usando Map<String, dynamic> en lugar de String ??
    final reminderJson = jsonEncode(AppStatus.instance.currentReminder);

    final updatedRemindersFile = await LocalStore.append(
      "jamon.md",
      ReminderParser.parseJsonToReminderText(reminderJson),
    ).then((_) => uploadLocalRemindersFile());

    // attach new file to vector store
    final client = OpenAIClient(apiKey: Env.openAiKey);
    VectorStoreFileObject addedFile = await client.createVectorStoreFile(
      vectorStoreId: userMetadata.vectorId,
      request: CreateVectorStoreFileRequest(
        fileId: updatedRemindersFile.id,
      ),
    );

    debugPrint('File attached to vector store: ${addedFile.toString()}');

    await Supabase.instance.client
        .from('person_metadata')
        .update({'reminder_file_id': updatedRemindersFile.id}).eq(
            'user_id', AppStatus.instance.userId);

    await _tryDeleteOldFile(userMetadata.reminderFileId);

    final linesCount = await LocalStore.read("jamon.md");
    final reminderCount = switch (linesCount) {
      1 => 0,
      _ => linesCount - 1,
    };
    if (reminderCount > 0 &&
        AppStatus.instance.currentStatus == AppUserState.onboarding) {
      await AppStatus.instance.activateUser();
    }

    unawaited(
      AppEvent.reminderCreated.track(
        params: {
          'count': reminderCount,
          'userStatus': AppStatus.instance.currentStatus,
        },
      ),
    );

    AppStatus.instance.resetToIdle();
  }

  static Future<void> _tryDeleteOldFile(String fileId) async {
    try {
      await OpenAI.instance.file.delete(fileId);
    } catch (e, st) {
      ErrorLogger.logException(e, st);
    }
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
    String userQuery,
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
          userQuery,
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

  static Future<RunObject> _waitForRunCompletion(
    RunObject run,
    ThreadObject thread,
    OpenAIClient client,
  ) async {
    while (
        run.status == RunStatus.queued || run.status == RunStatus.inProgress) {
      run = await client.getThreadRun(threadId: thread.id, runId: run.id);
      debugPrint(run.status.toString());
    }
    return run;
  }
}
