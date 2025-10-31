import 'package:flutter/material.dart';
import 'package:binmatrix/services/iap/subscription_manager.dart';

/// Navigation observer to track screen changes and show ads accordingly
class AdNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    
    // Don't track ads for Pro users
    if (SubscriptionManager.instance.isProUser) {
      return;
    }
    
    // Track navigation for ad display logic
    // (Currently placeholder - can be extended for BIN detail screens)
    
  }
}

