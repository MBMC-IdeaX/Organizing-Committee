import 'package:equatable/equatable.dart';
import '../../domain/entities/judge_dashboard_entity.dart';
import '../../domain/entities/judge_team_entity.dart';

abstract class JudgeDashboardState extends Equatable {
  const JudgeDashboardState();

  @override
  List<Object?> get props => [];
}

class JudgeDashboardInitial extends JudgeDashboardState {
  const JudgeDashboardInitial();
}

class JudgeDashboardLoading extends JudgeDashboardState {
  const JudgeDashboardLoading();
}

class JudgeDashboardLoaded extends JudgeDashboardState {
  final JudgeDashboardEntity dashboard;
  final List<JudgeTeamEntity> teams;

  const JudgeDashboardLoaded({
    required this.dashboard,
    required this.teams,
  });

  @override
  List<Object?> get props => [dashboard, teams];
}

class JudgeDashboardError extends JudgeDashboardState {
  final String message;

  const JudgeDashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
