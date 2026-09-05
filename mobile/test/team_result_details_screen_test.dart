import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ideax_judging/app/theme/app_theme.dart';
import 'package:ideax_judging/features/admin/domain/entities/team_result_entity.dart';
import 'package:ideax_judging/features/admin/domain/repositories/results_repository.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/team_result_cubit.dart';
import 'package:ideax_judging/features/admin/presentation/screens/team_result_details_screen.dart';
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

  const testTeamResult = TeamResultEntity(
    teamId: 1,
    teamName: 'Team Alpha',
    projectName: 'Smart Waste Bin',
    idea: 'A smart system to automatically sort trash',
    rank: 2,
    aggregateTotal: 68,
    aggregateMaxScore: 80,
    averageScore: 34.0,
    averageMaxScore: 40,
    percentage: 85.00,
    complete: true,
    judgeBreakdowns: [
      JudgeScoreBreakdownEntity(
        judgeUsername: 'judge_one',
        totalScore: 34,
        maxScore: 40,
        criterionScores: {'Innovation': 18, 'Technical': 16},
        comment: 'Brilliant execution',
      ),
    ],
    criterionBreakdowns: [
      CriterionResultBreakdownEntity(
        criteriaId: 1,
        criteriaName: 'Innovation',
        averageScore: 18.0,
        maxScore: 20,
      ),
      CriterionResultBreakdownEntity(
        criteriaId: 2,
        criteriaName: 'Technical',
        averageScore: 16.0,
        maxScore: 20,
      ),
    ],
  );

  testWidgets('TeamResultDetailsScreen renders metrics, progress bars, and scorecards', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockResultsRepository.getTeamResult(1)).thenAnswer((_) async => testTeamResult);

    final teamCubit = TeamResultCubit(resultsRepository: mockResultsRepository);

    await tester.pumpWidget(
      BlocProvider<TeamResultCubit>.value(
        value: teamCubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const TeamResultDetailsScreen(teamId: 1),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Team Alpha'), findsOneWidget);
    expect(find.text('Project: Smart Waste Bin'), findsOneWidget);
    expect(find.text('A smart system to automatically sort trash'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.text('85.00%'), findsOneWidget);
    expect(find.text('68 / 80'), findsOneWidget);
    expect(find.text('Innovation'), findsWidgets);
    expect(find.text('18.00 / 20'), findsOneWidget);
    expect(find.text('Technical'), findsWidgets);
    expect(find.text('16.00 / 20'), findsOneWidget);
    expect(find.text('judge_one'), findsOneWidget);
    expect(find.text('Brilliant execution'), findsOneWidget);

    teamCubit.close();
  });
}
