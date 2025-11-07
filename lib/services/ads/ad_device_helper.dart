import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/utils/logger.dart';

/// Helper to get device IDs for AdMob testing
class AdDeviceHelper {
  static String? _cachedDeviceId;

  /// Get the current device ID for AdMob testing
  /// This will be logged so you can add it to your test devices list
  static Future<String?> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId;
    }

    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        
        // For Android, use the Advertising ID (if available) or Android ID
        // Note: Advertising ID requires Google Play Services
        // Android ID is a fallback but may change on app reinstall
        final deviceId = androidInfo.id; // This is Android ID (fallback)
        
        AppLogger.i('Android Device ID (Android ID): $deviceId');
        AppLogger.i('To get your Advertising ID, check logcat when loading an ad:');
        AppLogger.i('  adb logcat | grep -i "advertising id"');
        AppLogger.i('Or check the error logs when an ad fails to load.');
        AppLogger.i('');
        AppLogger.i('Add this to AdConfig._testDeviceIds for testing:');
        AppLogger.i('  "$deviceId",');
        
        _cachedDeviceId = deviceId;
        return deviceId;
      } else if (Platform.isIOS) {
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;
        
        // For iOS, use the identifierForVendor
        final deviceId = iosInfo.identifierForVendor ?? 'unknown';
        
        AppLogger.i('iOS Device ID (IdentifierForVendor): $deviceId');
        AppLogger.i('For iOS Simulator, use: "SIMULATOR"');
        AppLogger.i('');
        AppLogger.i('Add this to AdConfig._testDeviceIds for testing:');
        AppLogger.i('  "$deviceId",');
        
        _cachedDeviceId = deviceId;
        return deviceId;
      }
    } catch (e) {
      AppLogger.e('Error getting device ID', e);
    }

    return null;
  }

  /// Request the device's advertising ID and log it
  /// This is useful for getting the actual AdMob test device ID
  static Future<void> logDeviceInfo() async {
    AppLogger.i('=== AdMob Device ID Information ===');
    AppLogger.i('Platform: ${Platform.operatingSystem}');
    
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        
        AppLogger.i('Android ID: ${androidInfo.id}');
        AppLogger.i('Manufacturer: ${androidInfo.manufacturer}');
        AppLogger.i('Model: ${androidInfo.model}');
        AppLogger.i('SDK: ${androidInfo.version.sdkInt}');
        AppLogger.i('');
        AppLogger.i('To get your AdMob Advertising ID:');
        AppLogger.i('1. Run the app and try to load an ad');
        AppLogger.i('2. Check logcat: adb logcat | grep -i admob');
        AppLogger.i('3. Look for "Use RequestConfiguration.Builder().setTestDeviceIds"');
        AppLogger.i('4. The device ID will be shown in the error message');
        AppLogger.i('');
        AppLogger.i('Alternatively, use Android ID as fallback:');
        AppLogger.i('  "${androidInfo.id}",');
      } else if (Platform.isIOS) {
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;
        
        AppLogger.i('Identifier For Vendor: ${iosInfo.identifierForVendor}');
        AppLogger.i('Name: ${iosInfo.name}');
        AppLogger.i('Model: ${iosInfo.model}');
        AppLogger.i('System Version: ${iosInfo.systemVersion}');
        AppLogger.i('');
        AppLogger.i('For iOS testing, you can use:');
        AppLogger.i('  "${iosInfo.identifierForVendor ?? "SIMULATOR"}",');
        AppLogger.i('');
        AppLogger.i('Or check Xcode console when loading an ad for the actual device ID');
      }
    } catch (e) {
      AppLogger.e('Error getting device info', e);
    }
    
    AppLogger.i('===================================');
  }

  /// Configure RequestConfiguration with the current device as test device
  static Future<void> configureTestDevice() async {
    final deviceId = await getDeviceId();
    
    if (deviceId == null) {
      AppLogger.w('Could not get device ID for test device configuration');
      return;
    }

    try {
      final requestConfiguration = RequestConfiguration(
        testDeviceIds: [deviceId],
      );
      MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      AppLogger.i('Configured test device: $deviceId');
    } catch (e) {
      AppLogger.e('Error configuring test device', e);
    }
  }
}

