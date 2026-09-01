import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ideax_judging/app/routes/app_routes.dart';
import 'package:ideax_judging/app/theme/app_theme.dart';
import 'package:ideax_judging/features/admin/domain/entities/admin_summary_entity.dart';
import 'package:ideax_judging/features/admin/domain/repositories/admin_repository.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/admin_dashboard_cubit.dart';
import 'package:ideax_judging/features/auth/domain/entities/user_entity.dart';
import 'package:ideax_judging/features/auth/domain/repositories/auth_repository.dart';
import 'package:ideax_judging/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ideax_judging/features/judge/domain/entities/judge_dashboard_entity.dart';
import 'package:ideax_judging/features/judge/domain/repositories/judge_repository.dart';
import 'package:ideax_judging/features/judge/presentation/cubit/judge_dashboard_cubit.dart';
import 'package:ideax_judging/shared/models/user_role.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAdminRepository extends Mock implements AdminRepository {}
class MockJudgeRepository extends Mock implements JudgeRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockAuthRepository mockAuthRepository;
  late MockAdminRepository mockAdminRepository;
  late MockJudgeRepository mockJudgeRepository;
  late StreamController<void> sessionExpiredController;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAdminRepository = MockAdminRepository();
    mockJudgeRepository = MockJudgeRepository();
    sessionExpiredController = StreamController<void>.broadcast();
    when(() => mockAuthRepository.onSessionExpired)
        .thenAnswer((_) => sessionExpiredController.stream);
    when(() => mockAdminRepository.getDashboardSummary()).thenAnswer(
      (_) async => const AdminSummaryEntity(
        totalTeams: 5,
        activeTeams: 4,
        totalCriteria: 3,
        activeCriteria: 3,
        totalMaxScore: 60,
        totalJudges: 2,
        activeJudges: 2,
        readyForJudging: true,
      ),
    );
    when(() => mockJudgeRepository.getDashboard()).thenAnswer(
      (_) async => const JudgeDashboardEntity(
        totalTeams: 0,
        completedTeams: 0,
        remainingTeams: 0,
        progressPercentage: 0.0,
      ),
    );
    when(() => mockJudgeRepository.getTeams()).thenAnswer((_) async => []);
  });

  tearDown(() {
    sessionExpiredController.close();
  });

  const adminUser = UserEntity(
    id: 1,
    username: 'admin_lead',
    role: UserRole.admin,
    active: true,
  );

  const judgeUser = UserEntity(
    id: 2,
    username: 'judge_lead',
    role: UserRole.judge,
    active: true,
  );

  group('UserRole & Route Protection Tests', () {
    test('UserRole strictly validates ADMIN and JUDGE', () {
      expect(UserRole.fromString('ADMIN'), UserRole.admin);
      expect(UserRole.fromString('JUDGE'), UserRole.judge);
      expect(() => UserRole.fromString('admin'), throwsA(isA<FormatException>()));
      expect(() => UserRole.fromString('judge'), throwsA(isA<FormatException>()));
      expect(() => UserRole.fromString(null), throwsA(isA<FormatException>()));
      expect(() => UserRole.fromString('UNKNOWN_ROLE'), throwsA(isA<FormatException>()));
    });

    testWidgets('ADMIN navigation opens Admin Console', (tester) async {
      when(() => mockAuthRepository.restoreSession()).thenAnswer((_) async => adminUser);

      final authCubit = AuthCubit(authRepository: mockAuthRepository);
      final adminDashboardCubit = AdminDashboardCubit(adminRepository: mockAdminRepository);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<AdminDashboardCubit>.value(value: adminDashboardCubit),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            initialRoute: '/',
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();

      expect(find.text('IdeaX Admin Console'), findsOneWidget);
      expect(find.text('ADMIN ROLE'), findsOneWidget);

      authCubit.close();
      adminDashboardCubit.close();
    });

    testWidgets('JUDGE navigation opens Judge Dashboard', (tester) async {
      when(() => mockAuthRepository.restoreSession()).thenAnswer((_) async => judgeUser);

      final authCubit = AuthCubit(authRepository: mockAuthRepository);
      final judgeDashboardCubit = JudgeDashboardCubit(judgeRepository: mockJudgeRepository);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<JudgeDashboardCubit>.value(value: judgeDashboardCubit),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            initialRoute: '/',
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();

      expect(find.text('No Active Projects'), findsOneWidget);

      authCubit.close();
      judgeDashboardCubit.close();
    });
  });
}
