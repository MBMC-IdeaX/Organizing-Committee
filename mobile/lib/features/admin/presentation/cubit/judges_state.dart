import 'package:equatable/equatable.dart';
import '../../domain/entities/judge_entity.dart';

abstract class JudgesState extends Equatable {
  const JudgesState();

  @override
  List<Object?> get props => [];
}

class JudgesInitial extends JudgesState {
  const JudgesInitial();
}

class JudgesLoading extends JudgesState {
  const JudgesLoading();
}

class JudgesLoaded extends JudgesState {
  final List<JudgeEntity> judges;
  final bool isSubmitting;
  final String? actionSuccessMessage;

  const JudgesLoaded({
    required this.judges,
    this.isSubmitting = false,
    this.actionSuccessMessage,
  });

  JudgesLoaded copyWith({
    List<JudgeEntity>? judges,
    bool? isSubmitting,
    String? actionSuccessMessage,
  }) {
    return JudgesLoaded(
      judges: judges ?? this.judges,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [judges, isSubmitting, actionSuccessMessage];
}

class JudgesError extends JudgesState {
  final String message;

  const JudgesError({required this.message});

  @override
  List<Object?> get props => [message];
}
