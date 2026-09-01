import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<void>? _sessionExpiredSubscription;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    _sessionExpiredSubscription = _authRepository.onSessionExpired.listen((_) {
      emit(const Unauthenticated());
    });
  }

  Future<void> restoreSession() async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.restoreSession();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> checkAuthStatus() async {
    await restoreSession();
  }

  Future<void> login({required String username, required String password}) async {
    if (state is AuthLoading) return; // Prevent double-tap duplicate requests

    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(
        username: username,
        password: password,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _cleanErrorMessage(e)));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      await _authRepository.logout();
    } finally {
      emit(const Unauthenticated());
    }
  }

  String _cleanErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring(11);
    }
    return str;
  }

  @override
  Future<void> close() {
    _sessionExpiredSubscription?.cancel();
    return super.close();
  }
}
