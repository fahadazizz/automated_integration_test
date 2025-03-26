import 'package:flutter/material.dart';

/// Tracks navigation events in the app.
class NavigationTracker extends NavigatorObserver {
  final List<Map<String, dynamic>> _navigationHistory = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _navigationHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'push',
      'route': route.settings.name ?? route.runtimeType.toString(),
      'previousRoute':
          previousRoute?.settings.name ?? previousRoute?.runtimeType.toString(),
    });
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _navigationHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'pop',
      'route': route.settings.name ?? route.runtimeType.toString(),
      'previousRoute':
          previousRoute?.settings.name ?? previousRoute?.runtimeType.toString(),
    });
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _navigationHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'replace',
      'newRoute': newRoute?.settings.name ?? newRoute?.runtimeType.toString(),
      'oldRoute': oldRoute?.settings.name ?? oldRoute?.runtimeType.toString(),
    });
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _navigationHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'remove',
      'route': route.settings.name ?? route.runtimeType.toString(),
      'previousRoute':
          previousRoute?.settings.name ?? previousRoute?.runtimeType.toString(),
    });
  }

  List<Map<String, dynamic>> getNavigationHistory() => _navigationHistory;
}
