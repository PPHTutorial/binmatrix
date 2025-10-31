import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';

/// Service for decrypting encrypted BIN database
/// Uses AES encryption with a key derived from app-specific constants
class DatabaseEncryptionService {
  static const String _encryptedAssetPath = 'assets/data/bin_database.enc';
  
  // App-specific key derivation salt (should be obfuscated in production)
  static const String _keySalt = 'binmatrix_2024_secure_key_salt_v1';
  
  /// Decrypt and load the BIN database
  static Future<List<Map<String, dynamic>>> decryptDatabase() async {
    try {
      // Load encrypted asset
      final ByteData encryptedData = await rootBundle.load(_encryptedAssetPath);
      final Uint8List encryptedBytes = encryptedData.buffer.asUint8List();
      
      // Derive decryption key from salt
      final key = _deriveKey(_keySalt);
      
      // Simple XOR decryption (for obfuscation - not true security)
      // In production, use proper AES encryption
      final decryptedBytes = _xorDecrypt(encryptedBytes, key);
      
      // Decode JSON
      final jsonString = utf8.decode(decryptedBytes);
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList.map((item) => item as Map<String, dynamic>).toList();
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

