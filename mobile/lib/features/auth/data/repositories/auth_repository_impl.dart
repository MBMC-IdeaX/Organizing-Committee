import '../../../../core/constants/storage_keys.dart';
import '../../../../core/network/session_event_bus.dart';
import '../../../../core/storage/storage_service_interface.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final StorageServiceInterface _storageService;
  final SessionEventBus _sessionEventBus;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required StorageServiceInterface storageService,
    required SessionEventBus sessionEventBus,
  })  : _remoteDataSource = remoteDataSource,
        _storageService = storageService,
        _sessionEventBus = sessionEventBus;

  @override
  Stream<void> get onSessionExpired => _sessionEventBus.onUnauthorized;

  @override
  Future<UserEntity> login({required String username, required String password}) async {
    final response = await _remoteDataSource.login(
      LoginRequestModel(username: username, password: password),
    );

    // Save token and minimal session info securely
    await _storageService.saveToken(response.token);
    await _storageService.write(key: StorageKeys.currentUserId, value: response.user.id.toString());
    await _storageService.write(key: StorageKeys.currentUsername, value: response.user.username);
    await _storageService.write(key: StorageKeys.currentUserRole, value: response.user.role.name);

    return response.toEntity();
  }

  @override
  Future<UserEntity?> restoreSession() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      if (!userModel.active) {
        await _storageService.clearSession();
        return null;
      }

      return UserEntity(
        id: userModel.id,
        username: userModel.username,
        role: userModel.role,
        active: userModel.active,
      );
    } catch (_) {
      // If token is invalid/expired on backend, clear session
      await _storageService.clearSession();
      return null;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await restoreSession();
  }

  @override
  Future<void> logout() async {
    await _storageService.clearSession();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }
}
