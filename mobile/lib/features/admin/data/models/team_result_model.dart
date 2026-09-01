import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/team_result_entity.dart';

class TeamResultModel {
  final int teamId;
  final String teamName;
  final String projectName;
  final String? idea;
  final int rank;
  final int aggregateTotal;
  final int aggregateMaxScore;
  final double averageScore;
  final int averageMaxScore;
  final double percentage;
  final bool complete;
  final List<JudgeScoreBreakdownModel> judgeBreakdowns;
  final List<CriterionResultBreakdownModel> criterionBreakdowns;

  TeamResultModel({
    required this.teamId,
    required this.teamName,
    required this.projectName,
    this.idea,
    required this.rank,
    required this.aggregateTotal,
    required this.aggregateMaxScore,
    required this.averageScore,
    required this.averageMaxScore,
    required this.percentage,
    required this.complete,
    required this.judgeBreakdowns,
    required this.criterionBreakdowns,
  });

  factory TeamResultModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    final judgeList = json['judgeBreakdowns'] as List? ?? [];
    final critList = json['criterionBreakdowns'] as List? ?? [];

    return TeamResultModel(
      teamId: (json['teamId'] as num?)?.toInt() ?? 0,
      teamName: json['teamName'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      idea: json['idea'] as String?,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      aggregateTotal: (json['aggregateTotal'] as num?)?.toInt() ?? 0,
      aggregateMaxScore: (json['aggregateMaxScore'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      averageMaxScore: (json['averageMaxScore'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      complete: json['complete'] as bool? ?? false,
      judgeBreakdowns: judgeList.map((e) => JudgeScoreBreakdownModel.fromJson(e)).toList(),
      criterionBreakdowns: critList.map((e) => CriterionResultBreakdownModel.fromJson(e)).toList(),
    );
  }

  TeamResultEntity toEntity() {
    return TeamResultEntity(
      teamId: teamId,
      teamName: teamName,
      projectName: projectName,
      idea: idea,
      rank: rank,
      aggregateTotal: aggregateTotal,
      aggregateMaxScore: aggregateMaxScore,
      averageScore: averageScore,
      averageMaxScore: averageMaxScore,
      percentage: percentage,
      complete: complete,
      judgeBreakdowns: judgeBreakdowns.map((e) => e.toEntity()).toList(),
      criterionBreakdowns: criterionBreakdowns.map((e) => e.toEntity()).toList(),
    );
  }
}

class JudgeScoreBreakdownModel {
  final String judgeUsername;
  final int totalScore;
  final int maxScore;
  final Map<String, int> criterionScores;
  final String? comment;

  JudgeScoreBreakdownModel({
    required this.judgeUsername,
    required this.totalScore,
    required this.maxScore,
    required this.criterionScores,
    this.comment,
  });

  factory JudgeScoreBreakdownModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    final critMapRaw = asMap(json['criterionScores']);
    final Map<String, int> criterionScores = {};
    critMapRaw.forEach((k, v) {
      criterionScores[k] = (v as num?)?.toInt() ?? 0;
    });

    return JudgeScoreBreakdownModel(
      judgeUsername: json['judgeUsername'] as String? ?? '',
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 0,
      criterionScores: criterionScores,
      comment: json['comment'] as String?,
    );
  }

  JudgeScoreBreakdownEntity toEntity() {
    return JudgeScoreBreakdownEntity(
      judgeUsername: judgeUsername,
      totalScore: totalScore,
      maxScore: maxScore,
      criterionScores: criterionScores,
      comment: comment,
    );
  }
}

class CriterionResultBreakdownModel {
  final int criteriaId;
  final String criteriaName;
  final double averageScore;
  final int maxScore;

  CriterionResultBreakdownModel({
    required this.criteriaId,
    required this.criteriaName,
    required this.averageScore,
    required this.maxScore,
  });

  factory CriterionResultBreakdownModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return CriterionResultBreakdownModel(
      criteriaId: (json['criteriaId'] as num?)?.toInt() ?? 0,
      criteriaName: json['criteriaName'] as String? ?? '',
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 0,
    );
  }

  CriterionResultBreakdownEntity toEntity() {
    return CriterionResultBreakdownEntity(
      criteriaId: criteriaId,
      criteriaName: criteriaName,
      averageScore: averageScore,
      maxScore: maxScore,
    );
  }
}
