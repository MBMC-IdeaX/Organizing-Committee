import 'package:equatable/equatable.dart';
import '../../domain/entities/team_result_entity.dart';

abstract class TeamResultState extends Equatable {
  const TeamResultState();

  @override
  List<Object?> get props => [];
}

class TeamResultInitial extends TeamResultState {
  const TeamResultInitial();
}

class TeamResultLoading extends TeamResultState {
  const TeamResultLoading();
}

class TeamResultLoaded extends TeamResultState {
  final TeamResultEntity teamResult;

  const TeamResultLoaded({
    required this.teamResult,
  });

  @override
  List<Object?> get props => [teamResult];
}

class TeamResultError extends TeamResultState {
  final String message;

  const TeamResultError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
