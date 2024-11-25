import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/App/status.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'screens/root.dart';

Future<void> runMainApp() async {
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
      //! 3rd party code will be collapsed and greyed out when viewing stack traces on the Sentry dashboard
      //! @see https://pub.dev/documentation/sentry_flutter/latest/sentry_flutter/SentryOptions/considerInAppFramesByDefault.html
      ..considerInAppFramesByDefault = false
      ..addInAppInclude('lola_ai_app')
      //! Use the beforeSend callback to filter which events are sent
      ..beforeSend = (event, hint) async => event,
    appRunner: () => runApp(const MyApp()),
  );
}
