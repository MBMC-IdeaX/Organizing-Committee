import 'package:equatable/equatable.dart';
import '../../domain/entities/team_entity.dart';

abstract class TeamsState extends Equatable {
  const TeamsState();

  @override
  List<Object?> get props => [];
}

class TeamsInitial extends TeamsState {
  const TeamsInitial();
}

class TeamsLoading extends TeamsState {
  const TeamsLoading();
}

class TeamsLoaded extends TeamsState {
  final List<TeamEntity> teams;
  final bool isSubmitting;
  final String? actionSuccessMessage;

  const TeamsLoaded({
    required this.teams,
    this.isSubmitting = false,
    this.actionSuccessMessage,
  });

  TeamsLoaded copyWith({
    List<TeamEntity>? teams,
    bool? isSubmitting,
    String? actionSuccessMessage,
  }) {
    return TeamsLoaded(
      teams: teams ?? this.teams,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [teams, isSubmitting, actionSuccessMessage];
}

class TeamsError extends TeamsState {
  final String message;

  const TeamsError({required this.message});

  @override
  List<Object?> get props => [message];
}
