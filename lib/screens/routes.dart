import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/core/routes.dart';
import 'package:lola_ai_app/screens/voz/voz_screen.dart';

import 'inicio/inicio_screen.dart';
import 'opciones/messages/options_messages_screen.dart';
import 'opciones/others/options_others_screen.dart';
import 'opciones/profile/options_profile_screen.dart';

Route<dynamic>? routesProvider(RouteSettings settings) {
  debugPrint(settings.toString());
  var routeParams = (settings.name, settings.arguments);
  var gotoInicio = MaterialPageRoute(builder: (ctx) => const InicioScreen());
  var gotoVoz = MaterialPageRoute(builder: (ctx) => const VozScreen());

  return switch (routeParams) {
    (String name, _) when name == "/" => gotoInicio,
    (String name, Null _) when name == "/voz" => gotoVoz,
    (String name, Object params) when name == "/opciones" =>
      whereOptRoute(params),
    // TODO: Handle this case.
    _ => throw UnimplementedError(),
  };
}

MaterialPageRoute<dynamic> whereOptRoute(Object params) {
  var gotoOptProfile =
      MaterialPageRoute(builder: (ctx) => const OptProfileScreen());
  var gotoOptMessages =
      MaterialPageRoute(builder: (ctx) => const OptMessagesScreen());
  var gotoOptOthers =
      MaterialPageRoute(builder: (ctx) => const OptOthersScreen());

  debugPrint(params.toString());
  return switch (params) {
    (String subname, _) when subname == "/mensajes" => gotoOptMessages,
    (ProfileArgs _) => gotoOptProfile,
    {'subroute': String r} when r == "/otros" => gotoOptOthers,
    // TODO: Handle this case.
    _ => throw UnimplementedError(),
  };
}
