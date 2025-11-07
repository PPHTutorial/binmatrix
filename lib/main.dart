import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'services/iap/subscription_manager.dart';
import 'core/config/app_config.dart';
import 'services/storage/bin_history_service.dart';
import 'services/storage/bin_favorites_service.dart';
import 'services/ads/ad_service.dart';
import 'services/ads/app_open_ad_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration from .env (if available)
  // Note: .env files bundled with the app CAN be extracted
  // This is for convenience, not security
  await AppConfig.initialize();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize persistence services for history and favorites
  await BinHistoryService.instance.initialize();
  await BinFavoritesService.instance.initialize();

  // Initialize subscription manager
  await SubscriptionManager.instance.initialize();

  // Initialize AdMob (only if not Pro user)
  if (!SubscriptionManager.instance.isProUser) {
    await AdService.instance.initialize();
    // Load app open ad after initialization
    await AppOpenAdService.instance.loadAd();
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Pre-warm disabled

  // Run app with lifecycle management for App Open ads
  runApp(
    ProviderScope(
      child: const AppLifecycleWrapper(
        child: BinMatrixApp(),
      ),
    ),
  );
}

/// Wrapper widget to handle app lifecycle for App Open ads
class AppLifecycleWrapper extends StatefulWidget {
  final Widget child;

  const AppLifecycleWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Show app open ad when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      // Don't show ads for Pro users
      if (!SubscriptionManager.instance.isProUser) {
        // Small delay to ensure app is fully resumed
        Future.delayed(const Duration(milliseconds: 500), () {
          AppOpenAdService.instance.showAdIfAvailable();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
