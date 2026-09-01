import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/criteria_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import 'criteria_state.dart';

class CriteriaCubit extends Cubit<CriteriaState> {
  final AdminRepository _adminRepository;

  CriteriaCubit({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(const CriteriaInitial());

  int _calculateActiveTotalScore(List<CriteriaEntity> list) {
    return list
        .where((c) => c.active)
        .fold(0, (sum, item) => sum + item.maxScore);
  }

  Future<void> loadCriteria() async {
    emit(const CriteriaLoading());
    try {
      final criteria = await _adminRepository.getCriteria();
      final totalScore = _calculateActiveTotalScore(criteria);
      emit(CriteriaLoaded(criteria: criteria, totalMaxScore: totalScore));
    } catch (e) {
      emit(CriteriaError(message: _cleanErrorMessage(e)));
    }
  }

  Future<bool> createCriteria({
    required String name,
    String? description,
    required int maxScore,
    int displayOrder = 0,
  }) async {
    if (state is CriteriaLoaded && (state as CriteriaLoaded).isSubmitting) return false;

    final currentCriteria = state is CriteriaLoaded ? (state as CriteriaLoaded).criteria : <CriteriaEntity>[];
    final currentScore = state is CriteriaLoaded ? (state as CriteriaLoaded).totalMaxScore : 0;
    emit(CriteriaLoaded(criteria: currentCriteria, totalMaxScore: currentScore, isSubmitting: true));

    try {
      final created = await _adminRepository.createCriteria(
        name: name,
        description: description,
        maxScore: maxScore,
        displayOrder: displayOrder,
      );
      final updatedList = List<CriteriaEntity>.from(currentCriteria)..add(created);
      updatedList.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      final updatedScore = _calculateActiveTotalScore(updatedList);

      emit(CriteriaLoaded(
        criteria: updatedList,
        totalMaxScore: updatedScore,
        isSubmitting: false,
        actionSuccessMessage: 'Criterion "${created.name}" created successfully',
      ));
      return true;
    } catch (e) {
      emit(CriteriaLoaded(criteria: currentCriteria, totalMaxScore: currentScore, isSubmitting: false));
      emit(CriteriaError(message: _cleanErrorMessage(e)));
      return false;
    }
  }

  Future<bool> updateCriteria({
    required int id,
    required String name,
    String? description,
    required int maxScore,
    required int displayOrder,
  }) async {
    if (state is CriteriaLoaded && (state as CriteriaLoaded).isSubmitting) return false;

    final currentCriteria = state is CriteriaLoaded ? (state as CriteriaLoaded).criteria : <CriteriaEntity>[];
    final currentScore = state is CriteriaLoaded ? (state as CriteriaLoaded).totalMaxScore : 0;
    emit(CriteriaLoaded(criteria: currentCriteria, totalMaxScore: currentScore, isSubmitting: true));

    try {
      final updated = await _adminRepository.updateCriteria(
        id: id,
        name: name,
        description: description,
        maxScore: maxScore,
        displayOrder: displayOrder,
      );
      final updatedList = currentCriteria.map((c) => c.id == id ? updated : c).toList();
      updatedList.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      final updatedScore = _calculateActiveTotalScore(updatedList);

      emit(CriteriaLoaded(
        criteria: updatedList,
        totalMaxScore: updatedScore,
        isSubmitting: false,
        actionSuccessMessage: 'Criterion "${updated.name}" updated successfully',
      ));
      return true;
    } catch (e) {
      emit(CriteriaLoaded(criteria: currentCriteria, totalMaxScore: currentScore, isSubmitting: false));
      emit(CriteriaError(message: _cleanErrorMessage(e)));
      return false;
    }
  }

  Future<void> toggleCriteriaStatus(int id, bool active) async {
    if (state is! CriteriaLoaded) return;
    final currentCriteria = (state as CriteriaLoaded).criteria;

    try {
      final updated = await _adminRepository.updateCriteriaStatus(id: id, active: active);
      final updatedList = currentCriteria.map((c) => c.id == id ? updated : c).toList();
      final updatedScore = _calculateActiveTotalScore(updatedList);

      emit(CriteriaLoaded(
        criteria: updatedList,
        totalMaxScore: updatedScore,
        actionSuccessMessage: 'Criterion status updated to ${active ? "Active" : "Inactive"}',
      ));
    } catch (e) {
      emit(CriteriaError(message: _cleanErrorMessage(e)));
    }
  }

  Future<void> moveCriteriaUp(int index) async {
    if (state is! CriteriaLoaded || index <= 0) return;
    final criteria = List<CriteriaEntity>.from((state as CriteriaLoaded).criteria);
    final item = criteria.removeAt(index);
    criteria.insert(index - 1, item);

    final orderedIds = criteria.map((c) => c.id).toList();
    final currentScore = (state as CriteriaLoaded).totalMaxScore;
    emit(CriteriaLoaded(criteria: criteria, totalMaxScore: currentScore, isSubmitting: true));

    try {
      final reordered = await _adminRepository.reorderCriteria(orderedIds);
      final updatedScore = _calculateActiveTotalScore(reordered);
      emit(CriteriaLoaded(criteria: reordered, totalMaxScore: updatedScore, isSubmitting: false));
    } catch (e) {
      emit(CriteriaError(message: _cleanErrorMessage(e)));
      await loadCriteria();
    }
  }

  Future<void> moveCriteriaDown(int index) async {
    if (state is! CriteriaLoaded) return;
    final criteria = List<CriteriaEntity>.from((state as CriteriaLoaded).criteria);
    if (index >= criteria.length - 1) return;

    final item = criteria.removeAt(index);
    criteria.insert(index + 1, item);

    final orderedIds = criteria.map((c) => c.id).toList();
    final currentScore = (state as CriteriaLoaded).totalMaxScore;
    emit(CriteriaLoaded(criteria: criteria, totalMaxScore: currentScore, isSubmitting: true));

    try {
      final reordered = await _adminRepository.reorderCriteria(orderedIds);
      final updatedScore = _calculateActiveTotalScore(reordered);
      emit(CriteriaLoaded(criteria: reordered, totalMaxScore: updatedScore, isSubmitting: false));
    } catch (e) {
      emit(CriteriaError(message: _cleanErrorMessage(e)));
      await loadCriteria();
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
