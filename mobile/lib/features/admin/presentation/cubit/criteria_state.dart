import 'package:equatable/equatable.dart';
import '../../domain/entities/criteria_entity.dart';

abstract class CriteriaState extends Equatable {
  const CriteriaState();

  @override
  List<Object?> get props => [];
}

class CriteriaInitial extends CriteriaState {
  const CriteriaInitial();
}

class CriteriaLoading extends CriteriaState {
  const CriteriaLoading();
}

class CriteriaLoaded extends CriteriaState {
  final List<CriteriaEntity> criteria;
  final int totalMaxScore;
  final bool isSubmitting;
  final String? actionSuccessMessage;

  const CriteriaLoaded({
    required this.criteria,
    required this.totalMaxScore,
    this.isSubmitting = false,
    this.actionSuccessMessage,
  });

  CriteriaLoaded copyWith({
    List<CriteriaEntity>? criteria,
    int? totalMaxScore,
    bool? isSubmitting,
    String? actionSuccessMessage,
  }) {
    return CriteriaLoaded(
      criteria: criteria ?? this.criteria,
      totalMaxScore: totalMaxScore ?? this.totalMaxScore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [criteria, totalMaxScore, isSubmitting, actionSuccessMessage];
}

class CriteriaError extends CriteriaState {
  final String message;

  const CriteriaError({required this.message});

  @override
  List<Object?> get props => [message];
}
