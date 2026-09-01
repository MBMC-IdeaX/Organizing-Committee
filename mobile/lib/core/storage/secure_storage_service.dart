import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';
import 'storage_service_interface.dart';

/// Secure Storage implementation utilizing iOS Keychain and Android Keystore.
/// Used exclusively for storing JWT tokens and user session data.
class SecureStorageService implements StorageServiceInterface {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
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
