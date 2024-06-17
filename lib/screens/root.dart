import 'package:flutter/material.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lola App',
      theme: themeProvider(),
      initialRoute: '/voz',
      // todo: search on github
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
