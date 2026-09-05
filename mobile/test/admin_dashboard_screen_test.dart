import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ideax_judging/app/theme/app_theme.dart';
import 'package:ideax_judging/features/admin/domain/entities/admin_summary_entity.dart';
import 'package:ideax_judging/features/admin/domain/repositories/admin_repository.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/admin_dashboard_cubit.dart';
import 'package:ideax_judging/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:ideax_judging/features/auth/domain/repositories/auth_repository.dart';
import 'package:ideax_judging/app/routes/route_names.dart';
import 'package:ideax_judging/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockAdminRepository mockAdminRepository;
  late MockAuthRepository mockAuthRepository;
  late AuthCubit authCubit;
  late AdminDashboardCubit adminDashboardCubit;

  setUp(() {
    mockAdminRepository = MockAdminRepository();
    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.onSessionExpired).thenAnswer((_) => const Stream.empty());

    authCubit = AuthCubit(authRepository: mockAuthRepository);
    adminDashboardCubit = AdminDashboardCubit(adminRepository: mockAdminRepository);
  });

  tearDown(() {
    authCubit.close();
    adminDashboardCubit.close();
  });

  const testSummary = AdminSummaryEntity(
    totalTeams: 12,
    activeTeams: 10,
    totalCriteria: 5,
    activeCriteria: 5,
    totalMaxScore: 80,
    totalJudges: 6,
    activeJudges: 4,
    readyForJudging: true,
  );

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<AdminDashboardCubit>.value(value: adminDashboardCubit),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AdminDashboardScreen(),
        routes: {
          RouteNames.login: (context) => const Scaffold(body: Text('Login Screen')),
        },
      ),
    );
  }

  group('AdminDashboardScreen Widget Tests', () {
    testWidgets('renders header, metric cards, readiness checklist, and navigation modules', (tester) async {
      when(() => mockAdminRepository.getDashboardSummary()).thenAnswer((_) async => testSummary);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('IdeaX Admin Console'), findsOneWidget);
      expect(find.text('Event Management & Judging Control'), findsOneWidget);
      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.text('Judging Setup: READY'), findsOneWidget);
      expect(find.text('Manage Teams'), findsOneWidget);
      expect(find.text('Manage Criteria'), findsOneWidget);
      expect(find.text('Manage Judges'), findsOneWidget);
    });

    testWidgets('clicking logout button and confirming calls AuthCubit logout', (tester) async {
      when(() => mockAdminRepository.getDashboardSummary()).thenAnswer((_) async => testSummary);
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Click logout icon button
      final logoutIconFinder = find.byIcon(Icons.logout_rounded);
      expect(logoutIconFinder, findsOneWidget);
      await tester.tap(logoutIconFinder);
      await tester.pumpAndSettle();

      // Verify AlertDialog is visible
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Sign Out?'), findsOneWidget);

      // Click 'Sign Out' button inside AlertDialog
      final signOutButtonFinder = find.widgetWithText(ElevatedButton, 'Sign Out');
      expect(signOutButtonFinder, findsOneWidget);
      await tester.tap(signOutButtonFinder);
      await tester.pumpAndSettle();

      // Verify logout is called on repository/cubit
      verify(() => mockAuthRepository.logout()).called(1);
    });

    testWidgets('Danger Zone Reset Data button opens ResetSystemDialog', (tester) async {
      when(() => mockAdminRepository.getDashboardSummary()).thenAnswer((_) async => testSummary);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Danger Zone'), findsOneWidget);
      expect(find.text('Reset Competition Data'), findsOneWidget);

      final resetBtn = find.widgetWithText(ElevatedButton, 'Reset Data');
      expect(resetBtn, findsOneWidget);

      await tester.ensureVisible(resetBtn);
      await tester.pumpAndSettle();

      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      expect(find.text('Clear all evaluation scores & ballots'), findsOneWidget);
      expect(find.text('Authorize Reset'), findsOneWidget);
    });
  });
}
