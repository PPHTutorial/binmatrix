import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Tool to encrypt the BIN database JSON file
/// Usage: dart run tools/encrypt_database.dart

void main() async {
  // Input and output paths
  const inputPath = r'C:\Users\samue\OneDrive\Desktop\A - M (MOLDOVA).json';
  const outputPath = 'assets/data/bin_database.enc';
  const keySalt = 'binmatrix_2024_secure_key_salt_v1';
  
  print('Reading JSON file...');
  final inputFile = File(inputPath);
  if (!await inputFile.exists()) {
    print('Error: Input file not found at $inputPath');
    exit(1);
  }
  
  final jsonString = await inputFile.readAsString();
  print('JSON file size: ${jsonString.length} bytes');
  
  // Derive encryption key
  print('Deriving encryption key...');
  final key = _deriveKey(keySalt);
  
  // Encrypt the data
  print('Encrypting data...');
  final jsonBytes = utf8.encode(jsonString);
  final encryptedBytes = _xorEncrypt(Uint8List.fromList(jsonBytes), key);
  
  // Ensure output directory exists
  final outputFile = File(outputPath);
  await outputFile.parent.create(recursive: true);
  
  // Write encrypted file
  print('Writing encrypted file to $outputPath...');
  await outputFile.writeAsBytes(encryptedBytes);
  
  print('Encryption complete!');
  print('Encrypted file size: ${encryptedBytes.length} bytes');
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

