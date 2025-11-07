import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/ads/ad_config.dart';
import '../../services/iap/subscription_manager.dart';
import '../../app/themes/app_colors.dart';
import '../../core/utils/logger.dart';

/// Native Advanced Ad Widget
/// Displays native ads that blend with app content
class NativeAdWidget extends ConsumerStatefulWidget {
  final bool showAd;
  final double? height;

  const NativeAdWidget({
    super.key,
    this.showAd = true,
    this.height,
  });

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _maybeLoadAd();
  }

  void _maybeLoadAd() {
    // Don't load ads for Pro users
    if (SubscriptionManager.instance.isProUser) {
      AppLogger.i('Skipping native ad load - user is Pro');
      return;
    }

    if (!widget.showAd) {
      AppLogger.i('Skipping native ad load - showAd is false');
      return;
    }

    // Delay ad loading to ensure AdMob is initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      // Double-check Pro status before loading
      if (SubscriptionManager.instance.isProUser) {
        return;
      }

      _loadNativeAd();
    });
  }

  void _loadNativeAd() {
    if (_isLoading || _nativeAd != null) {
      return;
    }

    _isLoading = true;
    final adUnitId = AdConfig.getNativeAdvancedAdUnitId();
    AppLogger.i('Loading native ad with unit ID: $adUnitId');

    final adOptions = NativeAdOptions(
      videoOptions: VideoOptions(
        startMuted: true,
      ),
      adChoicesPlacement: AdChoicesPlacement.topRightCorner,
      mediaAspectRatio: MediaAspectRatio.landscape,
    );

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'listTile', // Use built-in template for simplicity
      request: AdConfig.createAdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          AppLogger.i('Native ad loaded successfully');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isLoading = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          AppLogger.e('Native ad failed to load', error);
          AppLogger.e(
              'Ad error code: ${error.code}, domain: ${error.domain}, message: ${error.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _isLoading = false;
            });
          }
        },
        onAdClicked: (_) {
          AppLogger.i('Native ad clicked');
        },
        onAdImpression: (_) {
          AppLogger.i('Native ad impression recorded');
        },
      ),
      nativeAdOptions: adOptions,
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show ads for Pro users
    if (SubscriptionManager.instance.isProUser) {
      return const SizedBox.shrink();
    }

    if (!widget.showAd) {
      return const SizedBox.shrink();
    }

    if (!_isAdLoaded || _nativeAd == null) {
      // Show loading placeholder
      return Container(
        width: double.infinity,
        height: widget.height ?? 300.h,
        alignment: Alignment.center,
        color: Colors.grey.withOpacity(0.1),
        child: const SizedBox
            .shrink(), // Don't show loading text to avoid confusion
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: widget.height ?? 300.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}
