import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideax_judging/features/judge/domain/entities/judging_criteria_score_entity.dart';
import 'package:ideax_judging/features/judge/domain/entities/judging_session_entity.dart';
import 'package:ideax_judging/features/judge/domain/repositories/judge_repository.dart';
import 'package:ideax_judging/features/judge/presentation/cubit/judging_cubit.dart';
import 'package:ideax_judging/features/judge/presentation/cubit/judging_state.dart';
import 'package:mocktail/mocktail.dart';

class MockJudgeRepository extends Mock implements JudgeRepository {}

void main() {
  late MockJudgeRepository mockJudgeRepository;

  setUp(() {
    mockJudgeRepository = MockJudgeRepository();
  });

  const testCriteria = [
    JudgingCriteriaScoreEntity(
      criteriaId: 1,
      criteriaName: 'Innovation',
      description: 'Novelty',
      maxScore: 20,
      displayOrder: 1,
      score: 18,
    ),
    JudgingCriteriaScoreEntity(
      criteriaId: 2,
      criteriaName: 'Technical',
      description: 'Code quality',
      maxScore: 30,
      displayOrder: 2,
      score: null,
    ),
  ];

  const testSession = JudgingSessionEntity(
    judgingId: 10,
    teamId: 1,
    teamName: 'Team Alpha',
    projectName: 'Smart Waste',
    idea: 'IoT trash monitoring',
    displayOrder: 1,
    status: 'IN_PROGRESS',
    comment: 'Great pitch',
    criteriaScores: testCriteria,
    totalScore: 18,
    totalMaxScore: 50,
  );

  group('JudgingCubit Tests', () {
    blocTest<JudgingCubit, JudgingState>(
      'loads judging session and populates local scores',
      build: () {
        when(() => mockJudgeRepository.getJudgingSession(1)).thenAnswer((_) async => testSession);
        return JudgingCubit(judgeRepository: mockJudgeRepository);
      },
      act: (cubit) => cubit.loadSession(1),
      expect: () => [
        const JudgingLoading(),
        const JudgingSessionLoaded(
          session: testSession,
          localScores: {1: 18},
          localComment: 'Great pitch',
          hasUnsavedChanges: false,
        ),
      ],
    );

    test('setScore directly sets score, clamps between 0 and maxScore, and updates running total', () {
      when(() => mockJudgeRepository.getJudgingSession(1)).thenAnswer((_) async => testSession);
      final cubit = JudgingCubit(judgeRepository: mockJudgeRepository);

      cubit.emit(const JudgingSessionLoaded(
        session: testSession,
        localScores: {1: 10},
        localComment: null,
      ));

      // Direct typing valid score: 17
      cubit.setScore(1, 17, 20);
      var loaded = cubit.state as JudgingSessionLoaded;
      expect(loaded.localScores[1], 17);
      expect(loaded.currentTotalScore, 17);
      expect(loaded.hasUnsavedChanges, true);

      // Direct typing 0: valid lower boundary
      cubit.setScore(1, 0, 20);
      loaded = cubit.state as JudgingSessionLoaded;
      expect(loaded.localScores[1], 0);
      expect(loaded.currentTotalScore, 0);

      // Direct typing score > maxScore: clamps to 20
      cubit.setScore(1, 25, 20);
      loaded = cubit.state as JudgingSessionLoaded;
      expect(loaded.localScores[1], 20);
      expect(loaded.currentTotalScore, 20);

      // Direct typing negative score: clamps to 0
      cubit.setScore(1, -5, 20);
      loaded = cubit.state as JudgingSessionLoaded;
      expect(loaded.localScores[1], 0);

      cubit.close();
    });

    test('incrementScore and decrementScore respect bounds (0 to maxScore)', () {
      when(() => mockJudgeRepository.getJudgingSession(1)).thenAnswer((_) async => testSession);
      final cubit = JudgingCubit(judgeRepository: mockJudgeRepository);

      cubit.emit(const JudgingSessionLoaded(
        session: testSession,
        localScores: {1: 19},
        localComment: null,
      ));

      // Increment 19 -> 20 (max 20)
      cubit.incrementScore(1, 20);
      expect((cubit.state as JudgingSessionLoaded).localScores[1], 20);

      // Increment 20 -> should stay 20
      cubit.incrementScore(1, 20);
      expect((cubit.state as JudgingSessionLoaded).localScores[1], 20);

      // Decrement 20 -> 19
      cubit.decrementScore(1);
      expect((cubit.state as JudgingSessionLoaded).localScores[1], 19);

      cubit.close();
    });

    blocTest<JudgingCubit, JudgingState>(
      'saveDraftScores persists scores to repository and clears hasUnsavedChanges',
      build: () {
        when(() => mockJudgeRepository.saveScores(1, any())).thenAnswer((_) async => testSession);
        return JudgingCubit(judgeRepository: mockJudgeRepository);
      },
      seed: () => const JudgingSessionLoaded(
        session: testSession,
        localScores: {1: 18, 2: 25},
        localComment: 'Great pitch',
        hasUnsavedChanges: true,
      ),
      act: (cubit) => cubit.saveDraftScores(),
      expect: () => [
        const JudgingSessionLoaded(
          session: testSession,
          localScores: {1: 18, 2: 25},
          localComment: 'Great pitch',
          isSaving: true,
          hasUnsavedChanges: true,
        ),
        const JudgingSessionLoaded(
          session: testSession,
          localScores: {1: 18, 2: 25},
          localComment: 'Great pitch',
          isSaving: false,
          hasUnsavedChanges: false,
          actionSuccessMessage: 'Scores saved successfully',
        ),
      ],
    );

    blocTest<JudgingCubit, JudgingState>(
      'completeEvaluation requires all criteria scored',
      build: () => JudgingCubit(judgeRepository: mockJudgeRepository),
      seed: () => const JudgingSessionLoaded(
        session: testSession,
        localScores: {1: 18}, // missing criterion 2
        localComment: null,
      ),
      act: (cubit) => cubit.completeEvaluation(),
      expect: () => [
        const JudgingSessionLoaded(
          session: testSession,
          localScores: {1: 18},
          localComment: null,
          actionErrorMessage: 'Please score all active criteria before marking complete.',
        ),
      ],
    );
  });
}
