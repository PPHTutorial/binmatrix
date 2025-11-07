import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Tool to encrypt the BIN database JSON file
/// 
/// Usage: 
/// 1. Copy .env.example to .env and set your encryption keys
/// 2. Place your JSON file at: assets/data/bin_database_source.json
/// 3. Run: dart run tools/encrypt_database.dart
/// 
/// The encrypted file will be created at: assets/data/bin_database.enc

void main() async {
  // Load environment variables from .env file
  final env = await _loadEnvFile();
  
  // Paths - source JSON should be in project
  const sourceJsonPath = 'assets/data/bin_database_source.json';
  const outputPath = 'assets/data/bin_database.enc';
  
  // Get encryption key from .env or use default
  final keySalt = env['ENCRYPTION_KEY_SALT'] ?? 'binmatrix_2024_secure_key_salt_v1';
  final keySecret = env['ENCRYPTION_KEY_SECRET'] ?? '';
  
  print('🔐 BIN Database Encryption Tool\n');
  
  // Check if source file exists
  final sourceFile = File(sourceJsonPath);
  if (!await sourceFile.exists()) {
    print('❌ Error: Source JSON file not found at: $sourceJsonPath');
    print('   Please place your JSON file at: $sourceJsonPath');
    print('   Or update the sourceJsonPath in this script.\n');
    exit(1);
  }
  
  // Check .env file
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('⚠️  Warning: .env file not found. Using default encryption key.');
    print('   For better security, copy .env.example to .env and set custom keys.\n');
  }
  
  print('📖 Reading source JSON file...');
  final jsonString = await sourceFile.readAsString();
  print('   File size: ${jsonString.length} bytes (${(jsonString.length / 1024 / 1024).toStringAsFixed(2)} MB)\n');
  
  // Derive encryption key
  // IMPORTANT: This must match _deriveKeyFromApp() in database_encryption_service.dart
  // The decryption service uses: baseSalt:appName:appVersion
  // So we need to match that format here
  print('🔑 Deriving encryption key...');
  
  // Match the app constants used in decryption service
  const appName = 'BinMatrix';
  const appVersion = '10.2.25';
  
  // Build key string to match decryption service
  // IMPORTANT: This format MUST match _deriveKeyFromApp() in database_encryption_service.dart
  // The decryption service splits and combines these values to avoid hardcoding full keys
  final combinedKey = keySecret.isNotEmpty 
      ? '$keySalt:$keySecret:$appName:$appVersion'
      : '$keySalt:$appName:$appVersion';
  
  final key = _deriveKey(combinedKey);
  print('   Using key derived from: ${keySecret.isNotEmpty ? "custom secret + app constants" : "salt + app constants"}');
  print('   Key format: salt:secret:appName:appVersion');
  print('   ⚠️  Security: Keys are split and obfuscated in runtime code\n');
  
  // Encrypt the data
  print('🔒 Encrypting data...');
  final jsonBytes = utf8.encode(jsonString);
  final encryptedBytes = _xorEncrypt(Uint8List.fromList(jsonBytes), key);
  
  // Ensure output directory exists
  final outputFile = File(outputPath);
  await outputFile.parent.create(recursive: true);
  
  // Write encrypted file
  print('💾 Writing encrypted file...');
  await outputFile.writeAsBytes(encryptedBytes);
  
  print('\n✅ Encryption complete!');
  print('   Encrypted file: $outputPath');
  print('   Encrypted size: ${encryptedBytes.length} bytes (${(encryptedBytes.length / 1024 / 1024).toStringAsFixed(2)} MB)');
  print('\n⚠️  Remember:');
  print('   - Keep your .env file secure and never commit it to version control');
  print('   - The encrypted file can be committed to version control');
  print('   - Delete or secure the source JSON file after encryption\n');
}

/// Load environment variables from .env file
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
        // Remove quotes if present (both single and double)
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

Uint8List _xorEncrypt(Uint8List data, Uint8List key) {
  final result = Uint8List(data.length);
  for (int i = 0; i < data.length; i++) {
    result[i] = data[i] ^ key[i % key.length];
  }
  return result;
}

