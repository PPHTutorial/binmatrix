import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration loaded from environment variables
/// 
/// SECURITY NOTE: 
/// - .env files bundled with the app CAN be extracted
/// - This provides organization, NOT true security
/// - For production, consider using build-time constants or secure storage
/// - Never commit .env files with real credentials
class AppConfig {
  static bool _initialized = false;
  
  /// Initialize configuration from .env file
  /// Call this in main() before running the app
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Load .env file from assets (must be listed in pubspec.yaml)
      // For development: use .env.dev
      // For production: use build-time constants instead
      await dotenv.load(fileName: ".env");
      _initialized = true;
    } catch (e) {
      // .env file not found or couldn't be loaded
      // This is OK - we'll use default/fallback values
      print('Warning: Could not load .env file: $e');
      print('Using default/fallback configuration');
      _initialized = true;
    }
  }
  
  /// Get encryption key salt from .env
  /// Falls back to default if not set
  /// Strips quotes if present
  static String get encryptionKeySalt {
    final value = dotenv.env['ENCRYPTION_KEY_SALT']?.replaceAll('"', '')?.trim();
    return value ?? 'binmatrix_2024_secure_key_salt_v1';
  }
  
  /// Get encryption key secret from .env
  /// Returns empty string if not set
  /// Strips quotes if present
  static String get encryptionKeySecret {
    final value = dotenv.env['ENCRYPTION_KEY_SECRET']?.replaceAll('"', '')?.trim();
    return value ?? '';
  }
  
  /// Check if .env was loaded successfully
  static bool get isLoaded => _initialized && dotenv.isInitialized;
  
  /// Get any environment variable
  static String? getEnv(String key) => dotenv.env[key];
  
  /// Get environment variable with default
  static String getEnvOrDefault(String key, String defaultValue) {
    return dotenv.env[key] ?? defaultValue;
  }
}

