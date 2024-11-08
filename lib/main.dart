import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/root.dart';

Future<void> runMainApp() async {
  await Supabase.initialize(
    url: Env.dbUrl,
    anonKey: Env.dbKey,
  );

  AppStatus.initialize();

  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentryDsn;
      options.environment = AppStatus.flavor().name;
      //! for screenshot use code below
      //! @see https://docs.sentry.io/platforms/flutter/enriching-events/screenshots/
      // runApp(const SentryWidget(child: MyApp()));
      options
        ..attachScreenshot = false
        ..attachViewHierarchy = false;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
      //! better stack traces in the dashboard
      options
        ..considerInAppFramesByDefault = false
        ..addInAppInclude('lola_ai_app');
      //! Use the beforeSend callback to filter which events are sent
      options.beforeSend = (SentryEvent event, Hint hint) async {
        //! Ignore events that are not from release builds
        // if (!kReleaseMode) {
        //   return null;
        // }
        // TODO: add your custom event filtering logic here
        // For all other events, return the event as is
        return event;
      };
    },
    appRunner: () => runApp(const MyApp()),
  );

  // runApp(const MyApp());
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

class AppStatus {
  bool _initialized = false;

  AppState currentStatus = AppState.idle;
  LolaState lolaStatus = LolaState.idle;

  ReminderState reminderStatus = ReminderState.idle;
  List<ChatCompletionMessage> currentReminderChat = [];
  Map<String, dynamic> currentReminder = {};

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
