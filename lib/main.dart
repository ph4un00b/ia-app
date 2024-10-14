import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/root.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  assert(Env.openAiKey.isNotEmpty, "OPENAI_API_KEY not defined");
  assert(Env.openAiBaseUrl.isNotEmpty, "OPENAI_API_BASE not defined");
  assert(Env.elevenApiKey.isNotEmpty, "ELEVEN_API_KEY not defined");
  assert(Env.dbUrl.isNotEmpty, "DB_URL not defined");
  assert(Env.dbKey.isNotEmpty, "DB_KEY not defined");

  await Supabase.initialize(
    url: Env.dbUrl,
    anonKey: Env.dbKey,
  );

  AppStatus.initialize();

  runApp(const MyApp());
}

enum LolaState { idle, running, auth, onboarding, creatingReminder }

enum ReminderState { idle, create, draft, edited, filled }

class AppStatus {
  bool _initialized = false;
  LolaState lolaStatus = LolaState.idle;
  ReminderState reminderStatus = ReminderState.idle;
  List<ChatCompletionMessage> currentReminderChat = [];

  // Private constructor
  AppStatus._();
  static final AppStatus _instance = AppStatus._();
  static AppStatus get instance => _instance;

  static void initialize() {
    assert(
      !_instance._initialized,
      'This instance is already initialized',
    );

    _instance._initialized = true;
  }
}
