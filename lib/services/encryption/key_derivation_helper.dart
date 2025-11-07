import '../../core/constants/app_constants.dart';
import '../../core/config/app_config.dart';

/// Helper to derive encryption/decryption keys consistently
/// 
/// This ensures the same key derivation logic is used everywhere
class KeyDerivationHelper {
  /// Derive the encryption key using the same format as the encryption tool
  /// 
  /// Format: salt:secret:appName:appVersion
  /// This MUST match tools/encrypt_database.dart exactly
  static String deriveKey() {
    final appName = AppConstants.appName;
    final appVersion = AppConstants.appVersion;
    
    // Try to get from .env first (development)
    // Note: .env file may not be available at runtime (not in assets for security)
    // So we have fallback to hardcoded values
    
    String baseSalt;
    String encryptionSecret;
    
    // Check if .env was loaded (only works if .env is in assets, which we don't recommend)
    if (AppConfig.isLoaded) {
      baseSalt = AppConfig.encryptionKeySalt;
      encryptionSecret = AppConfig.encryptionKeySecret;
    } else {
      // Fallback to hardcoded values (production)
      // These MUST match your .env file values exactly
      // IMPORTANT: Update these if you change .env values
      baseSalt = "9v3Qy8zRk7F1mL2pT6hXb0a4eNqVw1yZsK0uPqR5t8";
      encryptionSecret = "6f2a9d4b1c7e8f0a3b4c5d6e7f8091a2b3c4d5e6f7890abc123def4567890fed";
    }
    
    // Debug: Uncomment to verify key derivation
    // print('Key derivation - Salt: ${baseSalt.length} chars, Secret: ${encryptionSecret.length} chars');
    
    // Build key string matching encryption tool format
    // Format: salt:secret:appName:appVersion
    if (encryptionSecret.isEmpty) {
      return '$baseSalt:$appName:$appVersion';
    }
    return '$baseSalt:$encryptionSecret:$appName:$appVersion';
  }
  
  /// Debug helper: Print the key derivation (without showing the actual key)
  static void debugKeyDerivation() {
    final keyString = deriveKey();
    final parts = keyString.split(':');
    print('Key derivation:');
    print('  Salt length: ${parts[0].length}');
    print('  Secret length: ${parts.length > 1 ? parts[1].length : 0}');
    print('  App name: ${parts[parts.length - 2]}');
    print('  App version: ${parts[parts.length - 1]}');
    print('  Total key parts: ${parts.length}');
  }
}

