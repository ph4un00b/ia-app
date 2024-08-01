import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/core/routes.dart';
import 'package:lola_ai_app/screens/voz/voz_screen.dart';

import 'inicio/inicio_screen.dart';
import 'opciones/messages/messages_screen.dart';
import 'opciones/others/options_others_screen.dart';
import 'opciones/profile/options_profile_screen.dart';

Route<dynamic>? routesProvider(RouteSettings settings) {
  debugPrint(settings.toString());
  var routeParams = (settings.name, settings.arguments);

  return switch (routeParams) {
    (String name, _) when name == "/" => pageRoute(const InicioScreen()),
    (String name, Null _) when name == "/voz" => pageRoute(const VozScreen()),
    // (String name, Null _) when name == "/voz" => pageRoute(MessagesScreen(items: List<String>.generate(10000, (i) => 'Item $i'))),
    (String name, Object params) when name == "/opciones" => opciones(params),
    _ => throw UnimplementedError(),
  };
}

MaterialPageRoute<dynamic> opciones(Object params) {
  debugPrint(params.toString());
  return switch (params) {
    (ProfileArgs _) => pageRoute(const OptProfileScreen()),
    {'subroute': String r} when r == "/otros" => pageRoute(const OptOthersScreen()),
    (String subname, _) when subname == "/mensajes" => pageRoute(MessagesScreen(items: List<String>.generate(10000, (i) => 'Item $i'))),
    _ => throw UnimplementedError(),
  };
}

MaterialPageRoute<dynamic> pageRoute(Widget screen) {
  return MaterialPageRoute(builder: (_) => screen);
}
