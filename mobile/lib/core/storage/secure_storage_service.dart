import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';
import 'storage_service_interface.dart';

/// Secure Storage implementation utilizing iOS Keychain and Android Keystore on mobile,
/// with SharedPreferences (HTML5 localStorage) on Web and as a safe fallback.
/// This prevents crashes on Web when served over non-HTTPS LAN origins (where window.crypto.subtle is null).
class SecureStorageService implements StorageServiceInterface {
  final FlutterSecureStorage _storage;
  SharedPreferences? _prefs;

  SecureStorageService({
    FlutterSecureStorage? storage,
    SharedPreferences? prefs,
  })  : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            ),
        _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      final prefs = await _getPrefs();
      await prefs.setString(key, value);
      return;
    }
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      final prefs = await _getPrefs();
      await prefs.setString(key, value);
    }
  }

  @override
  Future<String?> read({required String key}) async {
    if (kIsWeb) {
      final prefs = await _getPrefs();
      return prefs.getString(key);
    }
    try {
      return await _storage.read(key: key);
    } catch (_) {
      final prefs = await _getPrefs();
      return prefs.getString(key);
    }
  }

  @override
  Future<void> delete({required String key}) async {
    if (kIsWeb) {
      final prefs = await _getPrefs();
      await prefs.remove(key);
      return;
    }
    try {
      await _storage.delete(key: key);
    } catch (_) {
      final prefs = await _getPrefs();
      await prefs.remove(key);
    }
  }

  @override
  Future<void> deleteAll() async {
    if (kIsWeb) {
      final prefs = await _getPrefs();
      await prefs.clear();
      return;
    }
    try {
      await _storage.deleteAll();
    } catch (_) {
      final prefs = await _getPrefs();
      await prefs.clear();
    }
  }

  @override
  Future<bool> containsKey({required String key}) async {
    if (kIsWeb) {
      final prefs = await _getPrefs();
      return prefs.containsKey(key);
    }
    try {
      return await _storage.containsKey(key: key);
    } catch (_) {
      final prefs = await _getPrefs();
      return prefs.containsKey(key);
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await write(key: StorageKeys.authToken, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await read(key: StorageKeys.authToken);
  }

  @override
  Future<void> removeToken() async {
    await delete(key: StorageKeys.authToken);
  }

  @override
  Future<void> clearSession() async {
    await deleteAll();
  }
}
