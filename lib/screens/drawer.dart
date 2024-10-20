import 'dart:convert';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Agents/reminder_agent.dart';
import 'package:lola_ai_app/features/LocalStore/local_store.dart';
import 'package:lola_ai_app/features/Reminders/json2reminder.dart';
import 'package:lola_ai_app/features/core/routes.dart';
import 'package:lola_ai_app/main.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      onDestinationSelected: (index) async {
        debugPrint("$index");
        var args = {'subroute': '/otros'};
        if (index case 0) {
          Navigator.pushNamed(context, '/opciones',
              arguments: ("/mensajes", "luis"));
        } else if (index case 1) {
          Navigator.pushNamed(context, '/opciones',
              arguments: ProfileArgs(city: "jamon", country: "bolivia"));
        } else if (index case 2) {
          Navigator.pushNamed(context, '/opciones', arguments: args);
        } else if (index case 3) {
          Navigator.of(context).pop();
        } else if (index case 4) {
          await searchAndDestroyOpenAiFiles();
        } else if (index case 5) {
          LocalStore.read("jamon.md");
        } else if (index case 6) {
          LocalStore.save("jamon.md");
          debugPrint('>> jamon.md created');
        } else if (index case 7) {
          try {
            await ReminderAgent.query("cuando debo beber leche?");
          } catch (e, st) {
            debugPrint('Error occurred: $e, $st');
          }
        }
        // TODO: crear modify assistant and update vectore store
        else if (index == 8) {
          await modifyAssistant();
        } else if (index == 9) {
          await createOpenAiAssistant();
        } else if (index == 10) {
          const reminderJson = '''
       {
        "title": "Cita con nutricionista",
        "description": "Tienes una cita con el nutricionista.",
        "category": "Salud",
        "kind": "ONE_TIME",
        "day": "MONDAY",
        "modifier": null,
        "date": "2024-11-04",
        "endDate": null,
        "repeat": null,
        "time": "18:00",
        "interval": null,
        "priority": "NORMAL",
        "notificationType": "APP",
        "isCompleted": false,
        "bot_reply": "¡Genial! He añadido tu recordatorio: \\"Cita con nutricionista el 4 de noviembre del 2024 a las 6 PM.\\" ¿Hay algo que te gustaría agregar o cambiar sobre este recordatorio? O, ¿te gustaría continuar y agregar un nuevo recordatorio?",
        "next_state_key": "DRAFT_REMINDER"
      }
          ''';
          await LocalStore.append(
              "jamon.md", ReminderParser.parseJsonToReminderText(reminderJson));
        } else if (index == 11) {
          await createStoreWithFile();
        } else if (index == 12) {
          await deleteOpenAiFiles();
        } else if (index == 13) {
          try {
            // antes de hacer esto:
            // 5. Leer File reminders
            // 6. Crear File reminders
            // 5. Leer File reminders

            // append new reminder
            const reminderJson = '''
          {
            "title": "Beber yogurt",
            "description": "Recordatorio para beber yogurt.",
            "category": "Salud",
            "kind": "DAILY",
            "day": null,
            "modifier": null,
            "date": null,
            "endDate": null,
            "repeat": null,
            "time": "10:00",
            "dayTime": "MORNING",
            "interval": null,
            "priority": "NORMAL",
            "notificationType": "APP",
            "isCompleted": false,
            "bot_reply": "¡Genial! He añadido tu recordatorio: \\"Beber yogurt a las 10 AM todos los días.\\" ¿Hay algo que te gustaría agregar o cambiar sobre este recordatorio? ¿O te gustaría continuar y agregar un nuevo recordatorio?",
            "next_state_key": "DRAFT_REMINDER"
          }
            ''';

            AppStatus.instance.currentReminder =
                jsonDecode(reminderJson) as Map<String, dynamic>;
            await ReminderAgent.updateReminders();
            // find new reminder
            await ReminderAgent.query("cuando debo beber yogurt?");
          } catch (e, st) {
            debugPrint('Error occurred: $e, $st');
          }
        }
      },
      selectedIndex: 0,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            'Opciones',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...destinations.map(
          (ExampleDestination destination) {
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
        const NavigationDrawerDestination(
          label: Text("Cerrar"),
          icon: Icon(Icons.clear),
          selectedIcon: Icon(Icons.clear),
        ),
        const NavigationDrawerDestination(
          label: Text("Lista de assistentes"),
          icon: Icon(Icons.list),
          selectedIcon: Icon(Icons.clear),
        ),
        const NavigationDrawerDestination(
          label: Text("5. Leer File reminders"),
          icon: Icon(Icons.list),
          selectedIcon: Icon(Icons.clear),
        ),
        const NavigationDrawerDestination(
          label: Text("6. Crear File reminders"),
          icon: Icon(Icons.list),
          selectedIcon: Icon(Icons.clear),
        ),
        const NavigationDrawerDestination(
          label: Text("7. Buscar reminder"),
          icon: Icon(Icons.list),
          selectedIcon: Icon(Icons.clear),
        ),
        const NavigationDrawerDestination(
          label: Text("8. Modify assistant"),
          icon: Icon(Icons.list),
          selectedIcon: Icon(Icons.clear),
        ),
        const NavigationDrawerDestination(
          label: Text("9. Create assistant"),
          icon: Icon(Icons.list),
          selectedIcon: Icon(Icons.clear),
        ),
        const NavigationDrawerDestination(
          label: Text("10. Appent to File"),
          icon: Icon(Icons.list),
          selectedIcon: Icon(Icons.clear),
        ),
        const NavigationDrawerDestination(
          label: Text("11. Create Store with file"),
          icon: Icon(Icons.list),
          selectedIcon: Icon(Icons.clear),
        ),
        const NavigationDrawerDestination(
          label: Text("12. Delete openai file"),
          icon: Icon(Icons.list),
          selectedIcon: Icon(Icons.clear),
        ),
        const NavigationDrawerDestination(
          label: Text("13. Push new reminders file"),
          icon: Icon(Icons.list),
          selectedIcon: Icon(Icons.clear),
        )
      ],
    );
  }

  Future<void> searchAndDestroyOpenAiFiles() async {
    OpenAIClient client = OpenAIClient(apiKey: Env.openAiKey);
    ListAssistantsResponse secres = await client.listAssistants();

    print(">>>> LISTA DE ASSISTENTES: ${secres.data.length} <<<< \n");
    for (var secre in secres.data) {
      // await client.deleteAssistant(assistantId: secre.id);
      print(secre.name);
      final createdAt =
          DateTime.fromMillisecondsSinceEpoch(secre.createdAt * 1000);
      print(createdAt.toLocal().toString());
      print(secre.toolResources);
    }

    ListVectorStoresResponse res = await client.listVectorStores();
    print(">>>> LISTA DE VECTORES STORES: ${res.data.length} <<<< \n");

    for (var store in res.data) {
      debugPrint('${store.id} ${store.name}');
      final createdAt =
          DateTime.fromMillisecondsSinceEpoch(store.createdAt * 1000);
      print(createdAt.toLocal().toString());
      final lastAt =
          DateTime.fromMillisecondsSinceEpoch((store.lastActiveAt ?? 1) * 1000);
      print("last-active : ${lastAt.toLocal().toString()}");
    }

    //! https://platform.openai.com/docs/api-reference/files/list
    print(">>>> LISTA DE FILES\n");
    OpenAI.apiKey = Env.openAiKey;
    OpenAI.baseUrl = "https://api.openai.com/"; // the default one.
    OpenAI.requestsTimeOut = const Duration(seconds: 10);
    OpenAI.showLogs = !true;
    OpenAI.showResponsesLogs = true;

    List<OpenAIFileModel> files = await OpenAI.instance.file.list();

    for (var file in files) {
      print(
          'File ID: ${file.id}, Name: ${file.fileName}, Datetime: ${file.createdAt}');
      // await OpenAI.instance.file.delete(file.id);
    }
    // try {
    //   final response = await http.get(
    //     Uri.parse('https://api.openai.com/v1/files'),
    //     headers: {
    //       'Authorization': 'Bearer ${Env.openAiKey}',
    //       'Content-Type': 'application/json',
    //     },
    //   );

    //   if (response.statusCode == 200) {
    //     final filesData = jsonDecode(response.body);
    //     final files = filesData['data'] as List<dynamic>;

    //     print('Total files: ${files.length}');
    //     for (var file in files) {
    //       print('File ID: ${file['id']}, Name: ${file['filename']}');
    //     }
    //   } else {
    //     print(
    //         'Failed to fetch files. Status code: ${response.statusCode}');
    //     print('Response body: ${response.body}');
    //   }
    // } catch (e) {
    //   print('Error fetching files: $e');
    // }
    // https://api.openai.com/v1/internal/files?after=file-UoTg26DXKG0Jj9dGYtiRVFzc&limit=10&order=desc&order_by=created_at

    for (var file in files) {
      await OpenAI.instance.file.delete(file.id);
      print(">>>> DELETED FILE: file-${file.id}");
    }
  }

  Future<void> modifyAssistant() async {
    const assistantId = "asst_XdqXSdTSvAE6S4Rdm9NB0yON";
    // TODO: crear modify assistant and update vectore store
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;
    OpenAIClient client = OpenAIClient(apiKey: Env.openAiKey);

    final lola = await client.modifyAssistant(
      assistantId: assistantId,
      request: const ModifyAssistantRequest(
        toolResources: ToolResources(
          fileSearch: ToolResourcesFileSearch(
            vectorStoreIds: ["vs_Rl1fEIxdK2yaTzZv0kJnqOhK"],
          ),
        ),
      ),
    );

    debugPrint(lola.toString());
  }

  Future<void> createOpenAiAssistant() async {
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;
    OpenAIClient client = OpenAIClient(apiKey: Env.openAiKey);

    AssistantObject lola = await client.createAssistant(
      request: const CreateAssistantRequest(
        model: AssistantModel.model(AssistantModels.gpt35Turbo),
        name: 'lola recuerdos',
        // description: 'Help students with math homework',
        instructions:
            'respondes forma amable los pendientes basados en los archivos md, asegura que siempre me respondas en español, no tan formal, nunca menciones los archivos.',
        // tools: [AssistantTools.codeInterpreter()],
      ),
    );

    debugPrint(lola.toString());
  }

  Future<void> deleteOpenAiFiles() async {
    OpenAI.apiKey = Env.openAiKey;
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    const filesToDelete = [
      'file-VshXivlm7lasOFXAohSEN1Hk',
      'file-NFX2wcQTg3tnZCL6ccNJVcaE',
    ];

    for (final fileId in filesToDelete) {
      try {
        await OpenAI.instance.file.delete(fileId);
        debugPrint('Successfully deleted file: $fileId');
      } catch (e) {
        debugPrint('Error deleting file $fileId: $e');
      }
    }
  }

  Future<void> createStoreWithFile() async {
    // TODO: Replace '1' with actual user ID from auth
    const userId = '1';
    List<Map<String, dynamic>> result = await Supabase.instance.client
        .from('person_metadata')
        .select('id, reminder_file_id')
        .eq('id', userId)
        .limit(1);

    if (result.isEmpty) {
      throw StateError('No user metadata found');
    }

    debugPrint(result.toString());

    OpenAI.apiKey = Env.openAiKey;
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    OpenAIFileModel? uploadedFile;
    try {
      Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();
      String appDocumentsPath = appDocumentsDirectory.path;
      String filePath = '$appDocumentsPath/jamon.md';

      uploadedFile = await OpenAI.instance.file.upload(
        file: File(filePath),
        purpose: "assistants",
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    if (uploadedFile == null) {
      throw StateError('No file uploaded');
    }

    await ReminderAgent.addFileToVectorStore(
      "vs_Rl1fEIxdK2yaTzZv0kJnqOhK",
      uploadedFile.id,
    );

    final String reminderFileId = result.first['reminder_file_id'];

    try {
      await OpenAI.instance.file.delete(reminderFileId);
      debugPrint('Successfully deleted file: $reminderFileId');
    } catch (e) {
      debugPrint('Error deleting file $reminderFileId: $e');
    }
  }
}
