import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/ranking_result_entity.dart';

class RankingResultModel {
  final int rank;
  final int teamId;
  final String teamName;
  final String projectName;
  final int aggregateTotal;
  final int aggregateMaxScore;
  final double averageScore;
  final int averageMaxScore;
  final double percentage;
  final int completedJudges;
  final int totalJudges;
  final bool complete;

  RankingResultModel({
    required this.rank,
    required this.teamId,
    required this.teamName,
    required this.projectName,
    required this.aggregateTotal,
    required this.aggregateMaxScore,
    required this.averageScore,
    required this.averageMaxScore,
    required this.percentage,
    required this.completedJudges,
    required this.totalJudges,
    required this.complete,
  });

  factory RankingResultModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return RankingResultModel(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      teamId: (json['teamId'] as num?)?.toInt() ?? 0,
      teamName: json['teamName'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      aggregateTotal: (json['aggregateTotal'] as num?)?.toInt() ?? 0,
      aggregateMaxScore: (json['aggregateMaxScore'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      averageMaxScore: (json['averageMaxScore'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      completedJudges: (json['completedJudges'] as num?)?.toInt() ?? 0,
      totalJudges: (json['totalJudges'] as num?)?.toInt() ?? 0,
      complete: json['complete'] as bool? ?? false,
    );
  }

  RankingResultEntity toEntity() {
    return RankingResultEntity(
      rank: rank,
      teamId: teamId,
      teamName: teamName,
      projectName: projectName,
      aggregateTotal: aggregateTotal,
      aggregateMaxScore: aggregateMaxScore,
      averageScore: averageScore,
      averageMaxScore: averageMaxScore,
      percentage: percentage,
      completedJudges: completedJudges,
      totalJudges: totalJudges,
      complete: complete,
    );
  }
}
