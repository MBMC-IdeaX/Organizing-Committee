import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/judge_team_entity.dart';

class JudgeTeamModel {
  final int id;
  final String teamName;
  final String projectName;
  final String? idea;
  final int displayOrder;
  final String status;
  final int totalScore;
  final int totalMaxScore;

  JudgeTeamModel({
    required this.id,
    required this.teamName,
    required this.projectName,
    this.idea,
    required this.displayOrder,
    required this.status,
    required this.totalScore,
    required this.totalMaxScore,
  });

  factory JudgeTeamModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return JudgeTeamModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      teamName: json['teamName'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      idea: json['idea'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'NOT_STARTED',
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      totalMaxScore: (json['totalMaxScore'] as num?)?.toInt() ?? 0,
    );
  }

  JudgeTeamEntity toEntity() {
    return JudgeTeamEntity(
      id: id,
      teamName: teamName,
      projectName: projectName,
      idea: idea,
      displayOrder: displayOrder,
      status: status,
      totalScore: totalScore,
      totalMaxScore: totalMaxScore,
    );
  }
}
