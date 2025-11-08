import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import '../../core/constants/app_constants.dart'; // Not needed - ad constants removed in pro version

/// Ad configuration for AdMob
class AdConfig {
  // Test Ad Unit IDs (for development)
  static const String _testBannerAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerAdUnitIdIOS =
      'ca-app-pub-3940256099942544/2934735716';

  static const String _testInterstitialAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialAdUnitIdIOS =
      'ca-app-pub-3940256099942544/4411468910';

  static const String _testRewardedAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedAdUnitIdIOS =
      'ca-app-pub-3940256099942544/1712485313';

  static const String _testRewardedInterstitialAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/5354046379';
  static const String _testAppOpenAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _testAppOpenAdUnitIdIOS =
      'ca-app-pub-3940256099942544/5575464033';
  static const String _testNativeAdvancedAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/2247696110';
  static const String _testNativeAdvancedAdUnitIdIOS =
      'ca-app-pub-3940256099942544/3986624511';

  // Production Ad Unit IDs
  static const String _prodBannerAdUnitIdAndroid =
      'ca-app-pub-9043208558525567/6516708431';
  static const String _prodInterstitialAdUnitIdAndroid =
      'ca-app-pub-9043208558525567/1175809898';
  static const String _prodRewardedAdUnitIdAndroid =
      'ca-app-pub-9043208558525567/5036105802';
  static const String _prodRewardedInterstitialAdUnitIdAndroid =
      'ca-app-pub-9043208558525567/1334047408';
  static const String _prodAppOpenAdUnitIdAndroid =
      'ca-app-pub-9043208558525567/5004316213';
  static const String _prodNativeAdvancedAdUnitIdAndroid =
      'ca-app-pub-9043208558525567/3723024135';

  static const String _prodInterstitialAdUnitIdIOS =
      'ca-app-pub-9043208558525567/8320213302';
  static const String _prodBannerAdUnitIdIOS =
      'ca-app-pub-9043208558525567/5885621652';
  static const String _prodRewardedAdUnitIdIOS =
      'ca-app-pub-9043208558525567/5502478278';
  static const String _testRewardedInterstitialAdUnitIdIOS =
      'ca-app-pub-3940256099942544/6978759866';
  static const String _prodRewardedInterstitialAdUnitIdIOS =
      'ca-app-pub-9043208558525567/3067886625';
  static const String _prodAppOpenAdUnitIdIOS =
      'ca-app-pub-9043208558525567/5004316213'; // iOS app open ID (if different from Android)
  static const String _prodNativeAdvancedAdUnitIdIOS =
      'ca-app-pub-9043208558525567/3723024135'; // iOS native advanced ID (if different from Android)

  // Automatically use test ads in debug mode, production ads in release mode
  static bool get _useTestAds => kDebugMode;

  // Test Device IDs - Add your device IDs here for testing
  // To get your Android device ID, run: adb logcat | grep -i admob
  // To get your iOS device ID, check Xcode console when loading an ad
  // You can also add them dynamically using device_info_plus package
  static const List<String> _testDeviceIds = [
    // Add your test device IDs here, for example:
    // 'YOUR_ANDROID_ADVERTISING_ID',  // Android: 32-character hex string
    // 'YOUR_IOS_SIMULATOR_ID',        // iOS Simulator
    // 'YOUR_IOS_DEVICE_ID',           // iOS Device
  ];

  /// Get test device IDs
  static List<String> getTestDeviceIds() {
    if (!_useTestAds) return [];
    return _testDeviceIds;
  }

  /// Get all test device IDs
  static List<String> getAllTestDeviceIds(
      {List<String>? additionalTestDevices}) {
    if (!_useTestAds) return [];

    final allTestDevices = [
      ..._testDeviceIds,
      if (additionalTestDevices != null) ...additionalTestDevices,
    ];

    return allTestDevices;
  }

  /// Create an AdRequest (test devices are configured via RequestConfiguration)
  static AdRequest createAdRequest() {
    return const AdRequest();
  }

  /// Get banner ad unit ID
  static String getBannerAdUnitId() {
    if (_useTestAds) {
      return Platform.isAndroid
          ? _testBannerAdUnitIdAndroid
          : _testBannerAdUnitIdIOS;
    } else {
      return Platform.isAndroid
          ? _prodBannerAdUnitIdAndroid
          : _prodBannerAdUnitIdIOS;
    }
  }

  /// Get interstitial ad unit ID
  static String getInterstitialAdUnitId() {
    if (_useTestAds) {
      return Platform.isAndroid
          ? _testInterstitialAdUnitIdAndroid
          : _testInterstitialAdUnitIdIOS;
    } else {
      return Platform.isAndroid
          ? _prodInterstitialAdUnitIdAndroid
          : _prodInterstitialAdUnitIdIOS;
    }
  }

  /// Get rewarded ad unit ID
  static String getRewardedAdUnitId() {
    if (_useTestAds) {
      return Platform.isAndroid
          ? _testRewardedAdUnitIdAndroid
          : _testRewardedAdUnitIdIOS;
    } else {
      return Platform.isAndroid
          ? _prodRewardedAdUnitIdAndroid
          : _prodRewardedAdUnitIdIOS;
    }
  }

  /// Get rewarded interstitial ad unit ID
  static String getRewardedInterstitialAdUnitId() {
    if (_useTestAds) {
      return Platform.isAndroid
          ? _testRewardedInterstitialAdUnitIdAndroid
          : _testRewardedInterstitialAdUnitIdIOS;
    } else {
      return Platform.isAndroid
          ? _prodRewardedInterstitialAdUnitIdAndroid
          : _prodRewardedInterstitialAdUnitIdIOS;
    }
  }

  /// Get app open ad unit ID
  static String getAppOpenAdUnitId() {
    if (_useTestAds) {
      return Platform.isAndroid
          ? _testAppOpenAdUnitIdAndroid
          : _testAppOpenAdUnitIdIOS;
    } else {
      return Platform.isAndroid
          ? _prodAppOpenAdUnitIdAndroid
          : _prodAppOpenAdUnitIdIOS;
    }
  }

  /// Get native advanced ad unit ID
  static String getNativeAdvancedAdUnitId() {
    if (_useTestAds) {
      return Platform.isAndroid
          ? _testNativeAdvancedAdUnitIdAndroid
          : _testNativeAdvancedAdUnitIdIOS;
    } else {
      return Platform.isAndroid
          ? _prodNativeAdvancedAdUnitIdAndroid
          : _prodNativeAdvancedAdUnitIdIOS;
    }
  }

  // Ad frequency settings (not used in pro version - kept for reference)
  // These constants were removed from AppConstants as they're not needed in pro version
  // static int get downloadsBeforeInterstitial => AppConstants.downloadsBeforeInterstitial;
  // static int get minutesBetweenInterstitials => AppConstants.minutesBetweenInterstitials;
  // static int get hoursForRewardedBenefit => AppConstants.hoursForRewardedBenefit;
}
