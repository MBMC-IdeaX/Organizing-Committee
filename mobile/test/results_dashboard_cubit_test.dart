import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideax_judging/core/errors/app_exception.dart';
import 'package:ideax_judging/features/admin/domain/entities/ranking_result_entity.dart';
import 'package:ideax_judging/features/admin/domain/entities/results_summary_entity.dart';
import 'package:ideax_judging/features/admin/domain/repositories/results_repository.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/results_dashboard_cubit.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/results_dashboard_state.dart';
import 'package:mocktail/mocktail.dart';

class MockResultsRepository extends Mock implements ResultsRepository {}

void main() {
  late MockResultsRepository mockResultsRepository;

  setUp(() {
    mockResultsRepository = MockResultsRepository();
  });

  const testSummary = ResultsSummaryEntity(
    totalTeams: 3,
    activeTeams: 3,
    totalJudges: 2,
    activeJudges: 2,
    totalCriteria: 2,
    activeCriteria: 2,
    totalPossibleScorePerJudge: 40,
    totalRequiredEvaluations: 6,
    completedEvaluations: 6,
    remainingEvaluations: 0,
    judgingCompletionPercentage: 100.0,
    judgingComplete: true,
    resultsAvailable: true,
  );

  const testSummaryIncomplete = ResultsSummaryEntity(
    totalTeams: 3,
    activeTeams: 3,
    totalJudges: 2,
    activeJudges: 2,
    totalCriteria: 2,
    activeCriteria: 2,
    totalPossibleScorePerJudge: 40,
    totalRequiredEvaluations: 6,
    completedEvaluations: 5,
    remainingEvaluations: 1,
    judgingCompletionPercentage: 83.3,
    judgingComplete: false,
    resultsAvailable: false,
  );

  final testRanking = [
    const RankingResultEntity(
      rank: 1,
      teamId: 1,
      teamName: 'Team A',
      projectName: 'Project A',
      aggregateTotal: 70,
      aggregateMaxScore: 80,
      averageScore: 35.0,
      averageMaxScore: 40,
      percentage: 87.5,
      completedJudges: 2,
      totalJudges: 2,
      complete: true,
    ),
  ];

  group('ResultsDashboardCubit Tests', () {
    blocTest<ResultsDashboardCubit, ResultsDashboardState>(
      'emits [ResultsDashboardLoading, ResultsDashboardLoaded] when results are available',
      build: () {
        when(() => mockResultsRepository.getResultsSummary()).thenAnswer((_) async => testSummary);
        when(() => mockResultsRepository.getRanking()).thenAnswer((_) async => testRanking);
        return ResultsDashboardCubit(resultsRepository: mockResultsRepository);
      },
      act: (cubit) => cubit.loadResultsDashboard(),
      expect: () => [
        const ResultsDashboardLoading(),
        ResultsDashboardLoaded(summary: testSummary, ranking: testRanking),
      ],
    );

    blocTest<ResultsDashboardCubit, ResultsDashboardState>(
      'emits [ResultsDashboardLoading, ResultsDashboardNotReady] when summary resultsAvailable is false',
      build: () {
        when(() => mockResultsRepository.getResultsSummary()).thenAnswer((_) async => testSummaryIncomplete);
        return ResultsDashboardCubit(resultsRepository: mockResultsRepository);
      },
      act: (cubit) => cubit.loadResultsDashboard(),
      expect: () => [
        const ResultsDashboardLoading(),
        const ResultsDashboardNotReady(summary: testSummaryIncomplete),
      ],
    );

    blocTest<ResultsDashboardCubit, ResultsDashboardState>(
      'emits [ResultsDashboardLoading, ResultsDashboardNotReady] when getRanking throws ConflictException RESULTS_NOT_READY',
      build: () {
        when(() => mockResultsRepository.getResultsSummary()).thenAnswer((_) async => testSummary);
        when(() => mockResultsRepository.getRanking()).thenThrow(
          const ConflictException(message: 'Not ready', errorCode: 'RESULTS_NOT_READY'),
        );
        return ResultsDashboardCubit(resultsRepository: mockResultsRepository);
      },
      act: (cubit) => cubit.loadResultsDashboard(),
      expect: () => [
        const ResultsDashboardLoading(),
        const ResultsDashboardNotReady(summary: testSummary),
      ],
    );

    blocTest<ResultsDashboardCubit, ResultsDashboardState>(
      'emits [ResultsDashboardLoading, ResultsDashboardError] on repository failure',
      build: () {
        when(() => mockResultsRepository.getResultsSummary()).thenThrow(Exception('Server error'));
        return ResultsDashboardCubit(resultsRepository: mockResultsRepository);
      },
      act: (cubit) => cubit.loadResultsDashboard(),
      expect: () => [
        const ResultsDashboardLoading(),
        const ResultsDashboardError(message: 'Server error'),
      ],
    );
  });
}
