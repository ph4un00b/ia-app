import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get openAiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openAiBaseUrl => dotenv.env['OPENAI_API_BASE'] ?? '';
  static String get elevenApiKey => dotenv.env['ELEVEN_API_KEY'] ?? '';
  static String get dbUrl => dotenv.env['DB_URL'] ?? '';
  static String get dbKey => dotenv.env['DB_KEY'] ?? '';
  static String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';
  static String get mixpanelToken => dotenv.env['MIXPANEL_TOKEN'] ?? '';
}
