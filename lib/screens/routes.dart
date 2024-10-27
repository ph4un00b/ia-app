import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/core/routes.dart';
import 'package:lola_ai_app/screens/voz/initial_screen.dart';
import 'package:lola_ai_app/screens/voz/voz_screen.dart';

import 'inicio/inicio_screen.dart';
import 'opciones/messages/messages_screen.dart';
import 'opciones/others/options_others_screen.dart';
import 'opciones/profile/options_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void dispose() {
    debugPrint('disposing home screen');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.popAndPushNamed(context, '/second');
          },
          child: const Text('Go to Second Screen'),
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {

  @override
  void initState() {
    super.initState();
    debugPrint('👀 initializing second screen');
  }

  @override
  void dispose() {
    debugPrint('disposing second screen');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('second Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.popAndPushNamed(context, '/voz');
          },
          child: const Text('Go to voz Screen'),
        ),
      ),
    );
  }
}

Route<dynamic>? routesProvider(RouteSettings settings) {
  debugPrint(settings.toString());
  var routeParams = (settings.name, settings.arguments);

  return switch (routeParams) {
    (String name, _) when name == "/" => pageRoute(const InicioScreen()),
    (String name, Null _) when name == "/voz" => pageRoute(const VozScreen()),
    (String name, Null _) when name == "/initial" =>
      pageRoute(const InitialVozScreen()),
    // (String name, Null _) when name == "/voz" => pageRoute(const HomeScreen()),
    // (String name, Null _) when name == "/second" => pageRoute(const SecondScreen()),
    // (String name, Null _) when name == "/voz" => pageRoute(MessagesScreen(items: List<String>.generate(10000, (i) => 'Item $i'))),
    (String name, Object params) when name == "/opciones" => opciones(params),
    _ => throw UnimplementedError(),
  };
}

MaterialPageRoute<dynamic> opciones(Object params) {
  debugPrint(params.toString());
  return switch (params) {
    (ProfileArgs _) => pageRoute(const OptProfileScreen()),
    {'subroute': String r} when r == "/otros" =>
      pageRoute(const OptOthersScreen()),
    (String subname, _) when subname == "/mensajes" => pageRoute(
        MessagesScreen(items: List<String>.generate(10000, (i) => 'Item $i'))),
    _ => throw UnimplementedError(),
  };
}

MaterialPageRoute<dynamic> pageRoute(Widget screen) {
  return MaterialPageRoute(builder: (_) => screen);
}
