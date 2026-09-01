import 'judge_team_entity.dart';

class JudgeDashboardEntity {
  final int totalTeams;
  final int completedTeams;
  final int remainingTeams;
  final double progressPercentage;
  final JudgeTeamEntity? nextTeam;

  const JudgeDashboardEntity({
    required this.totalTeams,
    required this.completedTeams,
    required this.remainingTeams,
    required this.progressPercentage,
    this.nextTeam,
  });

  bool get allCompleted => totalTeams > 0 && remainingTeams == 0;
  bool get hasTeams => totalTeams > 0;
}
