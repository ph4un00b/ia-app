import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/main.dart';
import 'package:path_provider/path_provider.dart';

enum NavigationAction { push, pop, replace }

class AppStateObserver extends NavigatorObserver {
  @override
  Future<void> didPush(
      Route<dynamic> route, Route<dynamic>? previousRoute) async {
    if (route.settings.name == '/voz') {
      final directory = await getApplicationDocumentsDirectory();
      final remindersFile = File('${directory.path}/jamon.md');

      AppStatus.instance.currentStatus =
          remindersFile.existsSync() ? AppState.active : AppState.onboarding;
    }
    _logNavigation(route: route, action: NavigationAction.push);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logNavigation(route: route, action: NavigationAction.pop);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _logNavigation(route: newRoute, action: NavigationAction.replace);
    }
  }

  void _logNavigation({
    required Route<dynamic> route,
    required NavigationAction action,
  }) =>
      log('Screen ${action.name}: ${route.settings.name ?? ' 😡 unnamed'}',
          name: 'Navigation');
}
