import 'package:flutter/material.dart';
import 'package:force_update_helper/force_update_helper.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/core/app_state_observer.dart';
import 'package:lola_ai_app/features/core/logger.dart';
import 'package:lola_ai_app/services/ForceUpdate/force_update.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _rootNavigatorKey,
      navigatorObservers: [AppStateObserver(), SentryNavigatorObserver()],
      title: 'Lola App',
      theme: themeProvider(),
      initialRoute: '/',
      routes: appRoutes,
      onGenerateRoute: routesProvider,
      builder: (context, child) => ForceUpdateWidget(
        navigatorKey: _rootNavigatorKey,
        forceUpdateClient: ForceUpdateClient(
          // TODO: fetch from an API endpoint or via Firebase Remote Config
          fetchRequiredVersion: ForceUpdate.minimumiOSVersion,
          // TODO: Set correct APP_STORE_ID in the .env files
          // we use another appid for testing purposes
          iosAppStoreId: Env.appStoreId,
        ),
        allowCancel: false,
        showForceUpdateAlert: ForceUpdate.showUpdateDialog,
        showStoreListing: (storeUrl) => ForceUpdate.launchStoreUrl(storeUrl)
            .catchError((e, st) => ErrorLogger.logException(e, st)),
        onException: ErrorLogger.logException,
        child: child!,
      ),
    );
  }

  // TODO: global theme?
  ThemeData themeProvider() {
    return ThemeData(
      // brightness: Brightness.dark,
      // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      brightness: Brightness.dark,
      primaryColor: Colors.blueGrey,
      useMaterial3: true,
    );
  }
}
