import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideax_judging/features/auth/domain/entities/user_entity.dart';
import 'package:ideax_judging/features/auth/domain/repositories/auth_repository.dart';
import 'package:ideax_judging/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ideax_judging/features/auth/presentation/cubit/auth_state.dart';
import 'package:ideax_judging/shared/models/user_role.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late StreamController<void> sessionExpiredController;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    sessionExpiredController = StreamController<void>.broadcast();
    when(() => mockAuthRepository.onSessionExpired)
        .thenAnswer((_) => sessionExpiredController.stream);
  });

  tearDown(() {
    sessionExpiredController.close();
  });

  const testAdminUser = UserEntity(
    id: 1,
    username: 'admin',
    role: UserRole.admin,
    active: true,
  );

  const testJudgeUser = UserEntity(
    id: 2,
    username: 'judge1',
    role: UserRole.judge,
    active: true,
  );

  group('AuthCubit Tests', () {
    test('initial state is AuthInitial', () {
      final cubit = AuthCubit(authRepository: mockAuthRepository);
      expect(cubit.state, const AuthInitial());
      cubit.close();
    });

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] when ADMIN login is successful',
      build: () {
        when(() => mockAuthRepository.login(username: 'admin', password: 'password123'))
            .thenAnswer((_) async => testAdminUser);
        return AuthCubit(authRepository: mockAuthRepository);
      },
      act: (cubit) => cubit.login(username: 'admin', password: 'password123'),
      expect: () => [
        const AuthLoading(),
        const Authenticated(user: testAdminUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] when JUDGE login is successful',
      build: () {
        when(() => mockAuthRepository.login(username: 'judge1', password: 'password123'))
            .thenAnswer((_) async => testJudgeUser);
        return AuthCubit(authRepository: mockAuthRepository);
      },
      act: (cubit) => cubit.login(username: 'judge1', password: 'password123'),
      expect: () => [
        const AuthLoading(),
        const Authenticated(user: testJudgeUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => mockAuthRepository.login(username: 'admin', password: 'wrong'))
            .thenThrow(Exception('Invalid credentials'));
        return AuthCubit(authRepository: mockAuthRepository);
      },
      act: (cubit) => cubit.login(username: 'admin', password: 'wrong'),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Invalid credentials'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] on successful session restoration',
      build: () {
        when(() => mockAuthRepository.restoreSession())
            .thenAnswer((_) async => testJudgeUser);
        return AuthCubit(authRepository: mockAuthRepository);
      },
      act: (cubit) => cubit.restoreSession(),
      expect: () => [
        const AuthLoading(),
        const Authenticated(user: testJudgeUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Unauthenticated] on failed session restoration',
      build: () {
        when(() => mockAuthRepository.restoreSession())
            .thenAnswer((_) async => null);
        return AuthCubit(authRepository: mockAuthRepository);
      },
      act: (cubit) => cubit.restoreSession(),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Unauthenticated] on logout',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return AuthCubit(authRepository: mockAuthRepository);
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );

    test('emits Unauthenticated when onSessionExpired event is received', () async {
      final cubit = AuthCubit(authRepository: mockAuthRepository);
      expect(cubit.state, const AuthInitial());

      // Trigger session expired event from interceptor
      sessionExpiredController.add(null);
      await pumpEventQueue();

      expect(cubit.state, const Unauthenticated());
      cubit.close();
    });
  });
}
