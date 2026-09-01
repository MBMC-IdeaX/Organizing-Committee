import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/judging_session_entity.dart';
import 'judging_criteria_score_model.dart';

class JudgingSessionModel {
  final int? judgingId;
  final int teamId;
  final String teamName;
  final String projectName;
  final String? idea;
  final int displayOrder;
  final String status;
  final String? comment;
  final DateTime? completedAt;
  final List<JudgingCriteriaScoreModel> criteriaScores;
  final int totalScore;
  final int totalMaxScore;

  JudgingSessionModel({
    this.judgingId,
    required this.teamId,
    required this.teamName,
    required this.projectName,
    this.idea,
    required this.displayOrder,
    required this.status,
    this.comment,
    this.completedAt,
    required this.criteriaScores,
    required this.totalScore,
    required this.totalMaxScore,
  });

  factory JudgingSessionModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return JudgingSessionModel(
      judgingId: (json['judgingId'] as num?)?.toInt(),
      teamId: (json['teamId'] as num?)?.toInt() ?? 0,
      teamName: json['teamName'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      idea: json['idea'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'NOT_STARTED',
      comment: json['comment'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      criteriaScores: asList(json['criteriaScores'])
          .map((item) => JudgingCriteriaScoreModel.fromJson(item))
          .toList(),
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      totalMaxScore: (json['totalMaxScore'] as num?)?.toInt() ?? 0,
    );
  }

  JudgingSessionEntity toEntity() {
    return JudgingSessionEntity(
      judgingId: judgingId,
      teamId: teamId,
      teamName: teamName,
      projectName: projectName,
      idea: idea,
      displayOrder: displayOrder,
      status: status,
      comment: comment,
      completedAt: completedAt,
      criteriaScores: criteriaScores.map((m) => m.toEntity()).toList(),
      totalScore: totalScore,
      totalMaxScore: totalMaxScore,
    );
  }
}
