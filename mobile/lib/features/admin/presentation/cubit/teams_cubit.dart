import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import 'teams_state.dart';

class TeamsCubit extends Cubit<TeamsState> {
  final AdminRepository _adminRepository;

  TeamsCubit({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(const TeamsInitial());

  Future<void> loadTeams() async {
    emit(const TeamsLoading());
    try {
      final teams = await _adminRepository.getTeams();
      emit(TeamsLoaded(teams: teams));
    } catch (e) {
      emit(TeamsError(message: _cleanErrorMessage(e)));
    }
  }

  Future<bool> createTeam({
    required String teamName,
    required String projectName,
    String? idea,
    int displayOrder = 0,
  }) async {
    if (state is TeamsLoaded && (state as TeamsLoaded).isSubmitting) return false;

    final currentTeams = state is TeamsLoaded ? (state as TeamsLoaded).teams : <TeamEntity>[];
    emit(TeamsLoaded(teams: currentTeams, isSubmitting: true));

    try {
      final created = await _adminRepository.createTeam(
        teamName: teamName,
        projectName: projectName,
        idea: idea,
        displayOrder: displayOrder,
      );
      final updatedList = List<TeamEntity>.from(currentTeams)..add(created);
      updatedList.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      emit(TeamsLoaded(
        teams: updatedList,
        isSubmitting: false,
        actionSuccessMessage: 'Team "${created.teamName}" created successfully',
      ));
      return true;
    } catch (e) {
      emit(TeamsLoaded(teams: currentTeams, isSubmitting: false));
      emit(TeamsError(message: _cleanErrorMessage(e)));
      return false;
    }
  }

  Future<bool> updateTeam({
    required int id,
    required String teamName,
    required String projectName,
    String? idea,
    required int displayOrder,
  }) async {
    if (state is TeamsLoaded && (state as TeamsLoaded).isSubmitting) return false;

    final currentTeams = state is TeamsLoaded ? (state as TeamsLoaded).teams : <TeamEntity>[];
    emit(TeamsLoaded(teams: currentTeams, isSubmitting: true));

    try {
      final updated = await _adminRepository.updateTeam(
        id: id,
        teamName: teamName,
        projectName: projectName,
        idea: idea,
        displayOrder: displayOrder,
      );
      final updatedList = currentTeams.map((t) => t.id == id ? updated : t).toList();
      updatedList.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      emit(TeamsLoaded(
        teams: updatedList,
        isSubmitting: false,
        actionSuccessMessage: 'Team "${updated.teamName}" updated successfully',
      ));
      return true;
    } catch (e) {
      emit(TeamsLoaded(teams: currentTeams, isSubmitting: false));
      emit(TeamsError(message: _cleanErrorMessage(e)));
      return false;
    }
  }

  Future<void> toggleTeamStatus(int id, bool active) async {
    if (state is! TeamsLoaded) return;
    final currentTeams = (state as TeamsLoaded).teams;

    try {
      final updated = await _adminRepository.updateTeamStatus(id: id, active: active);
      final updatedList = currentTeams.map((t) => t.id == id ? updated : t).toList();
      emit(TeamsLoaded(
        teams: updatedList,
        actionSuccessMessage: 'Team status updated to ${active ? "Active" : "Inactive"}',
      ));
    } catch (e) {
      emit(TeamsError(message: _cleanErrorMessage(e)));
    }
  }

  Future<void> moveTeamUp(int index) async {
    if (state is! TeamsLoaded || index <= 0) return;
    final teams = List<TeamEntity>.from((state as TeamsLoaded).teams);
    final team = teams.removeAt(index);
    teams.insert(index - 1, team);

    final orderedIds = teams.map((t) => t.id).toList();
    emit(TeamsLoaded(teams: teams, isSubmitting: true));

    try {
      final reordered = await _adminRepository.reorderTeams(orderedIds);
      emit(TeamsLoaded(teams: reordered, isSubmitting: false));
    } catch (e) {
      emit(TeamsError(message: _cleanErrorMessage(e)));
      await loadTeams();
    }
  }

  Future<void> moveTeamDown(int index) async {
    if (state is! TeamsLoaded) return;
    final teams = List<TeamEntity>.from((state as TeamsLoaded).teams);
    if (index >= teams.length - 1) return;

    final team = teams.removeAt(index);
    teams.insert(index + 1, team);

    final orderedIds = teams.map((t) => t.id).toList();
    emit(TeamsLoaded(teams: teams, isSubmitting: true));

    try {
      final reordered = await _adminRepository.reorderTeams(orderedIds);
      emit(TeamsLoaded(teams: reordered, isSubmitting: false));
    } catch (e) {
      emit(TeamsError(message: _cleanErrorMessage(e)));
      await loadTeams();
    }
  }

  Future<bool> deleteTeam(int id, {bool force = false}) async {
    if (state is TeamsLoaded && (state as TeamsLoaded).isSubmitting) return false;

    final currentTeams = state is TeamsLoaded ? (state as TeamsLoaded).teams : <TeamEntity>[];
    emit(TeamsLoaded(teams: currentTeams, isSubmitting: true));

    try {
      await _adminRepository.deleteTeam(id, force: force);
      final updatedList = currentTeams.where((t) => t.id != id).toList();
      emit(TeamsLoaded(
        teams: updatedList,
        isSubmitting: false,
        actionSuccessMessage: force
            ? 'Team and its evaluation records deleted successfully'
            : 'Team deleted successfully',
      ));
      return true;
    } catch (e) {
      emit(TeamsLoaded(teams: currentTeams, isSubmitting: false));
      rethrow;
    }
  }

  String _cleanErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring(11);
    }
    return str;
  }
}
