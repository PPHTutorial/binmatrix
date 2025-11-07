# BIN Database Encryption Guide

## Overview

The BIN database is encrypted and bundled with the app to protect sensitive data while preventing unauthorized modifications.

## Security Model

1. **Source JSON** (not in version control)
   - Location: `assets/data/bin_database_source.json`
   - Gitignored - never committed
   - Contains your original BIN data

2. **Encrypted Database** (committed to version control)
   - Location: `assets/data/bin_database.enc`
   - Encrypted using keys from `.env`
   - Safe to commit (encrypted, can't be read without keys)

3. **Encryption Keys** (not in version control)
   - Location: `.env` (gitignored)
   - Contains encryption keys
   - Never commit this file!

4. **Runtime Protection**
   - The encrypted file is bundled as an **asset** (read-only)
   - Users cannot modify the database file at runtime
   - Only the app can decrypt using embedded app constants

## Setup Instructions

### Step 1: Copy Source JSON to Project

1. Copy your JSON file to: `assets/data/bin_database_source.json`
   ```bash
   # Example (Windows)
   copy "C:\Users\samue\OneDrive\Desktop\A - M (MOLDOVA).json" assets\data\bin_database_source.json
   ```

2. The file will be automatically gitignored (won't be committed)

### Step 2: Create .env File

1. Copy the example file:
   ```bash
   copy .env.example .env
   ```

2. Edit `.env` and set your encryption keys:
   ```env
   ENCRYPTION_KEY_SALT=binmatrix_2024_secure_key_salt_v1
   ENCRYPTION_KEY_SECRET=your_very_secure_secret_key_here
   ```

3. **Important**: The `.env` file is gitignored - never commit it!

### Step 3: Encrypt the Database

Run the encryption tool:
```bash
dart run tools/encrypt_database.dart
```

This will:
- Read `assets/data/bin_database_source.json`
- Encrypt using keys from `.env`
- Create `assets/data/bin_database.enc`
- The encrypted file can be safely committed to version control

### Step 4: Update App Constants (if needed)

If you changed `ENCRYPTION_KEY_SALT` in `.env`, update `lib/core/constants/app_constants.dart` to match, or update the `_deriveKeyFromApp()` method in `DatabaseEncryptionService` to match your encryption tool's key derivation.

## How It Works

### Build Time (Encryption)
```
Source JSON → Read .env keys → Encrypt → Encrypted file
```

### Runtime (Decryption)
```
Encrypted file (asset) → Derive key from app constants → Decrypt → Use in app
```

### Security Features

✅ **Source JSON**: Never committed, gitignored  
✅ **Encryption Keys**: Stored in .env, gitignored  
✅ **Encrypted File**: Can be committed (safe when encrypted)  
✅ **Runtime Protection**: Asset files are read-only, cannot be modified  
✅ **Key Matching**: App can only decrypt files encrypted with matching keys  

## File Structure

```
project/
├── .env                          # ← Gitignored (your encryption keys)
├── .env.example                  # ← Template (safe to commit)
├── assets/
│   └── data/
│       ├── bin_database_source.json  # ← Gitignored (source data)
│       └── bin_database.enc          # ← Committed (encrypted, safe)
├── lib/
│   └── services/
│       └── encryption/
│           └── database_encryption_service.dart  # Runtime decryption
└── tools/
    └── encrypt_database.dart     # Build-time encryption tool
```

## Updating the Database

When you need to update the BIN data:

1. Replace `assets/data/bin_database_source.json` with new data
2. Run encryption tool: `dart run tools/encrypt_database.dart`
3. Commit the updated `assets/data/bin_database.enc`
4. **Never commit** the source JSON or `.env` file

## Troubleshooting

**Error: Source file not found**
- Make sure `assets/data/bin_database_source.json` exists
- Check the file path in the encryption tool

**Error: Failed to decrypt database**
- Ensure app constants match the encryption keys used
- Check that `_deriveKeyFromApp()` matches the encryption tool's key derivation

**Warning: .env not found**
- Tool will use default keys (less secure)
- Copy `.env.example` to `.env` and set custom keys

## Important Security Notes

⚠️ **Never commit**:
- `.env` file
- `assets/data/bin_database_source.json`

✅ **Safe to commit**:
- `assets/data/bin_database.enc` (encrypted)
- `.env.example` (template only)
- Encryption/decryption code

The encrypted database file cannot be modified by users because it's bundled as a read-only asset. Only the app itself can decrypt and use it.
