import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/main.dart';
import 'package:path_provider/path_provider.dart';

enum NavigationAction {
  push,
  pop,
  replace;

  Future<void> trackScreen({required String routeName}) async {
    if (kReleaseMode) {
      await AppStatus.instance.mixpanel
          ?.track('Screen', properties: {'name': routeName, 'action': name});
    } else {
      log('trackScreen($routeName, $this)', name: 'Navigation');
    }
  }
}

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
  }) {
    if (route.settings.name != null) {
      action.trackScreen(routeName: route.settings.name!);
    } else {
      log('Route name is missing', name: 'Navigation');
    }
  }
}
