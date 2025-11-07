import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import 'ad_device_helper.dart';
import '../../core/utils/logger.dart';

/// Service for managing ads (banner, interstitial, rewarded)
class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();

  AdService._();

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  int _interstitialAdLoadAttempts = 0;
  static const int _maxInterstitialLoadAttempts = 3;

  DateTime? _lastInterstitialAdShown;
  static const Duration _interstitialAdCooldown = Duration(minutes: 2);

  /// Initialize AdMob
  Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.i('AdMob already initialized');
      return;
    }

    try {
      // Configure test device for test ads
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: ['FDB6404EE2DF76ABCA39527BDAFAB242'],
        ),
      );

      final initResponse = await MobileAds.instance.initialize();
      _isInitialized = true;
      AppLogger.i(
          'AdMob initialized successfully. Adapter status: ${initResponse.adapterStatuses}');

      // Log which ad unit IDs are being used
      AppLogger.i('Using banner ad unit ID: ${AdConfig.getBannerAdUnitId()}');
      AppLogger.i(
          'Using interstitial ad unit ID: ${AdConfig.getInterstitialAdUnitId()}');

      // Configure test devices if using test ads
      final testDeviceIds = AdConfig.getAllTestDeviceIds();
      if (testDeviceIds.isNotEmpty) {
        final requestConfiguration = RequestConfiguration(
          testDeviceIds: testDeviceIds,
        );
        MobileAds.instance.updateRequestConfiguration(requestConfiguration);
        AppLogger.i('Configured ${testDeviceIds.length} test device(s)');
      } else {
        // Log device information so user can add their device ID
        await AdDeviceHelper.logDeviceInfo();
      }

      // Pre-load interstitial ad
      _loadInterstitialAd();
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing AdMob', e, stackTrace);
      _isInitialized = true; // Set to true to prevent retry loops
    }
  }

  /// Load interstitial ad
  void _loadInterstitialAd() {
    if (_interstitialAdLoadAttempts >= _maxInterstitialLoadAttempts) {
      AppLogger.w('Max interstitial ad load attempts reached');
      return;
    }

    final adUnitId = AdConfig.getInterstitialAdUnitId();
    AppLogger.i('Loading interstitial ad with unit ID: $adUnitId');

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdConfig.createAdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _interstitialAdLoadAttempts = 0;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _lastInterstitialAdShown = DateTime.now();
              _loadInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              AppLogger.e('Interstitial ad failed to show', error);
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd();
            },
          );

          AppLogger.i('Interstitial ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          AppLogger.e('Failed to load interstitial ad', error);
          AppLogger.e(
              'Ad error code: ${error.code}, domain: ${error.domain}, message: ${error.message}');
          _isInterstitialAdReady = false;
          _interstitialAdLoadAttempts++;
          _interstitialAd = null;

          // Retry after delay
          Future.delayed(const Duration(seconds: 5), () {
            if (_interstitialAdLoadAttempts < _maxInterstitialLoadAttempts) {
              AppLogger.i(
                  'Retrying to load interstitial ad (attempt $_interstitialAdLoadAttempts/$_maxInterstitialLoadAttempts)');
              _loadInterstitialAd();
            } else {
              AppLogger.w(
                  'Max interstitial ad load attempts reached. Giving up.');
            }
          });
        },
      ),
    );
  }

  /// Show interstitial ad if available and cooldown has passed
  Future<bool> showInterstitialAd({bool force = false}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInterstitialAdReady || _interstitialAd == null) {
      AppLogger.w('Interstitial ad not ready');
      return false;
    }

    // Check cooldown (unless forced)
    if (!force && _lastInterstitialAdShown != null) {
      final timeSinceLastAd =
          DateTime.now().difference(_lastInterstitialAdShown!);
      if (timeSinceLastAd < _interstitialAdCooldown) {
        AppLogger.i('Interstitial ad in cooldown');
        return false;
      }
    }

    try {
      _interstitialAd?.show();
      return true;
    } catch (e) {
      AppLogger.e('Error showing interstitial ad', e);
      return false;
    }
  }

  /// Check if interstitial ad is ready
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  /// Dispose resources
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
