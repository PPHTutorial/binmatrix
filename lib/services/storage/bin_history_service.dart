import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/bin_info.dart';

/// Service for managing BIN lookup history
class BinHistoryService {
  static BinHistoryService? _instance;
  static BinHistoryService get instance => _instance ??= BinHistoryService._();
  
  BinHistoryService._();

  Box? _box;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _box = await Hive.openBox(AppConstants.boxBinHistory);
      _initialized = true;
    } catch (e) {
      print('Error initializing history service: $e');
      _initialized = true;
    }
  }

  /// Add a BIN lookup to history
  Future<void> addToHistory(BinInfo binInfo) async {
    await initialize();
    if (_box == null) return;

    try {
      final historyItem = {
        'bin': binInfo.bin,
        'timestamp': DateTime.now().toIso8601String(),
        'data': binInfo.toJson(),
      };

      // Check if already exists
      final existing = _box!.values.firstWhere(
        (item) {
          final mapItem = item as Map;
          return mapItem['bin']?.toString() == binInfo.bin;
        },
        orElse: () => <String, dynamic>{},
      );

      if ((existing as Map).isNotEmpty) {
        // Remove old entry
        final key = _box!.keys.firstWhere(
          (k) {
            final item = _box!.get(k);
            if (item == null) return false;
            final mapItem = item as Map;
            return mapItem['bin']?.toString() == binInfo.bin;
          },
          orElse: () => null,
        );
        if (key != null) {
          await _box!.delete(key);
        }
      }

      // Add to beginning
      await _box!.put(DateTime.now().millisecondsSinceEpoch, historyItem);

      // Limit history size
      if (_box!.length > AppConstants.maxLookupHistory) {
        final keys = _box!.keys.toList()..sort();
        while (_box!.length > AppConstants.maxLookupHistory) {
          await _box!.delete(keys.removeAt(0));
        }
      }
    } catch (e) {
      print('Error adding to history: $e');
    }
  }

  /// Get all history items sorted by newest first
  List<BinInfo> getHistory() {
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
          print('Error parsing history item: $e');
          return null;
        }
      }).whereType<BinInfo>().toList();
    } catch (e) {
      print('Error getting history: $e');
      return [];
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    await initialize();
    if (_box == null) return;
    await _box!.clear();
  }

  /// Remove a specific item from history
  Future<void> removeFromHistory(String bin) async {
    await initialize();
    if (_box == null) return;

    try {
      final key = _box!.keys.firstWhere(
        (k) {
          final item = _box!.get(k);
          if (item == null) return false;
          final mapItem = item as Map;
          return mapItem['bin']?.toString() == bin;
        },
        orElse: () => null,
      );
      if (key != null) {
        await _box!.delete(key);
      }
    } catch (e) {
      print('Error removing from history: $e');
    }
  }

  /// Get history count
  int getHistoryCount() {
    if (_box == null) return 0;
    return _box!.length;
  }
}

