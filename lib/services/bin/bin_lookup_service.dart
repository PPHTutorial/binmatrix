import '../../domain/entities/bin_info.dart';
import '../../data/models/bin_info_model.dart';
import '../encryption/database_encryption_service.dart';
import '../../core/utils/logger.dart';

/// Service for BIN lookup operations
class BinLookupService {
  static BinLookupService? _instance;
  static BinLookupService get instance => _instance ??= BinLookupService._();
  
  BinLookupService._();

  List<BinInfo>? _cachedDatabase;
  bool _isLoading = false;

  /// Initialize and load the database
  Future<void> initialize() async {
    if (_cachedDatabase != null || _isLoading) return;
    
    _isLoading = true;
    try {
      final dbAvailable = await DatabaseEncryptionService.isDatabaseAvailable();
      if (!dbAvailable) {
        AppLogger.w('BIN database not available');
        _cachedDatabase = [];
        return;
      }

      final jsonData = await DatabaseEncryptionService.decryptDatabase();
      _cachedDatabase = jsonData
          .map((item) => BinInfoModel.fromJson(item).toEntity())
          .toList();
      
      AppLogger.i('BIN database loaded: ${_cachedDatabase!.length} entries');
    } catch (e) {
      AppLogger.e('Failed to load BIN database', e);
      _cachedDatabase = [];
    } finally {
      _isLoading = false;
    }
  }

  /// Lookup BIN by 6-8 digit BIN number
  Future<BinInfo?> lookupBin(String binNumber) async {
    // Clean the input (remove spaces, dashes, etc.)
    final cleanBin = binNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Validate BIN length (6-8 digits)
    if (cleanBin.length < 6 || cleanBin.length > 8) {
      return null;
    }

    // Ensure database is loaded
    if (_cachedDatabase == null) {
      await initialize();
    }

    if (_cachedDatabase == null || _cachedDatabase!.isEmpty) {
      return null;
    }

    // Try exact match first (6 digits - standard BIN length)
    final binPrefix6 = cleanBin.substring(0, 6);
    try {
      final exactMatch = _cachedDatabase!.firstWhere(
        (info) => info.bin == binPrefix6,
      );
      return exactMatch;
    } catch (e) {
      // No exact match found, try prefix matching
    }

    // Try prefix match for longer BINs (7-8 digits)
    // Match BINs where the stored BIN is a prefix of the input
    for (final info in _cachedDatabase!) {
      if (cleanBin.startsWith(info.bin) || info.bin.startsWith(cleanBin.substring(0, 6))) {
        return info;
      }
    }

    return null;
  }

  /// Search BINs by bank name
  List<BinInfo> searchByBank(String bankName) {
    if (_cachedDatabase == null || bankName.isEmpty) return [];
    
    final query = bankName.toLowerCase();
    return _cachedDatabase!
        .where((info) => info.bank.toLowerCase().contains(query))
        .toList();
  }

  /// Search BINs by country
  List<BinInfo> searchByCountry(String country) {
    if (_cachedDatabase == null || country.isEmpty) return [];
    
    final query = country.toLowerCase();
    return _cachedDatabase!
        .where((info) => info.country.toLowerCase().contains(query))
        .toList();
  }

  /// Get all unique countries
  List<String> getAllCountries() {
    if (_cachedDatabase == null) return [];
    
    final countries = <String>{};
    for (final info in _cachedDatabase!) {
      if (info.country.isNotEmpty) {
        countries.add(info.country);
      }
    }
    
    final sorted = countries.toList()..sort();
    return sorted;
  }

  /// Get all unique brands
  List<String> getAllBrands() {
    if (_cachedDatabase == null) return [];
    
    final brands = <String>{};
    for (final info in _cachedDatabase!) {
      if (info.brand.isNotEmpty) {
        brands.add(info.brand);
      }
    }
    
    return brands.toList()..sort();
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    if (_cachedDatabase == null) {
      return {
        'totalEntries': 0,
        'countries': 0,
        'brands': 0,
      };
    }

    return {
      'totalEntries': _cachedDatabase!.length,
      'countries': getAllCountries().length,
      'brands': getAllBrands().length,
    };
  }

  /// Clear cache
  void clearCache() {
    _cachedDatabase = null;
  }
}

