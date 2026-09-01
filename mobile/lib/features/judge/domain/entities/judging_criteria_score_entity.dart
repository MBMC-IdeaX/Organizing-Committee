class JudgingCriteriaScoreEntity {
  final int criteriaId;
  final String criteriaName;
  final String? description;
  final int maxScore;
  final int displayOrder;
  final int? score;

  const JudgingCriteriaScoreEntity({
    required this.criteriaId,
    required this.criteriaName,
    this.description,
    required this.maxScore,
    required this.displayOrder,
    this.score,
  });

  bool get hasScore => score != null;

  JudgingCriteriaScoreEntity copyWith({int? score}) {
    return JudgingCriteriaScoreEntity(
      criteriaId: criteriaId,
      criteriaName: criteriaName,
      description: description,
      maxScore: maxScore,
      displayOrder: displayOrder,
      score: score ?? this.score,
    );
  }
}
