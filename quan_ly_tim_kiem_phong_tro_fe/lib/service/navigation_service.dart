// navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? navigateTo(Widget screen) {
    return navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }
}

final NavigationService navigationService = NavigationService();
