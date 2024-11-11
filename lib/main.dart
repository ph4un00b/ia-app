import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/root.dart';

Future<void> runMainApp() async {
  await Supabase.initialize(
    url: Env.dbUrl,
    anonKey: Env.dbKey,
  );

  await AppStatus.initialize();

  await SentryFlutter.init(
    (options) => options
      ..dsn = Env.sentryDsn
      ..environment = AppStatus.flavor().name
      //! @see https://docs.sentry.io/platforms/flutter/enriching-events/screenshots/
      ..attachScreenshot = false
      ..attachViewHierarchy = false
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      ..tracesSampleRate = 1.0
      // Setting to 1.0 will profile 100% of sampled transactions:
      ..profilesSampleRate = 1.0
      //! better stack traces in the dashboard
      ..considerInAppFramesByDefault = false
      ..addInAppInclude('lola_ai_app')
      //! Use the beforeSend callback to filter which events are sent
      ..beforeSend = (event, hint) async => event,
    appRunner: () => runApp(const MyApp()),
  );
}

enum AppState { idle, auth, onboarding, active }

// TODO:
// enum AppState {
//   idle,
//   active,
//   authenticating,
//   onboarding,
//   creatingReminder,
//   remindersCreated,
// }
enum LolaState { idle, running, creatingReminder }

enum ReminderState { idle, create, draft, edited, filled }

enum Flavor { dev, stg, prod }

typedef ReminderData = Map<String, dynamic>;

class AppStatus {
  bool _initialized = false;
  Mixpanel? mixpanel;

  var lolaStatus = LolaState.idle;
  var currentStatus = AppState.idle;
  var reminderStatus = ReminderState.idle;
  var currentReminder = ReminderData();
  var currentReminderChat = <ChatCompletionMessage>[];

  AppStatus._();
  static final AppStatus _instance = AppStatus._();
  static AppStatus get instance => _instance;

  static Future<void> initialize() async {
    assert(
      !_instance._initialized,
      'This instance is already initialized',
    );

    await _instance._initMixpanel();
    _instance._initialized = true;
  }

  Future<void> _initMixpanel() async {
    mixpanel = await Mixpanel.init(
      Env.mixpanelToken,
      trackAutomaticEvents: true,
    )
      ..setLoggingEnabled(false);
  }

  static Flavor flavor() {
    return switch (appFlavor) {
      'prod' => Flavor.prod,
      'stg' => Flavor.stg,
      'dev' => Flavor.dev,
      null => Flavor.dev, // * if not specified, default to dev
      _ => throw UnsupportedError('Invalid flavor: $appFlavor'),
    };
  }
}
