import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/main.dart';

enum NavigationAction { push, pop, replace }

class AppStateObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == '/voz') {
      AppStatus.instance.currentStatus = AppState.active;
    }
    _logNavigation(route, NavigationAction.push);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logNavigation(route, NavigationAction.pop);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _logNavigation(newRoute, NavigationAction.replace);
    }
  }

  void _logNavigation(Route<dynamic> route, NavigationAction action) {
    final routeName = route.settings.name;
    if (routeName != null) {
      log('Screen ${action.name}: $routeName', name: 'Navigation');
      // print('👻 Screen ${action.name}: $routeName name: Navigation');
    } else {
      log('Screen ${action.name}: $routeName', name: 'Navigation');
    }
  }
}
