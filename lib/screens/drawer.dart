import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/core/routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      onDestinationSelected: (index) {
        debugPrint("$index");
        var args = {'subroute': '/otros'};
        if (index case 0) {
          Navigator.pushNamed(context, '/opciones',
              arguments: ("/mensajes", "luis"));
        } else if (index case 1) {
          Navigator.pushNamed(context, '/opciones',
              arguments: ProfileArgs(city: "jamon", country: "bolivia"));
        } else if (index case 2) {
          Navigator.pushNamed(context, '/opciones', arguments: args);
        } else if (index case 3) {
          Navigator.of(context).pop();
        }
      },
      selectedIndex: 0,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            'Opciones',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...destinations.map(
          (ExampleDestination destination) {
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
        const NavigationDrawerDestination(
          label: Text("Cerrar"),
          icon: Icon(Icons.clear),
          selectedIcon: Icon(Icons.clear),
        )
      ],
    );
  }
}
