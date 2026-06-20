import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:quizaipro_mobile/core/config/app_constants.dart';

class SecureStorage {
  SecureStorage()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  final FlutterSecureStorage _storage;

  // ── Access token ──────────────────────────────────────────────────────────

  Future<void> writeAccessToken(String token) =>
      _storage.write(key: AppConstants.accessTokenKey, value: token);

  Future<String?> readAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  Future<void> deleteAccessToken() =>
      _storage.delete(key: AppConstants.accessTokenKey);

  // ── Refresh token ─────────────────────────────────────────────────────────

  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: AppConstants.refreshTokenKey, value: token);

  Future<String?> readRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  Future<void> deleteRefreshToken() =>
      _storage.delete(key: AppConstants.refreshTokenKey);

  // ── Encryption keys (Drift / Hive) ────────────────────────────────────────

  Future<void> writeDriftEncryptionKey(String key) =>
      _storage.write(key: 'drift_encryption_key', value: key);

  Future<String?> readDriftEncryptionKey() =>
      _storage.read(key: 'drift_encryption_key');

  // ── Bulk ops ──────────────────────────────────────────────────────────────

  Future<void> clearAuthTokens() => Future.wait([
        deleteAccessToken(),
        deleteRefreshToken(),
      ]);

  Future<void> clearAll() => _storage.deleteAll();
}
