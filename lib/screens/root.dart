import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/core/app_state_observer.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [AppStateObserver()],
      title: 'Lola App',
      theme: themeProvider(),
      initialRoute: '/initial',
      // todo: search on github
      routes: appRoutes,
      onGenerateRoute: routesProvider,
    );
  }

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
