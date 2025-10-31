/// Global application constants
class AppConstants {
  // App Info
  static const String appName = 'BinMatrix';
  static const String appVersion = '10.2.25';
  static const String appVersionCode = '2';
  
  // BIN Database
  static const String encryptedDatabasePath = 'assets/data/bin_database.enc';
  
  // Performance
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration debounceDelay = Duration(milliseconds: 300);
  
  // Search & History
  static const int maxSearchHistory = 50;
  static const int maxLookupHistory = 100;
  
  // Local Storage Keys
  static const String keyProStatus = 'pro_status';
  static const String keyThemeMode = 'theme_mode';
  static const String keySearchHistory = 'bin_search_history';
  static const String keyLookupHistory = 'bin_lookup_history';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyCacheSize = 'cache_size';
  
  // Hive Box Names
  static const String boxBinFavorites = 'bin_favorites';
  static const String boxBinHistory = 'bin_lookup_history';
  static const String boxUserPrefs = 'user_prefs';
  static const String boxSubscription = 'subscription_status';
  
  // IAP Product IDs
  static const String iapMonthly = 'pro_monthly';
  static const String iapYearly = 'pro_yearly';
  static const String iapLifetime = 'pro_lifetime';
  
  // Support
  static const String supportEmail = 'support@binmatrix.app';
  static const String privacyPolicyUrl = 'https://binmatrix.app/privacy';
  static const String termsOfServiceUrl = 'https://binmatrix.app/terms';
}

