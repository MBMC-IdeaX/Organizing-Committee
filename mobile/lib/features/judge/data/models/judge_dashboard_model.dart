import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/judge_dashboard_entity.dart';
import 'judge_team_model.dart';

class JudgeDashboardModel {
  final int totalTeams;
  final int completedTeams;
  final int remainingTeams;
  final double progressPercentage;
  final JudgeTeamModel? nextTeam;

  JudgeDashboardModel({
    required this.totalTeams,
    required this.completedTeams,
    required this.remainingTeams,
    required this.progressPercentage,
    this.nextTeam,
  });

  factory JudgeDashboardModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return JudgeDashboardModel(
      totalTeams: (json['totalTeams'] as num?)?.toInt() ?? 0,
      completedTeams: (json['completedTeams'] as num?)?.toInt() ?? 0,
      remainingTeams: (json['remainingTeams'] as num?)?.toInt() ?? 0,
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      nextTeam: json['nextTeam'] != null
          ? JudgeTeamModel.fromJson(json['nextTeam'])
          : null,
    );
  }

  JudgeDashboardEntity toEntity() {
    return JudgeDashboardEntity(
      totalTeams: totalTeams,
      completedTeams: completedTeams,
      remainingTeams: remainingTeams,
      progressPercentage: progressPercentage,
      nextTeam: nextTeam?.toEntity(),
    );
  }
}
