import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Agents/llm.dart';
import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:openai_dart/openai_dart.dart';

class ReminderAgent {
  static Future<LLMResponse> query(String input, {required LLM llm}) async {
    if (input.isEmpty) {
      return const NoneResponse();
    }

    OpenAI.apiKey = Env.openAiKey;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut = const Duration(seconds: 10); // 60 seconds.
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    var pregunta = input;

    OpenAIClient client = OpenAIClient(apiKey: Env.openAiKey);

    VectorStoreObject? store;
    try {
      store = await client.createVectorStore(
        request: const CreateVectorStoreRequest(
          name: 'reminders store',
        ),
      );
      debugPrint(store.toString());
    } catch (e) {
      debugPrint(e.toString());
    }

    assert(store != null);
    if (store == null) {
      return const NoneResponse();
    }

    OpenAI.apiKey = Env.openAiKey;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut = const Duration(seconds: 10); // 60 seconds.
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    OpenAIFileModel? uploadedFile;
    try {
      uploadedFile = await OpenAI.instance.file.upload(
        file: File(Constants.testReminderPath),
        purpose: "assistants",
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    // assert(uploadedFile != null);
    if (uploadedFile == null) {
      return const NoneResponse();
    }

    debugPrint(uploadedFile.id);

    try {
      VectorStoreFileObject file = await client.createVectorStoreFile(
        vectorStoreId: store.id,
        request: CreateVectorStoreFileRequest(
          fileId: uploadedFile.id,
        ),
      );

      debugPrint(file.toString());
    } catch (e) {
      debugPrint(e.toString());
    }

    // end vector store

    // AssistantObject lola = await client.createAssistant(
    //   request: const CreateAssistantRequest(
    //     model: AssistantModel.model(AssistantModels.gpt35Turbo),
    //     name: 'lola recuerdos',
    //     // description: 'Help students with math homework',
    //     instructions:
    //         'respondes forma amable los pendientes basados en los archivos md, asegura que siempre me respondas en español, no tan formal, nunca menciones los archivos.',
    //     // tools: [AssistantTools.codeInterpreter()],
    //   ),
    // );

    // debugPrint('\n$lola');

    // lola = await client.modifyAssistant(
    //   assistantId: lola.id,
    //   request: ModifyAssistantRequest(
    //     toolResources: ToolResources(
    //       fileSearch: ToolResourcesFileSearch(
    //         vectorStoreIds: [store.id],
    //       ),
    //     ),
    //   ),
    // );
    // debugPrint('\nupdate: $lola');

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
        // attachments: [
        //   MessageAttachment(
        //       fileId: uploadedFile.id,
        //       tools: [const AssistantTools.fileSearch()])
        // ]
      ),
    );

    debugPrint('\n$msg');

    RunObject run = await client.createThreadRun(
      threadId: hilo.id,
      request: const CreateRunRequest(
        assistantId: 'asst_XdqXSdTSvAE6S4Rdm9NB0yON',
        // instructions:
        //     'Please address the user as Jane Doe. The user has a premium account.',
      ),
    );

    try {
      final completedRun = await _waitOnRun(run, hilo, client);
      debugPrint('Final status: ${completedRun.status}');
    } catch (e) {
      debugPrint('Error: $e');
    }

    final listMessagesResponse = await client.listThreadMessages(
      threadId: hilo.id,
      order: 'desc',
    );

    for (var message in listMessagesResponse.data) {
      debugPrint(message.content.first.text);
    }
    // ListAssistantsResponse secres = await client.listAssistants();

    // for (var secre in secres.data) {
    //   await client.deleteAssistant(assistantId: secre.id);
    // }

    // ListVectorStoresResponse res =
    //     await client.listVectorStores();

    // for (var store in res.data) {
    //   debugPrint('${store.id} ${store.name}');
    //   final res = await client.deleteVectorStore(
    //       vectorStoreId: store.id.toString());
    //   debugPrint(res.toString());
    // }

    // List<OpenAIFileModel> files =
    //     await OpenAI.instance.file.list();

    // for (var file in files) {
    //   await OpenAI.instance.file.delete(file.id);
    // }
    if (listMessagesResponse.data.isEmpty) {
      return const NoneResponse();
    }

    var result = listMessagesResponse.data.first.content.first.text.trim();
    return ReminderResponse(payload: result);
  }

  static _waitOnRun(
    RunObject run,
    ThreadObject hilo,
    OpenAIClient client,
  ) async {
    while (
        run.status == RunStatus.queued || run.status == RunStatus.inProgress) {
      run = await client.getThreadRun(threadId: hilo.id, runId: run.id);
      debugPrint(run.status.toString());
      // XXX: this is for taking a look at the run status
      // await Future.delayed(const Duration(seconds: 1));
    }
    return run;
  }
}
