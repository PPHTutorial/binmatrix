import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Test script to verify encryption and decryption keys match
/// Run: dart run tools/test_key_derivation.dart

void main() async {
  print('🔑 Testing Key Derivation\n');
  
  // Load .env (same as encryption tool)
  final env = await _loadEnvFile();
  final keySalt = env['ENCRYPTION_KEY_SALT']?.replaceAll('"', '')?.trim() ?? 
                  'binmatrix_2024_secure_key_salt_v1';
  final keySecret = env['ENCRYPTION_KEY_SECRET']?.replaceAll('"', '')?.trim() ?? '';
  
  // App constants (same as runtime)
  const appName = 'BinMatrix';
  const appVersion = '10.2.25';
  
  // Build key (same format as encryption tool)
  final combinedKey = keySecret.isNotEmpty 
      ? '$keySalt:$keySecret:$appName:$appVersion'
      : '$keySalt:$appName:$appVersion';
  
  // Derive key (same as both tools)
  final keyBytes = _deriveKey(combinedKey);
  
  print('✅ Key Derivation Test:');
  print('   Salt length: ${keySalt.length}');
  print('   Secret length: ${keySecret.length}');
  print('   Combined key length: ${combinedKey.length}');
  print('   Derived key (first 16 bytes hex): ${keyBytes.sublist(0, 16).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  print('   Key derivation: SUCCESS\n');
  
  // Verify against hardcoded fallback values
  const hardcodedSalt = "9v3Qy8zRk7F1mL2pT6hXb0a4eNqVw1yZsK0uPqR5t8";
  const hardcodedSecret = "6f2a9d4b1c7e8f0a3b4c5d6e7f8091a2b3c4d5e6f7890abc123def4567890fed";
  
  final hardcodedKey = '$hardcodedSalt:$hardcodedSecret:$appName:$appVersion';
  final hardcodedKeyBytes = _deriveKey(hardcodedKey);
  
  print('🔍 Comparing with hardcoded fallback:');
  print('   Salt match: ${keySalt == hardcodedSalt}');
  print('   Secret match: ${keySecret == hardcodedSecret}');
  print('   Keys match: ${_keysEqual(keyBytes, hardcodedKeyBytes)}');
  
  if (keySalt == hardcodedSalt && keySecret == hardcodedSecret) {
    print('\n✅ Keys match! Encryption and decryption should work.');
  } else {
    print('\n❌ Keys do NOT match! Update hardcoded values in KeyDerivationHelper.');
    print('   Expected salt: $keySalt');
    print('   Expected secret: $keySecret');
  }
}

Future<Map<String, String>> _loadEnvFile() async {
  final env = <String, String>{};
  final envFile = File('.env');
  
  if (!await envFile.exists()) {
    return env;
  }
  
  try {
    final lines = await envFile.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      
      final index = trimmed.indexOf('=');
      if (index > 0) {
        final key = trimmed.substring(0, index).trim();
        var value = trimmed.substring(index + 1).trim();
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.substring(1, value.length - 1);
        }
        env[key] = value;
      }
    }
  } catch (e) {
    print('Warning: Failed to read .env file: $e');
  }
  
  return env;
}

Uint8List _deriveKey(String input) {
  final bytes = utf8.encode(input);
  final hash = sha256.convert(bytes);
  return Uint8List.fromList(hash.bytes.sublist(0, 32));
}

bool _keysEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

