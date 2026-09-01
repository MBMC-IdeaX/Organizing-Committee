import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideax_judging/features/admin/domain/entities/team_result_entity.dart';
import 'package:ideax_judging/features/admin/domain/repositories/results_repository.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/team_result_cubit.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/team_result_state.dart';
import 'package:mocktail/mocktail.dart';

class MockResultsRepository extends Mock implements ResultsRepository {}

void main() {
  late MockResultsRepository mockResultsRepository;

  setUp(() {
    mockResultsRepository = MockResultsRepository();
  });

  const testTeamResult = TeamResultEntity(
    teamId: 1,
    teamName: 'Team A',
    projectName: 'Project A',
    idea: 'Idea A',
    rank: 1,
    aggregateTotal: 70,
    aggregateMaxScore: 80,
    averageScore: 35.0,
    averageMaxScore: 40,
    percentage: 87.5,
    complete: true,
    judgeBreakdowns: [
      JudgeScoreBreakdownEntity(
        judgeUsername: 'judge1',
        totalScore: 35,
        maxScore: 40,
        criterionScores: {'Innovation': 18, 'Technical': 17},
        comment: 'Nice',
      ),
    ],
    criterionBreakdowns: [
      CriterionResultBreakdownEntity(
        criteriaId: 1,
        criteriaName: 'Innovation',
        averageScore: 18.0,
        maxScore: 20,
      ),
    ],
  );

  group('TeamResultCubit Tests', () {
    blocTest<TeamResultCubit, TeamResultState>(
      'emits [TeamResultLoading, TeamResultLoaded] on successful load',
      build: () {
        when(() => mockResultsRepository.getTeamResult(1)).thenAnswer((_) async => testTeamResult);
        return TeamResultCubit(resultsRepository: mockResultsRepository);
      },
      act: (cubit) => cubit.loadTeamResult(1),
      expect: () => [
        const TeamResultLoading(),
        const TeamResultLoaded(teamResult: testTeamResult),
      ],
    );

    blocTest<TeamResultCubit, TeamResultState>(
      'emits [TeamResultLoading, TeamResultError] on repository failure',
      build: () {
        when(() => mockResultsRepository.getTeamResult(1)).thenThrow(Exception('Resource not found'));
        return TeamResultCubit(resultsRepository: mockResultsRepository);
      },
      act: (cubit) => cubit.loadTeamResult(1),
      expect: () => [
        const TeamResultLoading(),
        const TeamResultError(message: 'Resource not found'),
      ],
    );
  });
}
