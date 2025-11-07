# BinMatrix Setup Instructions

## Quick Start

### 1. Copy Your JSON File

Copy your BIN database JSON file to the project:

```bash
# Windows PowerShell
copy "C:\Users\samue\OneDrive\Desktop\A - M (MOLDOVA).json" "assets\data\bin_database_source.json"

# Or manually copy to: assets/data/bin_database_source.json
```

⚠️ **Note**: This file is gitignored and won't be committed to version control.

### 2. Set Up Encryption Keys

1. Copy the example environment file:
   ```bash
   copy .env.example .env
   ```

2. Edit `.env` and set your encryption keys (optional but recommended):
   ```env
   ENCRYPTION_KEY_SALT=binmatrix_2024_secure_key_salt_v1
   ENCRYPTION_KEY_SECRET=your_very_secure_secret_key_here
   ```

   ⚠️ **Important**: If you set `ENCRYPTION_KEY_SECRET`, you must also update the decryption service to match. See `lib/services/encryption/database_encryption_service.dart` method `_deriveKeyFromApp()`.

### 3. Encrypt the Database

Run the encryption tool:
```bash
dart run tools/encrypt_database.dart
```

This will:
- ✅ Read `assets/data/bin_database_source.json`
- ✅ Encrypt it using keys from `.env`
- ✅ Create `assets/data/bin_database.enc`
- ✅ The encrypted file is safe to commit to version control

### 4. Verify Setup

1. Check that `assets/data/bin_database.enc` was created
2. Test the app: `flutter run`
3. The app should be able to decrypt and use the database

## File Structure After Setup

```
binmatrix/
├── .env                              # ← Your encryption keys (gitignored)
├── .env.example                      # ← Template (safe to commit)
├── assets/
│   └── data/
│       ├── bin_database_source.json  # ← Source data (gitignored)
│       └── bin_database.enc          # ← Encrypted (committed)
├── lib/
│   └── services/
│       └── encryption/
│           └── database_encryption_service.dart
└── tools/
    └── encrypt_database.dart
```

## Security Notes

✅ **Safe to commit:**
- `assets/data/bin_database.enc` (encrypted file)
- `.env.example` (template)
- All code files

❌ **Never commit:**
- `.env` (contains your encryption keys)
- `assets/data/bin_database_source.json` (source data)

🔒 **Runtime Protection:**
- The encrypted file is bundled as a **read-only asset**
- Users cannot modify the database at runtime
- Only the app can decrypt using embedded app constants

## Updating the Database

When you need to update BIN data:

1. Replace `assets/data/bin_database_source.json`
2. Run: `dart run tools/encrypt_database.dart`
3. Commit the updated `assets/data/bin_database.enc`
4. Test the app

## Troubleshooting

**"Source file not found"**
- Ensure `assets/data/bin_database_source.json` exists
- Check file permissions

**"Failed to decrypt database"**
- Ensure `.env` keys match app constants
- Check `_deriveKeyFromApp()` in `database_encryption_service.dart`

**"Database not available"**
- Verify `assets/data/bin_database.enc` exists
- Check it's listed in `pubspec.yaml` under assets

## Next Steps

After setup, you can:
- Run `flutter run` to test the app
- Start using the BIN checker functionality
- See `README_ENCRYPTION.md` for detailed encryption documentation

