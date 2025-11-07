import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/utils/logger.dart';
import 'ad_config.dart';
import '../iap/subscription_manager.dart';

/// Service for managing App Open Ads
/// App Open ads show when users open or switch back to the app
class AppOpenAdService {
  static AppOpenAdService? _instance;
  static AppOpenAdService get instance => _instance ??= AppOpenAdService._();

  AppOpenAdService._();

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isLoadingAd = false;
  DateTime? _lastAdShownTime;
  static const Duration _adCooldown =
      Duration(minutes: 4); // Don't show ads too frequently

  /// Load an app open ad
  Future<void> loadAd() async {
    // Don't load ads for Pro users
    if (SubscriptionManager.instance.isProUser) {
      AppLogger.i('Skipping app open ad load - user is Pro');
      return;
    }

    if (_isLoadingAd || _appOpenAd != null) {
      AppLogger.i('App open ad already loaded or loading');
      return;
    }

    _isLoadingAd = true;
    final adUnitId = AdConfig.getAppOpenAdUnitId();
    AppLogger.i('Loading app open ad with unit ID: $adUnitId');

    try {
      await AppOpenAd.load(
        adUnitId: adUnitId,
        request: AdConfig.createAdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            AppLogger.i('App open ad loaded successfully');
            _appOpenAd = ad;
            _isLoadingAd = false;
            _registerCallbacks(ad);
          },
          onAdFailedToLoad: (error) {
            AppLogger.e('Failed to load app open ad', error);
            AppLogger.e(
                'Ad error code: ${error.code}, domain: ${error.domain}, message: ${error.message}');
            _isLoadingAd = false;
            _appOpenAd = null;
          },
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Exception loading app open ad', e, stackTrace);
      _isLoadingAd = false;
      _appOpenAd = null;
    }
  }

  void _registerCallbacks(AppOpenAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AppLogger.i('App open ad showed full screen content');
        _isShowingAd = true;
        _lastAdShownTime = DateTime.now();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.e('App open ad failed to show full screen content', error);
        ad.dispose();
        _appOpenAd = null;
        _isShowingAd = false;
        _isLoadingAd = false;
        loadAd(); // Try to load another ad
      },
      onAdDismissedFullScreenContent: (ad) {
        AppLogger.i('App open ad dismissed full screen content');
        ad.dispose();
        _appOpenAd = null;
        _isShowingAd = false;
        _isLoadingAd = false;
        loadAd(); // Load next ad for future use
      },
    );
  }

  /// Show app open ad if available and conditions are met
  Future<bool> showAdIfAvailable() async {
    // Don't show ads for Pro users
    if (SubscriptionManager.instance.isProUser) {
      AppLogger.i('Skipping app open ad - user is Pro');
      return false;
    }

    // Check if ad is available
    if (_appOpenAd == null) {
      AppLogger.i('App open ad not available');
      loadAd(); // Try to load for next time
      return false;
    }

    // Check if ad is currently showing
    if (_isShowingAd) {
      AppLogger.i('App open ad already showing');
      return false;
    }

    // Check cooldown period
    if (_lastAdShownTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShownTime!);
      if (timeSinceLastAd < _adCooldown) {
        AppLogger.i(
            'App open ad in cooldown (${_adCooldown.inMinutes - timeSinceLastAd.inMinutes} minutes remaining)');
        return false;
      }
    }

    try {
      await _appOpenAd!.show();
      return true;
    } catch (e, stackTrace) {
      AppLogger.e('Error showing app open ad', e, stackTrace);
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _isShowingAd = false;
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isShowingAd = false;
    _isLoadingAd = false;
  }
}
