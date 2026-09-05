import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ideax_judging/app/theme/app_theme.dart';
import 'package:ideax_judging/features/admin/domain/entities/ranking_result_entity.dart';
import 'package:ideax_judging/features/admin/domain/entities/results_summary_entity.dart';
import 'package:ideax_judging/features/admin/domain/repositories/results_repository.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/results_dashboard_cubit.dart';
import 'package:ideax_judging/features/admin/presentation/screens/results_dashboard_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockResultsRepository extends Mock implements ResultsRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockResultsRepository mockResultsRepository;

  setUp(() {
    mockResultsRepository = MockResultsRepository();
  });

  const testSummaryComplete = ResultsSummaryEntity(
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
    completedEvaluations: 4,
    remainingEvaluations: 2,
    judgingCompletionPercentage: 66.7,
    judgingComplete: false,
    resultsAvailable: false,
  );

  final testRanking = [
    const RankingResultEntity(
      rank: 1,
      teamId: 1,
      teamName: 'Team Alpha',
      projectName: 'Project Alpha',
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

  testWidgets('ResultsDashboardScreen renders incomplete status details when in progress', (tester) async {
    when(() => mockResultsRepository.getResultsSummary()).thenAnswer((_) async => testSummaryIncomplete);

    final resultsCubit = ResultsDashboardCubit(resultsRepository: mockResultsRepository);

    await tester.pumpWidget(
      BlocProvider<ResultsDashboardCubit>.value(
        value: resultsCubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ResultsDashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Results are not ready yet'), findsOneWidget);
    expect(find.text('Judging Progress'), findsOneWidget);
    expect(find.text('4 / 6 Evaluations'), findsOneWidget);
    expect(find.text('66.7%'), findsOneWidget);
    expect(find.text('Missing Ballots'), findsOneWidget);
    expect(find.text('2'), findsNWidgets(2));

    resultsCubit.close();
  });

  testWidgets('ResultsDashboardScreen renders complete podium and standings table when complete', (tester) async {
    when(() => mockResultsRepository.getResultsSummary()).thenAnswer((_) async => testSummaryComplete);
    when(() => mockResultsRepository.getRanking()).thenAnswer((_) async => testRanking);

    final resultsCubit = ResultsDashboardCubit(resultsRepository: mockResultsRepository);

    await tester.pumpWidget(
      BlocProvider<ResultsDashboardCubit>.value(
        value: resultsCubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ResultsDashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('JUDGING COMPLETE'), findsOneWidget);
    expect(find.text('Podium Standings'), findsOneWidget);
    expect(find.text('Champion'), findsOneWidget);
    expect(find.text('Team Alpha'), findsWidgets);
    expect(find.text('Project Alpha'), findsWidgets);
    expect(find.text('87.5%'), findsWidgets);
    expect(find.text('70/80'), findsOneWidget);

    resultsCubit.close();
  });
}
