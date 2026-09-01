import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideax_judging/features/admin/domain/entities/judge_entity.dart';
import 'package:ideax_judging/features/admin/domain/repositories/admin_repository.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/judges_cubit.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/judges_state.dart';
import 'package:ideax_judging/shared/models/user_role.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  late MockAdminRepository mockAdminRepository;

  setUp(() {
    mockAdminRepository = MockAdminRepository();
  });

  const judge1 = JudgeEntity(
    id: 1,
    username: 'judge_sarah',
    role: UserRole.judge,
    active: true,
  );

  group('JudgesCubit Tests', () {
    test('initial state is JudgesInitial', () {
      final cubit = JudgesCubit(adminRepository: mockAdminRepository);
      expect(cubit.state, const JudgesInitial());
      cubit.close();
    });

    blocTest<JudgesCubit, JudgesState>(
      'emits [JudgesLoading, JudgesLoaded] on successful loadJudges',
      build: () {
        when(() => mockAdminRepository.getJudges()).thenAnswer((_) async => [judge1]);
        return JudgesCubit(adminRepository: mockAdminRepository);
      },
      act: (cubit) => cubit.loadJudges(),
      expect: () => [
        const JudgesLoading(),
        const JudgesLoaded(judges: [judge1]),
      ],
    );

    blocTest<JudgesCubit, JudgesState>(
      'emits updated judge list on createJudge',
      build: () {
        when(() => mockAdminRepository.createJudge(
              username: 'judge_sarah',
              password: 'Password123!',
            )).thenAnswer((_) async => judge1);
        return JudgesCubit(adminRepository: mockAdminRepository);
      },
      act: (cubit) => cubit.createJudge(
        username: 'judge_sarah',
        password: 'Password123!',
      ),
      expect: () => [
        const JudgesLoaded(judges: [], isSubmitting: true),
        const JudgesLoaded(
          judges: [judge1],
          isSubmitting: false,
          actionSuccessMessage: 'Judge "judge_sarah" created successfully',
        ),
      ],
    );

    blocTest<JudgesCubit, JudgesState>(
      'emits updated judge list on deleteJudge',
      build: () {
        when(() => mockAdminRepository.deleteJudge(1)).thenAnswer((_) async {});
        final cubit = JudgesCubit(adminRepository: mockAdminRepository);
        cubit.emit(const JudgesLoaded(judges: [judge1]));
        return cubit;
      },
      act: (cubit) => cubit.deleteJudge(1),
      expect: () => [
        const JudgesLoaded(judges: [judge1], isSubmitting: true),
        const JudgesLoaded(
          judges: [],
          isSubmitting: false,
          actionSuccessMessage: 'Judge account deleted successfully',
        ),
      ],
    );
  });
}
