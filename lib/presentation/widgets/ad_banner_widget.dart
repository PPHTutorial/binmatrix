import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/ads/ad_config.dart';
import '../../services/iap/subscription_manager.dart';
import '../../app/themes/app_colors.dart';

/// Ad banner widget that respects Pro status
class AdBannerWidget extends ConsumerStatefulWidget {
  final bool showAd;
  
  const AdBannerWidget({
    super.key,
    this.showAd = true,
  });

  @override
  ConsumerState<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends ConsumerState<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _maybeLoadAd();
  }

  void _maybeLoadAd() {
    // Don't load ads for Pro users
    if (SubscriptionManager.instance.isProUser) {
      print('Skipping ad load - user is Pro');
      return;
    }

    if (!widget.showAd) {
      print('Skipping ad load - showAd is false');
      return;
    }

    print('Preparing to load banner ad...');
    
    // Delay ad loading to ensure AdMob is initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) {
        print('Widget not mounted, skipping ad load');
        return;
      }
      
      // Double-check Pro status before loading
      if (SubscriptionManager.instance.isProUser) {
        print('Skipping ad load - user is Pro (double check)');
        return;
      }

      print('Loading banner ad...');
      _loadBannerAd();
    });
  }

  void _loadBannerAd() {
    final adUnitId = AdConfig.getBannerAdUnitId();
    print('Loading banner ad with unit ID: $adUnitId');
    
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: AdConfig.createAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print('Banner ad loaded successfully');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load:');
          print('  Error code: ${error.code}');
          print('  Error domain: ${error.domain}');
          print('  Error message: ${error.message}');
          print('  Ad unit ID: $adUnitId');
          ad.dispose();
          _isAdLoaded = false;
        },
        onAdOpened: (_) {
          print('Banner ad opened');
        },
        onAdClosed: (_) {
          print('Banner ad closed');
        },
        onAdImpression: (_) {
          print('Banner ad impression recorded');
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
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

    if (!_isAdLoaded || _bannerAd == null) {
      // Show a placeholder or loading indicator during debug
      return Container(
        width: double.infinity,
        height: 50.h,
        alignment: Alignment.center,
        color: Colors.grey.withOpacity(0.1),
        child: Text(
          'Loading ad...',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      height: 50.h,
      alignment: Alignment.center,
      color: isDark ? AppColors.darkCard : Colors.white,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
