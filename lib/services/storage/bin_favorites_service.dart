import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/bin_info.dart';

/// Service for managing favorite BINs
class BinFavoritesService {
  static BinFavoritesService? _instance;
  static BinFavoritesService get instance => _instance ??= BinFavoritesService._();
  
  BinFavoritesService._();

  Box? _box;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _box = await Hive.openBox(AppConstants.boxBinFavorites);
      _initialized = true;
    } catch (e) {
      print('Error initializing favorites service: $e');
      _initialized = true;
    }
  }

  /// Add a BIN to favorites
  Future<void> addFavorite(BinInfo binInfo) async {
    await initialize();
    if (_box == null) return;

    try {
      final favoriteItem = {
        'bin': binInfo.bin,
        'timestamp': DateTime.now().toIso8601String(),
        'data': binInfo.toJson(),
      };

      await _box!.put(binInfo.bin, favoriteItem);
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  /// Remove a BIN from favorites
  Future<void> removeFavorite(String bin) async {
    await initialize();
    if (_box == null) return;

    try {
      await _box!.delete(bin);
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  /// Check if a BIN is favorite
  bool isFavorite(String bin) {
    if (_box == null || !_initialized) return false;
    try {
      return _box!.containsKey(bin);
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  /// Get all favorites
  List<BinInfo> getFavorites() {
    if (_box == null || !_initialized) return [];

    try {
      final items = _box!.values.toList();
      if (items.isEmpty) return [];
      
      items.sort((a, b) {
        try {
          final mapA = a as Map;
          final mapB = b as Map;
          final timeA = DateTime.parse(mapA['timestamp'].toString());
          final timeB = DateTime.parse(mapB['timestamp'].toString());
          return timeB.compareTo(timeA);
        } catch (e) {
          return 0;
        }
      });

      return items.map((item) {
        try {
          final mapItem = item as Map;
          final data = mapItem['data'];
          if (data == null) return null;
          
          // Convert Map<dynamic, dynamic> to Map<String, dynamic>
          final dataMap = Map<String, dynamic>.from(data as Map);
          return BinInfo.fromJson(dataMap);
        } catch (e) {
          print('Error parsing favorite item: $e');
          return null;
        }
      }).whereType<BinInfo>().toList();
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    await initialize();
    if (_box == null) return;
    await _box!.clear();
  }

  /// Get favorites count
  int getFavoritesCount() {
    if (_box == null) return 0;
    return _box!.length;
  }
}

