import 'package:envied/envied.dart';

part 'env_prod.g.dart';

@Envied(path: '.env.prod')
final class EnvProd {
  @EnviedField(varName: 'APPSTORE_ID', obfuscate: false)
  static const String appStoreId = _EnvProd.appStoreId;

  @EnviedField(varName: 'OPENAI_API_KEY', obfuscate: true)
  static final String openAiKey = _EnvProd.openAiKey;

  @EnviedField(varName: 'OPENAI_API_BASE', obfuscate: false)
  static const String openAiBaseUrl = _EnvProd.openAiBaseUrl;

  @EnviedField(varName: 'ELEVEN_API_KEY', obfuscate: true)
  static final String elevenApiKey = _EnvProd.elevenApiKey;

  @EnviedField(varName: 'DB_URL', obfuscate: false)
  static const String dbUrl = _EnvProd.dbUrl;

  @EnviedField(varName: 'DB_KEY', obfuscate: true)
  static final String dbKey = _EnvProd.dbKey;

  @EnviedField(varName: 'SENTRY_DSN', obfuscate: true)
  static final String sentryDsn = _EnvProd.sentryDsn;

  @EnviedField(varName: 'MIXPANEL_TOKEN', obfuscate: true)
  static final String mixpanelToken = _EnvProd.mixpanelToken;
}
