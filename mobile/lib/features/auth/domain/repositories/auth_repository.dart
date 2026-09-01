import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<void> get onSessionExpired;
  Future<UserEntity> login({required String username, required String password});
  Future<UserEntity?> restoreSession();
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
  Future<bool> isAuthenticated();
}
