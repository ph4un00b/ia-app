import 'package:envied/envied.dart';

part 'env_dev.g.dart';

@Envied(path: '.env.dev')
final class EnvDev {
  @EnviedField(varName: 'APPSTORE_ID', obfuscate: false)
  static const String appStoreId = _EnvDev.appStoreId;

  @EnviedField(varName: 'OPENAI_API_KEY', obfuscate: true)
  static final String openAiKey = _EnvDev.openAiKey;

  @EnviedField(varName: 'OPENAI_API_BASE', obfuscate: false)
  static const String openAiBaseUrl = _EnvDev.openAiBaseUrl;

  @EnviedField(varName: 'ELEVEN_API_KEY', obfuscate: true)
  static final String elevenApiKey = _EnvDev.elevenApiKey;

  @EnviedField(varName: 'DB_URL', obfuscate: false)
  static const String dbUrl = _EnvDev.dbUrl;

  @EnviedField(varName: 'DB_KEY', obfuscate: true)
  static final String dbKey = _EnvDev.dbKey;

  @EnviedField(varName: 'SENTRY_DSN', obfuscate: true)
  static final String sentryDsn = _EnvDev.sentryDsn;

  @EnviedField(varName: 'MIXPANEL_TOKEN', obfuscate: true)
  static final String mixpanelToken = _EnvDev.mixpanelToken;
}
