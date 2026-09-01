import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/judge_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import 'judges_state.dart';

class JudgesCubit extends Cubit<JudgesState> {
  final AdminRepository _adminRepository;

  JudgesCubit({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(const JudgesInitial());

  Future<void> loadJudges() async {
    emit(const JudgesLoading());
    try {
      final judges = await _adminRepository.getJudges();
      emit(JudgesLoaded(judges: judges));
    } catch (e) {
      emit(JudgesError(message: _cleanErrorMessage(e)));
    }
  }

  Future<bool> createJudge({
    required String username,
    required String password,
  }) async {
    if (state is JudgesLoaded && (state as JudgesLoaded).isSubmitting) return false;

    final currentJudges = state is JudgesLoaded ? (state as JudgesLoaded).judges : <JudgeEntity>[];
    emit(JudgesLoaded(judges: currentJudges, isSubmitting: true));

    try {
      final created = await _adminRepository.createJudge(
        username: username,
        password: password,
      );
      final updatedList = List<JudgeEntity>.from(currentJudges)..insert(0, created);

      emit(JudgesLoaded(
        judges: updatedList,
        isSubmitting: false,
        actionSuccessMessage: 'Judge "${created.username}" created successfully',
      ));
      return true;
    } catch (e) {
      emit(JudgesLoaded(judges: currentJudges, isSubmitting: false));
      emit(JudgesError(message: _cleanErrorMessage(e)));
      return false;
    }
  }

  Future<bool> updateJudge({
    required int id,
    required String username,
    String? password,
  }) async {
    if (state is JudgesLoaded && (state as JudgesLoaded).isSubmitting) return false;

    final currentJudges = state is JudgesLoaded ? (state as JudgesLoaded).judges : <JudgeEntity>[];
    emit(JudgesLoaded(judges: currentJudges, isSubmitting: true));

    try {
      final updated = await _adminRepository.updateJudge(
        id: id,
        username: username,
        password: password,
      );
      final updatedList = currentJudges.map((j) => j.id == id ? updated : j).toList();

      emit(JudgesLoaded(
        judges: updatedList,
        isSubmitting: false,
        actionSuccessMessage: 'Judge "${updated.username}" updated successfully',
      ));
      return true;
    } catch (e) {
      emit(JudgesLoaded(judges: currentJudges, isSubmitting: false));
      emit(JudgesError(message: _cleanErrorMessage(e)));
      return false;
    }
  }

  Future<void> toggleJudgeStatus(int id, bool active) async {
    if (state is! JudgesLoaded) return;
    final currentJudges = (state as JudgesLoaded).judges;

    try {
      final updated = await _adminRepository.updateJudgeStatus(id: id, active: active);
      final updatedList = currentJudges.map((j) => j.id == id ? updated : j).toList();

      emit(JudgesLoaded(
        judges: updatedList,
        actionSuccessMessage: 'Judge status updated to ${active ? "Active" : "Inactive"}',
      ));
    } catch (e) {
      emit(JudgesError(message: _cleanErrorMessage(e)));
    }
  }

  Future<bool> deleteJudge(int id, {bool force = false}) async {
    if (state is JudgesLoaded && (state as JudgesLoaded).isSubmitting) return false;

    final currentJudges = state is JudgesLoaded ? (state as JudgesLoaded).judges : <JudgeEntity>[];
    emit(JudgesLoaded(judges: currentJudges, isSubmitting: true));

    try {
      await _adminRepository.deleteJudge(id, force: force);
      final updatedList = currentJudges.where((j) => j.id != id).toList();
      emit(JudgesLoaded(
        judges: updatedList,
        isSubmitting: false,
        actionSuccessMessage: force
            ? 'Judge account and its evaluation records deleted successfully'
            : 'Judge account deleted successfully',
      ));
      return true;
    } catch (e) {
      emit(JudgesLoaded(judges: currentJudges, isSubmitting: false));
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
