import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/judging_criteria_score_entity.dart';

class JudgingCriteriaScoreModel {
  final int criteriaId;
  final String criteriaName;
  final String? description;
  final int maxScore;
  final int displayOrder;
  final int? score;

  JudgingCriteriaScoreModel({
    required this.criteriaId,
    required this.criteriaName,
    this.description,
    required this.maxScore,
    required this.displayOrder,
    this.score,
  });

  factory JudgingCriteriaScoreModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return JudgingCriteriaScoreModel(
      criteriaId: (json['criteriaId'] as num?)?.toInt() ?? 0,
      criteriaName: json['criteriaName'] as String? ?? '',
      description: json['description'] as String?,
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 0,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt(),
    );
  }

  JudgingCriteriaScoreEntity toEntity() {
    return JudgingCriteriaScoreEntity(
      criteriaId: criteriaId,
      criteriaName: criteriaName,
      description: description,
      maxScore: maxScore,
      displayOrder: displayOrder,
      score: score,
    );
  }
}
