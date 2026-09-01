abstract class StorageServiceInterface {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<bool> containsKey({required String key});

  // Dedicated Auth Methods
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> removeToken();
  Future<void> clearSession();
}
