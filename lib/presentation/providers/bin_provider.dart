import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bin_info.dart';
import '../../services/bin/bin_lookup_service.dart';
import '../../services/storage/bin_history_service.dart';
import '../../services/ads/ad_service.dart';
import '../../services/iap/subscription_manager.dart';
import 'favorites_provider.dart' show historyProvider;

/// BIN lookup provider
class BinLookupNotifier extends StateNotifier<AsyncValue<BinInfo?>> {
  final BinHistoryService _historyService = BinHistoryService.instance;
  final Ref _ref;

  BinLookupNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await BinLookupService.instance.initialize();
      await _historyService.initialize();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> lookupBin(String binNumber) async {
    state = const AsyncValue.loading();
    try {
      final result = await BinLookupService.instance.lookupBin(binNumber);
      state = AsyncValue.data(result);
      
      // Add to history if found and refresh history provider
      if (result != null) {
        await _historyService.addToHistory(result);
        _ref.read(historyProvider.notifier).addToHistory(result);
        
        // Show interstitial ad for free users (every few lookups)
        if (!SubscriptionManager.instance.isProUser) {
          // Show ad with some probability (every 3rd lookup or so)
          final random = DateTime.now().millisecondsSinceEpoch % 3;
          if (random == 0) {
            // Fire and forget - don't await
            AdService.instance.showInterstitialAd().catchError((e) => false);
          }
        }
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final binLookupProvider = StateNotifierProvider<BinLookupNotifier, AsyncValue<BinInfo?>>(
  (ref) => BinLookupNotifier(ref),
);

