import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'key_derivation_helper.dart';

/// Service for decrypting encrypted BIN database
/// 
/// Security Notes:
/// - The encrypted file is bundled as an asset (read-only at runtime)
/// - Decryption key is derived from app constants (same as encryption tool)
/// - The file cannot be modified at runtime (assets are read-only)
/// - For stronger security, consider using AES encryption in production
class DatabaseEncryptionService {
  static const String _encryptedAssetPath = 'assets/data/bin_database.enc';
  
  // Key derivation - must match the encryption tool
  // This combines a salt with app-specific constants for key derivation
  static String get _keySalt => _deriveKeyFromApp();
  
  /// Derive key from app constants (must match encryption tool's key derivation)
  /// 
  /// IMPORTANT: This must match the key derivation in tools/encrypt_database.dart
  /// Uses KeyDerivationHelper for consistent key derivation
  static String _deriveKeyFromApp() {
    return KeyDerivationHelper.deriveKey();
  }
  
  /// Decrypt and load the BIN database
  /// 
  /// The database is:
  /// - Encrypted at build time using the encryption tool
  /// - Bundled as a read-only asset
  /// - Decrypted in memory at runtime
  /// - Cannot be modified by users (asset files are immutable)
  static Future<List<Map<String, dynamic>>> decryptDatabase() async {
    try {
      // Load encrypted asset (read-only, cannot be modified)
      final ByteData encryptedData = await rootBundle.load(_encryptedAssetPath);
      final Uint8List encryptedBytes = encryptedData.buffer.asUint8List();
      
      // Derive decryption key (must match encryption tool)
      // The encryption tool reads from .env, but at runtime we derive from app constants
      // This ensures only the app can decrypt its own database
      final key = _deriveKey(_keySalt);
      
      // XOR decryption (matches encryption tool)
      final decryptedBytes = _xorDecrypt(encryptedBytes, key);
      
      // Decode JSON with better error handling
      String jsonString;
      try {
        jsonString = utf8.decode(decryptedBytes);
      } catch (e) {
        // If UTF-8 decoding fails, the decryption key is likely wrong
        throw Exception('Failed to decode decrypted data as UTF-8. This usually means the encryption key is incorrect. Error: $e');
      }
      
      // Parse JSON
      dynamic jsonData;
      try {
        jsonData = json.decode(jsonString);
      } catch (e) {
        throw Exception('Failed to parse JSON. Decryption may have used wrong key. Error: $e');
      }
      
      // Convert to list of maps
      if (jsonData is! List) {
        throw Exception('Expected JSON array but got: ${jsonData.runtimeType}');
      }
      
      return jsonData.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to decrypt database: $e');
    }
  }
  
  /// Derive a key from a string (simple hash-based)
  static Uint8List _deriveKey(String input) {
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return Uint8List.fromList(hash.bytes.sublist(0, 32)); // Use first 32 bytes
  }
  
  /// XOR decryption (simple obfuscation)
  static Uint8List _xorDecrypt(Uint8List data, Uint8List key) {
    final result = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      result[i] = data[i] ^ key[i % key.length];
    }
    return result;
  }
  
  /// Check if database is available
  static Future<bool> isDatabaseAvailable() async {
    try {
      await rootBundle.load(_encryptedAssetPath);
      return true;
    } catch (e) {
      return false;
    }
  }
}
