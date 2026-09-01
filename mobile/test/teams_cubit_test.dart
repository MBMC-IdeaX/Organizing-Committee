import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideax_judging/features/admin/domain/entities/team_entity.dart';
import 'package:ideax_judging/features/admin/domain/repositories/admin_repository.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/teams_cubit.dart';
import 'package:ideax_judging/features/admin/presentation/cubit/teams_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  late MockAdminRepository mockAdminRepository;

  setUp(() {
    mockAdminRepository = MockAdminRepository();
  });

  const testTeam1 = TeamEntity(
    id: 1,
    teamName: 'Team Nova',
    projectName: 'Smart Ag',
    idea: 'IoT monitoring',
    displayOrder: 1,
    active: true,
  );

  const testTeam2 = TeamEntity(
    id: 2,
    teamName: 'Team Vision',
    projectName: 'Civic Connect',
    idea: 'Citizen app',
    displayOrder: 2,
    active: true,
  );

  group('TeamsCubit Tests', () {
    test('initial state is TeamsInitial', () {
      final cubit = TeamsCubit(adminRepository: mockAdminRepository);
      expect(cubit.state, const TeamsInitial());
      cubit.close();
    });

    blocTest<TeamsCubit, TeamsState>(
      'emits [TeamsLoading, TeamsLoaded] on successful loadTeams',
      build: () {
        when(() => mockAdminRepository.getTeams())
            .thenAnswer((_) async => [testTeam1, testTeam2]);
        return TeamsCubit(adminRepository: mockAdminRepository);
      },
      act: (cubit) => cubit.loadTeams(),
      expect: () => [
        const TeamsLoading(),
        const TeamsLoaded(teams: [testTeam1, testTeam2]),
      ],
    );

    blocTest<TeamsCubit, TeamsState>(
      'emits updated teams list on successful createTeam',
      build: () {
        when(() => mockAdminRepository.createTeam(
              teamName: 'Team Nova',
              projectName: 'Smart Ag',
              idea: 'IoT monitoring',
              displayOrder: 1,
            )).thenAnswer((_) async => testTeam1);
        return TeamsCubit(adminRepository: mockAdminRepository);
      },
      act: (cubit) => cubit.createTeam(
        teamName: 'Team Nova',
        projectName: 'Smart Ag',
        idea: 'IoT monitoring',
        displayOrder: 1,
      ),
      expect: () => [
        const TeamsLoaded(teams: [], isSubmitting: true),
        const TeamsLoaded(
          teams: [testTeam1],
          isSubmitting: false,
          actionSuccessMessage: 'Team "Team Nova" created successfully',
        ),
      ],
    );

    blocTest<TeamsCubit, TeamsState>(
      'emits updated status on toggleTeamStatus',
      build: () {
        when(() => mockAdminRepository.updateTeamStatus(id: 1, active: false))
            .thenAnswer((_) async => const TeamEntity(
                  id: 1,
                  teamName: 'Team Nova',
                  projectName: 'Smart Ag',
                  idea: 'IoT monitoring',
                  displayOrder: 1,
                  active: false,
                ));
        final cubit = TeamsCubit(adminRepository: mockAdminRepository);
        cubit.emit(const TeamsLoaded(teams: [testTeam1]));
        return cubit;
      },
      act: (cubit) => cubit.toggleTeamStatus(1, false),
      expect: () => [
        const TeamsLoaded(
          teams: [
            TeamEntity(
              id: 1,
              teamName: 'Team Nova',
              projectName: 'Smart Ag',
              idea: 'IoT monitoring',
              displayOrder: 1,
              active: false,
            ),
          ],
          actionSuccessMessage: 'Team status updated to Inactive',
        ),
      ],
    );

    blocTest<TeamsCubit, TeamsState>(
      'emits updated teams list on successful deleteTeam',
      build: () {
        when(() => mockAdminRepository.deleteTeam(1)).thenAnswer((_) async {});
        final cubit = TeamsCubit(adminRepository: mockAdminRepository);
        cubit.emit(const TeamsLoaded(teams: [testTeam1, testTeam2]));
        return cubit;
      },
      act: (cubit) => cubit.deleteTeam(1),
      expect: () => [
        const TeamsLoaded(teams: [testTeam1, testTeam2], isSubmitting: true),
        const TeamsLoaded(
          teams: [testTeam2],
          isSubmitting: false,
          actionSuccessMessage: 'Team deleted successfully',
        ),
      ],
    );
  });
}
