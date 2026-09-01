import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/judge_repository.dart';
import 'judging_state.dart';

class JudgingCubit extends Cubit<JudgingState> {
  final JudgeRepository _judgeRepository;

  JudgingCubit({required JudgeRepository judgeRepository})
      : _judgeRepository = judgeRepository,
        super(const JudgingInitial());

  Future<void> loadSession(int teamId) async {
    emit(const JudgingLoading());
    try {
      final session = await _judgeRepository.getJudgingSession(teamId);
      final Map<int, int> initialScores = {};
      for (final item in session.criteriaScores) {
        if (item.score != null) {
          initialScores[item.criteriaId] = item.score!;
        }
      }
      emit(JudgingSessionLoaded(
        session: session,
        localScores: initialScores,
        localComment: session.comment,
        hasUnsavedChanges: false,
      ));
    } catch (e) {
      emit(JudgingError(message: _cleanErrorMessage(e)));
    }
  }

  Future<void> startEvaluation(int teamId) async {
    emit(const JudgingLoading());
    try {
      final session = await _judgeRepository.startJudging(teamId);
      final Map<int, int> initialScores = {};
      for (final item in session.criteriaScores) {
        if (item.score != null) {
          initialScores[item.criteriaId] = item.score!;
        }
      }
      emit(JudgingSessionLoaded(
        session: session,
        localScores: initialScores,
        localComment: session.comment,
        hasUnsavedChanges: false,
      ));
    } catch (e) {
      emit(JudgingError(message: _cleanErrorMessage(e)));
    }
  }

  void incrementScore(int criteriaId, int maxScore) {
    if (state is! JudgingSessionLoaded) return;
    final current = state as JudgingSessionLoaded;
    if (current.session.isCompleted) return;

    final currentVal = current.localScores[criteriaId] ?? 0;
    if (currentVal < maxScore) {
      final updated = Map<int, int>.from(current.localScores);
      updated[criteriaId] = currentVal + 1;
      emit(current.copyWith(
        localScores: updated,
        hasUnsavedChanges: true,
        clearActionMessages: true,
      ));
    }
  }

  void decrementScore(int criteriaId) {
    if (state is! JudgingSessionLoaded) return;
    final current = state as JudgingSessionLoaded;
    if (current.session.isCompleted) return;

    final currentVal = current.localScores[criteriaId] ?? 0;
    if (currentVal > 0) {
      final updated = Map<int, int>.from(current.localScores);
      updated[criteriaId] = currentVal - 1;
      emit(current.copyWith(
        localScores: updated,
        hasUnsavedChanges: true,
        clearActionMessages: true,
      ));
    }
  }

  void setScore(int criteriaId, int score, int maxScore) {
    if (state is! JudgingSessionLoaded) return;
    final current = state as JudgingSessionLoaded;
    if (current.session.isCompleted) return;

    final clamped = score.clamp(0, maxScore);
    final updated = Map<int, int>.from(current.localScores);
    updated[criteriaId] = clamped;
    emit(current.copyWith(
      localScores: updated,
      hasUnsavedChanges: true,
      clearActionMessages: true,
    ));
  }

  void setComment(String comment) {
    if (state is! JudgingSessionLoaded) return;
    final current = state as JudgingSessionLoaded;
    if (current.session.isCompleted) return;

    emit(current.copyWith(
      localComment: comment,
      hasUnsavedChanges: true,
      clearActionMessages: true,
    ));
  }

  Future<bool> saveDraftScores() async {
    if (state is! JudgingSessionLoaded) return false;
    final current = state as JudgingSessionLoaded;
    if (current.isSaving || current.isCompleting || current.session.isCompleted) return false;

    emit(current.copyWith(isSaving: true, clearActionMessages: true));

    try {
      final scorePayload = current.localScores.entries
          .map((e) => {'criteriaId': e.key, 'score': e.value})
          .toList();

      var updatedSession = await _judgeRepository.saveScores(
        current.session.teamId,
        scorePayload,
      );

      if (current.localComment != null && current.localComment != current.session.comment) {
        updatedSession = await _judgeRepository.saveComment(
          current.session.teamId,
          current.localComment!,
        );
      }

      emit(current.copyWith(
        session: updatedSession,
        isSaving: false,
        hasUnsavedChanges: false,
        actionSuccessMessage: 'Scores saved successfully',
      ));
      return true;
    } catch (e) {
      emit(current.copyWith(
        isSaving: false,
        actionErrorMessage: _cleanErrorMessage(e),
      ));
      return false;
    }
  }

  Future<bool> completeEvaluation() async {
    if (state is! JudgingSessionLoaded) return false;
    final current = state as JudgingSessionLoaded;
    if (current.isSaving || current.isCompleting || current.session.isCompleted) return false;

    if (!current.allActiveCriteriaScored) {
      emit(current.copyWith(
        actionErrorMessage: 'Please score all active criteria before marking complete.',
      ));
      return false;
    }

    emit(current.copyWith(isCompleting: true, clearActionMessages: true));

    try {
      final scorePayload = current.localScores.entries
          .map((e) => {'criteriaId': e.key, 'score': e.value})
          .toList();

      final completedSession = await _judgeRepository.completeJudging(
        teamId: current.session.teamId,
        comment: current.localComment,
        scores: scorePayload,
      );

      emit(JudgingCompletedSuccess(session: completedSession));
      return true;
    } catch (e) {
      emit(current.copyWith(
        isCompleting: false,
        actionErrorMessage: _cleanErrorMessage(e),
      ));
      return false;
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
