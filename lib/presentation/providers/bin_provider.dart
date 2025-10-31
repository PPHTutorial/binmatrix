import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bin_info.dart';
import '../../services/bin/bin_lookup_service.dart';

/// BIN lookup state
class BinLookupState {
  final BinInfo? binInfo;
  final bool isLoading;
  final String? error;

  const BinLookupState({
    this.binInfo,
    this.isLoading = false,
    this.error,
  });

  BinLookupState copyWith({
    BinInfo? binInfo,
    bool? isLoading,
    String? error,
  }) {
    return BinLookupState(
      binInfo: binInfo ?? this.binInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// BIN lookup provider
class BinLookupNotifier extends StateNotifier<AsyncValue<BinInfo?>> {
  BinLookupNotifier() : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await BinLookupService.instance.initialize();
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
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final binLookupProvider = StateNotifierProvider<BinLookupNotifier, AsyncValue<BinInfo?>>(
  (ref) => BinLookupNotifier(),
);

