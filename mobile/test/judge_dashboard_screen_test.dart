import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ideax_judging/app/theme/app_theme.dart';
import 'package:ideax_judging/features/auth/domain/repositories/auth_repository.dart';
import 'package:ideax_judging/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ideax_judging/features/judge/domain/entities/judge_dashboard_entity.dart';
import 'package:ideax_judging/features/judge/domain/entities/judge_team_entity.dart';
import 'package:ideax_judging/features/judge/domain/repositories/judge_repository.dart';
import 'package:ideax_judging/features/judge/presentation/cubit/judge_dashboard_cubit.dart';
import 'package:ideax_judging/features/judge/presentation/screens/judge_dashboard_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockJudgeRepository extends Mock implements JudgeRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockJudgeRepository mockJudgeRepository;
  late MockAuthRepository mockAuthRepository;
  late StreamController<void> sessionExpiredController;

  setUp(() {
    mockJudgeRepository = MockJudgeRepository();
    mockAuthRepository = MockAuthRepository();
    sessionExpiredController = StreamController<void>.broadcast();
    when(() => mockAuthRepository.onSessionExpired)
        .thenAnswer((_) => sessionExpiredController.stream);
  });

  tearDown(() {
    sessionExpiredController.close();
  });

  const testDashboard = JudgeDashboardEntity(
    totalTeams: 2,
    completedTeams: 1,
    remainingTeams: 1,
    progressPercentage: 50.0,
    nextTeam: JudgeTeamEntity(
      id: 2,
      teamName: 'Team Beta',
      projectName: 'AgriBuddy',
      idea: 'AI agriculture',
      displayOrder: 2,
      status: 'NOT_STARTED',
      totalScore: 0,
      totalMaxScore: 50,
    ),
  );

  final testTeams = [
    const JudgeTeamEntity(
      id: 1,
      teamName: 'Team Alpha',
      projectName: 'Smart Waste',
      displayOrder: 1,
      status: 'COMPLETED',
      totalScore: 45,
      totalMaxScore: 50,
    ),
    const JudgeTeamEntity(
      id: 2,
      teamName: 'Team Beta',
      projectName: 'AgriBuddy',
      displayOrder: 2,
      status: 'NOT_STARTED',
      totalScore: 0,
      totalMaxScore: 50,
    ),
  ];

  testWidgets('JudgeDashboardScreen renders progress, next project card, and queue', (tester) async {
    when(() => mockJudgeRepository.getDashboard()).thenAnswer((_) async => testDashboard);
    when(() => mockJudgeRepository.getTeams()).thenAnswer((_) async => testTeams);

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
          home: const JudgeDashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('IdeaX Live Evaluation'), findsOneWidget);
    expect(find.text('JUDGE'), findsOneWidget);
    expect(find.text('1 / 2 Projects Completed'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Next Project'), findsOneWidget);
    expect(find.text('Start Next Project'), findsOneWidget);
    expect(find.text('Team Alpha'), findsOneWidget);
    expect(find.text('Team Beta'), findsOneWidget);

    authCubit.close();
    judgeDashboardCubit.close();
  });
}
