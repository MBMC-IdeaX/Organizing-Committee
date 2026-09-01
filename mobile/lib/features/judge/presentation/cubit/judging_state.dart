import 'package:equatable/equatable.dart';
import '../../domain/entities/judging_session_entity.dart';

abstract class JudgingState extends Equatable {
  const JudgingState();

  @override
  List<Object?> get props => [];
}

class JudgingInitial extends JudgingState {
  const JudgingInitial();
}

class JudgingLoading extends JudgingState {
  const JudgingLoading();
}

class JudgingSessionLoaded extends JudgingState {
  final JudgingSessionEntity session;
  final Map<int, int> localScores; // criteriaId -> score
  final String? localComment;
  final bool isSaving;
  final bool isCompleting;
  final bool hasUnsavedChanges;
  final String? actionSuccessMessage;
  final String? actionErrorMessage;

  const JudgingSessionLoaded({
    required this.session,
    required this.localScores,
    this.localComment,
    this.isSaving = false,
    this.isCompleting = false,
    this.hasUnsavedChanges = false,
    this.actionSuccessMessage,
    this.actionErrorMessage,
  });

  int get currentTotalScore {
    return localScores.values.fold(0, (sum, val) => sum + val);
  }

  bool get allActiveCriteriaScored {
    if (session.criteriaScores.isEmpty) return false;
    for (final criterion in session.criteriaScores) {
      if (!localScores.containsKey(criterion.criteriaId)) {
        return false;
      }
    }
    return true;
  }

  JudgingSessionLoaded copyWith({
    JudgingSessionEntity? session,
    Map<int, int>? localScores,
    String? localComment,
    bool? isSaving,
    bool? isCompleting,
    bool? hasUnsavedChanges,
    String? actionSuccessMessage,
    String? actionErrorMessage,
    bool clearActionMessages = false,
  }) {
    return JudgingSessionLoaded(
      session: session ?? this.session,
      localScores: localScores ?? this.localScores,
      localComment: localComment ?? this.localComment,
      isSaving: isSaving ?? this.isSaving,
      isCompleting: isCompleting ?? this.isCompleting,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      actionSuccessMessage: clearActionMessages ? null : (actionSuccessMessage ?? this.actionSuccessMessage),
      actionErrorMessage: clearActionMessages ? null : (actionErrorMessage ?? this.actionErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        session,
        localScores,
        localComment,
        isSaving,
        isCompleting,
        hasUnsavedChanges,
        actionSuccessMessage,
        actionErrorMessage,
      ];
}

class JudgingCompletedSuccess extends JudgingState {
  final JudgingSessionEntity session;

  const JudgingCompletedSuccess({required this.session});

  @override
  List<Object?> get props => [session];
}

class JudgingError extends JudgingState {
  final String message;

  const JudgingError({required this.message});

  @override
  List<Object?> get props => [message];
}
