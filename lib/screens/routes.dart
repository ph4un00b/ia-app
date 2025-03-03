import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/core/routes.dart';
import 'package:lola_ai_app/screens/opciones/recordatorios/reminders_screen.dart';
import 'package:lola_ai_app/screens/opciones/resumen/resumen_screen.dart';
import 'package:lola_ai_app/screens/splash/splash_screen.dart';
import 'package:lola_ai_app/screens/voz/chat_screen.dart';
import 'package:lola_ai_app/screens/voz/initial_screen.dart';

import 'opciones/messages/messages_screen.dart';
import 'opciones/others/options_others_screen.dart';
import 'opciones/profile/options_profile_screen.dart';

final appRoutes = <String, WidgetBuilder>{
  '/': (ctx) => const SplashScreen(),
  '/initial': (ctx) => const InitialVozScreen(),
  '/voz': (ctx) => const ChatScreen(),
  // '/voz': (ctx) => const VozScreen(),
  '/opciones/recordatorios': (ctx) => const RemindersScreen(),
  '/opciones/resumen': (ctx) => const ResumenScreen(),
};

Route<dynamic>? routesProvider(RouteSettings settings) {
  debugPrint(settings.name);
  // var routeParams = (settings.name, settings.arguments);

  // return switch (routeParams) {
  //   (String name, _) when name == "/" => pageRoute(const InicioScreen()),
  //   (String name, Null _) when name == "/voz" => pageRoute(const VozScreen()),
  //   (String name, Null _) when name == "/initial" =>
  //     pageRoute(const InitialVozScreen()),
  //   // (String name, Null _) when name == "/voz" => pageRoute(const HomeScreen()),
  //   // (String name, Null _) when name == "/second" => pageRoute(const SecondScreen()),
  //   // (String name, Null _) when name == "/voz" => pageRoute(MessagesScreen(items: List<String>.generate(10000, (i) => 'Item $i'))),
  //   (String name, Object params) when name == "/opciones" => opciones(params),
  //   _ => throw UnimplementedError(),
  // };
  return switch (settings.name) {
    '/opciones/mensajes' => pageRoute(MessagesScreen(items: List<String>.generate(10000, (i) => 'Item $i'))),
    // '/opciones/others' => pageRoute(const OptOthersScreen()),
    '/opciones/profile' => MaterialPageRoute(builder: (ctx) => const OptProfileScreen()),
    String() => null,
    null => null,
  };
}

MaterialPageRoute<dynamic> opciones(Object params) {
  debugPrint(params.toString());
  return switch (params) {
    (ProfileArgs _) => pageRoute(const OptProfileScreen()),
    {'subroute': String r} when r == "/otros" => pageRoute(const OptOthersScreen()),
    (String subname, _) when subname == "/mensajes" =>
      pageRoute(MessagesScreen(items: List<String>.generate(10000, (i) => 'Item $i'))),
    _ => throw UnimplementedError(),
  };
}

MaterialPageRoute<dynamic> pageRoute(Widget screen) {
  return MaterialPageRoute(builder: (ctx) => screen);
}
