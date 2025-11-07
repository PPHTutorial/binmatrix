import 'package:flutter/material.dart';
import '../../services/iap/subscription_manager.dart';
import '../../services/ads/ad_service.dart';

/// Helper utility for showing ads during navigation
class AdNavigationHelper {
  /// Navigate and show interstitial ad if needed (only for free users)
  static Future<T?> navigateWithAd<T extends Object?>(
    BuildContext context,
    Widget Function() routeBuilder, {
    bool showInterstitial = true,
  }) async {
    // Don't show ads for Pro users
    if (SubscriptionManager.instance.isProUser) {
      return Navigator.push<T>(
        context,
        MaterialPageRoute(builder: (_) => routeBuilder()),
      );
    }
    
    // Show interstitial ad before navigation if enabled
    if (showInterstitial) {
      final adShown = await AdService.instance.showInterstitialAd();
      if (adShown) {
        // Wait a bit for ad to be dismissed
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    // Navigate after ad
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => routeBuilder()),
    );
  }
  
  /// Navigate with rewarded interstitial (for premium content access)
  static Future<T?> navigateWithRewardedInterstitial<T extends Object?>(
    BuildContext context,
    Widget Function() routeBuilder,
    Function() onRewardEarned,
  ) async {
    // Don't show ads for Pro users
    if (SubscriptionManager.instance.isProUser) {
      onRewardEarned();
      return Navigator.push<T>(
        context,
        MaterialPageRoute(builder: (_) => routeBuilder()),
      );
    }
    
    // Show rewarded interstitial (for now, just show regular interstitial)
    final adShown = await AdService.instance.showInterstitialAd();
    if (adShown) {
      await Future.delayed(const Duration(milliseconds: 500));
      onRewardEarned();
    } else {
      // Still allow navigation and reward even if ad failed
      onRewardEarned();
    }
    
    // Navigate after ad
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => routeBuilder()),
    );
  }
}

