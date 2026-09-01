import 'judging_criteria_score_entity.dart';

class JudgingSessionEntity {
  final int? judgingId;
  final int teamId;
  final String teamName;
  final String projectName;
  final String? idea;
  final int displayOrder;
  final String status; // NOT_STARTED, IN_PROGRESS, COMPLETED
  final String? comment;
  final DateTime? completedAt;
  final List<JudgingCriteriaScoreEntity> criteriaScores;
  final int totalScore;
  final int totalMaxScore;

  const JudgingSessionEntity({
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

  bool get isCompleted => status == 'COMPLETED';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isNotStarted => status == 'NOT_STARTED';

  bool get allCriteriaScored {
    if (criteriaScores.isEmpty) return false;
    return criteriaScores.every((c) => c.score != null);
  }
}
