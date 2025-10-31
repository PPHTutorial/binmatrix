# Encrypting the BIN Database

## Step 1: Install Dependencies

First, make sure you have the crypto package available:

```bash
flutter pub get
```

## Step 2: Encrypt the JSON File

Run the encryption script:

```bash
dart run tools/encrypt_database.dart
```

This will:
1. Read the JSON file from: `C:\Users\samue\OneDrive\Desktop\A - M (MOLDOVA).json`
2. Encrypt it using XOR encryption with a key derived from a salt
3. Save it to: `assets/data/bin_database.enc`

## Step 3: Verify the Encrypted File

The encrypted file should be created in `assets/data/bin_database.enc`. Make sure this file is included in your `pubspec.yaml` under assets:

```yaml
assets:
  - assets/data/
```

## Important Notes

- The encryption uses XOR with a key derived from a salt. This provides basic obfuscation.
- For production, consider using stronger encryption (AES-256) with a key stored securely.
- The encrypted file will be bundled with your app, but reverse engineers would need to:
  1. Find the encrypted file
  2. Discover the encryption method
  3. Find the salt/key
  4. Decrypt the file
  
This makes it significantly harder than having plain JSON, but not impossible for determined attackers.

## Updating the Database

To update the database:
1. Replace the source JSON file
2. Run the encryption script again
3. Rebuild your app

