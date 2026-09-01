import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideax_judging/features/judge/domain/entities/judge_dashboard_entity.dart';
import 'package:ideax_judging/features/judge/domain/entities/judge_team_entity.dart';
import 'package:ideax_judging/features/judge/domain/repositories/judge_repository.dart';
import 'package:ideax_judging/features/judge/presentation/cubit/judge_dashboard_cubit.dart';
import 'package:ideax_judging/features/judge/presentation/cubit/judge_dashboard_state.dart';
import 'package:mocktail/mocktail.dart';

class MockJudgeRepository extends Mock implements JudgeRepository {}

void main() {
  late MockJudgeRepository mockJudgeRepository;

  setUp(() {
    mockJudgeRepository = MockJudgeRepository();
  });

  const testDashboard = JudgeDashboardEntity(
    totalTeams: 3,
    completedTeams: 1,
    remainingTeams: 2,
    progressPercentage: 33.3,
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

  group('JudgeDashboardCubit Tests', () {
    blocTest<JudgeDashboardCubit, JudgeDashboardState>(
      'emits [JudgeDashboardLoading, JudgeDashboardLoaded] on successful load',
      build: () {
        when(() => mockJudgeRepository.getDashboard()).thenAnswer((_) async => testDashboard);
        when(() => mockJudgeRepository.getTeams()).thenAnswer((_) async => testTeams);
        return JudgeDashboardCubit(judgeRepository: mockJudgeRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const JudgeDashboardLoading(),
        JudgeDashboardLoaded(dashboard: testDashboard, teams: testTeams),
      ],
    );

    blocTest<JudgeDashboardCubit, JudgeDashboardState>(
      'emits [JudgeDashboardLoading, JudgeDashboardError] on failure',
      build: () {
        when(() => mockJudgeRepository.getDashboard()).thenThrow(Exception('Server error occurred'));
        return JudgeDashboardCubit(judgeRepository: mockJudgeRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const JudgeDashboardLoading(),
        const JudgeDashboardError(message: 'Server error occurred'),
      ],
    );
  });
}
