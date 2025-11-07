import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bin_info.dart';
import '../../services/storage/bin_favorites_service.dart';
import '../../services/storage/bin_history_service.dart';

/// Provider for favorites list
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<BinInfo>>((ref) {
  return FavoritesNotifier();
});

/// Provider to check if a BIN is favorite
final isFavoriteProvider = Provider.family<bool, String>((ref, bin) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.any((item) => item.bin == bin);
});

class FavoritesNotifier extends StateNotifier<List<BinInfo>> {
  final BinFavoritesService _favoritesService = BinFavoritesService.instance;

  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await _favoritesService.initialize();
    state = _favoritesService.getFavorites();
  }

  // Expose for refresh
  Future<void> reload() => _loadFavorites();

  Future<void> toggleFavorite(BinInfo binInfo) async {
    if (_favoritesService.isFavorite(binInfo.bin)) {
      await _favoritesService.removeFavorite(binInfo.bin);
    } else {
      await _favoritesService.addFavorite(binInfo);
    }
    state = _favoritesService.getFavorites();
  }

  Future<void> addFavorite(BinInfo binInfo) async {
    await _favoritesService.addFavorite(binInfo);
    state = _favoritesService.getFavorites();
  }

  Future<void> removeFavorite(String bin) async {
    await _favoritesService.removeFavorite(bin);
    state = _favoritesService.getFavorites();
  }

  Future<void> clearFavorites() async {
    await _favoritesService.clearFavorites();
    state = [];
  }
}

/// Provider for history list
final historyProvider = StateNotifierProvider<HistoryNotifier, List<BinInfo>>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<List<BinInfo>> {
  final BinHistoryService _historyService = BinHistoryService.instance;

  HistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await _historyService.initialize();
    state = _historyService.getHistory();
  }

  // Expose for refresh
  Future<void> reload() => _loadHistory();

  Future<void> addToHistory(BinInfo binInfo) async {
    await _historyService.addToHistory(binInfo);
    state = _historyService.getHistory();
  }

  Future<void> removeFromHistory(String bin) async {
    await _historyService.removeFromHistory(bin);
    state = _historyService.getHistory();
  }

  Future<void> clearHistory() async {
    await _historyService.clearHistory();
    state = [];
  }
}
