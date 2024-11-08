import 'dart:developer';

import 'package:sentry_flutter/sentry_flutter.dart';

class ErrorLogger {
  static Future<void> logException(
    Object exception,
    StackTrace? stackTrace,
  ) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
    log(exception.toString(),
        name: 'Exception', error: exception, stackTrace: stackTrace);
  }
}
