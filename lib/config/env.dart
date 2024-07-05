import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get openAiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openAiBaseUrl => dotenv.env['OPENAI_API_BASE'] ?? '';
  static String get elevenApiKey => dotenv.env['ELEVEN_API_KEY'] ?? '';
}
