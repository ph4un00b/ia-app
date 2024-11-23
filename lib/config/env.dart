import 'package:flutter/foundation.dart';
import 'package:lola_ai_app/config/env_dev.dart';
import 'package:lola_ai_app/config/env_prod.dart';

final class Env {
  static String get appStoreId => kDebugMode ? EnvDev.appStoreId : EnvProd.appStoreId;
  static String get openAiKey => kDebugMode ? EnvDev.openAiKey : EnvProd.openAiKey;
  static String get openAiBaseUrl => kDebugMode ? EnvDev.openAiBaseUrl : EnvProd.openAiBaseUrl;
  static String get elevenApiKey => kDebugMode ? EnvDev.elevenApiKey : EnvProd.elevenApiKey;
  static String get dbUrl => kDebugMode ? EnvDev.dbUrl : EnvProd.dbUrl;
  static String get dbKey => kDebugMode ? EnvDev.dbKey : EnvProd.dbKey;
  static String get sentryDsn => kDebugMode ? EnvDev.sentryDsn : EnvProd.sentryDsn;
  static String get mixpanelToken => kDebugMode ? EnvDev.mixpanelToken : EnvProd.mixpanelToken;
}
