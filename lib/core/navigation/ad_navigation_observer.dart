import 'package:flutter/material.dart';

/// Navigation observer - simplified (no ad tracking)
/// Pro version doesn't need ad tracking
class AdNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Pro version - no ad tracking needed
  }
}
