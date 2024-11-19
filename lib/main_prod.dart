import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lola_ai_app/config/env.dart';

import 'main.dart';

// * Entry point for the prod flavor
void main() async {
  await dotenv.load(fileName: ".env.prod");
  assert(Env.openAiKey.isNotEmpty, "OPENAI_API_KEY not defined");
  assert(Env.openAiBaseUrl.isNotEmpty, "OPENAI_API_BASE not defined");
  assert(Env.elevenApiKey.isNotEmpty, "ELEVEN_API_KEY not defined");
  assert(Env.dbUrl.isNotEmpty, "DB_URL not defined");
  assert(Env.dbKey.isNotEmpty, "DB_KEY not defined");
  assert(Env.sentryDsn.isNotEmpty, "SENTRY_DSN not defined");
  assert(Env.mixpanelToken.isNotEmpty, "MIXPANEL_TOKEN not defined");
  assert(Env.appStoreId.isNotEmpty, "APPSTORE_ID not defined");

  await runMainApp();
}
