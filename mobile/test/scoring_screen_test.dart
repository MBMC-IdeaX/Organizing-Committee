import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ideax_judging/app/theme/app_theme.dart';
import 'package:ideax_judging/features/judge/domain/entities/judging_criteria_score_entity.dart';
import 'package:ideax_judging/features/judge/domain/entities/judging_session_entity.dart';
import 'package:ideax_judging/features/judge/domain/repositories/judge_repository.dart';
import 'package:ideax_judging/features/judge/presentation/cubit/judging_cubit.dart';
import 'package:ideax_judging/features/judge/presentation/screens/scoring_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockJudgeRepository extends Mock implements JudgeRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockJudgeRepository mockJudgeRepository;

  setUp(() {
    mockJudgeRepository = MockJudgeRepository();
  });

  const testCriteria = [
    JudgingCriteriaScoreEntity(
      criteriaId: 1,
      criteriaName: 'Innovation',
      description: 'Novelty & Creativity',
      maxScore: 20,
      displayOrder: 1,
      score: 15,
    ),
  ];

  const testSession = JudgingSessionEntity(
    judgingId: 10,
    teamId: 1,
    teamName: 'Team Alpha',
    projectName: 'Smart Waste Management',
    idea: 'IoT sensor network for municipal bins',
    displayOrder: 1,
    status: 'IN_PROGRESS',
    comment: 'Impressive live demo',
    criteriaScores: testCriteria,
    totalScore: 15,
    totalMaxScore: 20,
  );

  const completedSession = JudgingSessionEntity(
    judgingId: 10,
    teamId: 1,
    teamName: 'Team Alpha',
    projectName: 'Smart Waste Management',
    idea: 'IoT sensor network for municipal bins',
    displayOrder: 1,
    status: 'COMPLETED',
    comment: 'Final review notes',
    criteriaScores: testCriteria,
    totalScore: 15,
    totalMaxScore: 20,
  );

  testWidgets('ScoringScreen renders criteria, running score banner, steppers, and actions', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockJudgeRepository.getJudgingSession(1)).thenAnswer((_) async => testSession);

    final judgingCubit = JudgingCubit(judgeRepository: mockJudgeRepository);

    await tester.pumpWidget(
      BlocProvider<JudgingCubit>.value(
        value: judgingCubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ScoringScreen(teamId: 1),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Current Total Score'), findsOneWidget);
    expect(find.text('15 / 20'), findsOneWidget);
    expect(find.text('Team Alpha'), findsOneWidget);
    expect(find.text('01  Innovation'), findsOneWidget);
    expect(find.text('Save Draft'), findsOneWidget);
    expect(find.text('Mark Complete'), findsOneWidget);

    // Verify + stepper increments score
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('16 / 20'), findsOneWidget);

    judgingCubit.close();
  });

  testWidgets('Direct score typing updates running total immediately and clamps to maxScore', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockJudgeRepository.getJudgingSession(1)).thenAnswer((_) async => testSession);

    final judgingCubit = JudgingCubit(judgeRepository: mockJudgeRepository);

    await tester.pumpWidget(
      BlocProvider<JudgingCubit>.value(
        value: judgingCubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ScoringScreen(teamId: 1),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find the direct score text field
    final scoreTextField = find.byType(TextField).first;
    expect(scoreTextField, findsOneWidget);

    // Enter direct score '18'
    await tester.enterText(scoreTextField, '18');
    await tester.pumpAndSettle();

    expect(find.text('18 / 20'), findsOneWidget);

    // Enter score '0'
    await tester.enterText(scoreTextField, '0');
    await tester.pumpAndSettle();

    expect(find.text('0 / 20'), findsOneWidget);

    // Enter score exceeding maxScore (e.g. '25') -> should clamp to 20
    await tester.enterText(scoreTextField, '25');
    await tester.pumpAndSettle();

    expect(find.text('20 / 20'), findsOneWidget);

    judgingCubit.close();
  });

  testWidgets('Completed session is read-only and hides +/- buttons', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockJudgeRepository.getJudgingSession(1)).thenAnswer((_) async => completedSession);

    final judgingCubit = JudgingCubit(judgeRepository: mockJudgeRepository);

    await tester.pumpWidget(
      BlocProvider<JudgingCubit>.value(
        value: judgingCubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ScoringScreen(teamId: 1),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Final Total Score'), findsOneWidget);
    expect(find.text('FINALIZED'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsNothing);
    expect(find.byIcon(Icons.remove_rounded), findsNothing);
    expect(find.text('Save Draft'), findsNothing);

    judgingCubit.close();
  });
}
