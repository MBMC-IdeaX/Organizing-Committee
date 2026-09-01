import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideax_judging/features/admin/domain/entities/criteria_entity.dart';
import 'package:ideax_judging/features/admin/domain/repositories/admin_repository.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/criteria_cubit.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/criteria_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  late MockAdminRepository mockAdminRepository;

  setUp(() {
    mockAdminRepository = MockAdminRepository();
  });

  const crit1 = CriteriaEntity(
    id: 1,
    name: 'Innovation',
    description: 'Novelty',
    maxScore: 20,
    displayOrder: 1,
    active: true,
  );

  const crit2 = CriteriaEntity(
    id: 2,
    name: 'Technical',
    description: 'Architecture',
    maxScore: 20,
    displayOrder: 2,
    active: true,
  );

  group('CriteriaCubit Tests', () {
    test('initial state is CriteriaInitial', () {
      final cubit = CriteriaCubit(adminRepository: mockAdminRepository);
      expect(cubit.state, const CriteriaInitial());
      cubit.close();
    });

    blocTest<CriteriaCubit, CriteriaState>(
      'emits [CriteriaLoading, CriteriaLoaded] with active total max score calculation',
      build: () {
        when(() => mockAdminRepository.getCriteria())
            .thenAnswer((_) async => [crit1, crit2]);
        return CriteriaCubit(adminRepository: mockAdminRepository);
      },
      act: (cubit) => cubit.loadCriteria(),
      expect: () => [
        const CriteriaLoading(),
        const CriteriaLoaded(criteria: [crit1, crit2], totalMaxScore: 40),
      ],
    );

    blocTest<CriteriaCubit, CriteriaState>(
      'emits updated criteria list on successful createCriteria',
      build: () {
        when(() => mockAdminRepository.createCriteria(
              name: 'Innovation',
              description: 'Novelty',
              maxScore: 20,
              displayOrder: 1,
            )).thenAnswer((_) async => crit1);
        return CriteriaCubit(adminRepository: mockAdminRepository);
      },
      act: (cubit) => cubit.createCriteria(
        name: 'Innovation',
        description: 'Novelty',
        maxScore: 20,
        displayOrder: 1,
      ),
      expect: () => [
        const CriteriaLoaded(criteria: [], totalMaxScore: 0, isSubmitting: true),
        const CriteriaLoaded(
          criteria: [crit1],
          totalMaxScore: 20,
          isSubmitting: false,
          actionSuccessMessage: 'Criterion "Innovation" created successfully',
        ),
      ],
    );
  });
}
