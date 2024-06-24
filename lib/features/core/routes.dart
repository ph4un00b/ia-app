import 'package:flutter/material.dart';

class ProfileArgs {
  ProfileArgs({required this.city, required this.country});
  final String city;
  final String country;

  bool get isGermanCapital {
    return country == 'Germany' && city == 'Berlin';
  }
}

class ExampleDestination {
  const ExampleDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<ExampleDestination> destinations = <ExampleDestination>[
  ExampleDestination(
      'Mensajes', Icon(Icons.mail_outline), Icon(Icons.mail_outline)),
  ExampleDestination(
      'Perfil', Icon(Icons.manage_accounts), Icon(Icons.manage_accounts)),
  ExampleDestination(
      'Otros', Icon(Icons.add_circle_outline), Icon(Icons.add_circle_outline)),
];
