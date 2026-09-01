import 'package:equatable/equatable.dart';

class TeamResultEntity extends Equatable {
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
  final List<JudgeScoreBreakdownEntity> judgeBreakdowns;
  final List<CriterionResultBreakdownEntity> criterionBreakdowns;

  const TeamResultEntity({
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

  @override
  List<Object?> get props => [
        teamId,
        teamName,
        projectName,
        idea,
        rank,
        aggregateTotal,
        aggregateMaxScore,
        averageScore,
        averageMaxScore,
        percentage,
        complete,
        judgeBreakdowns,
        criterionBreakdowns,
      ];
}

class JudgeScoreBreakdownEntity extends Equatable {
  final String judgeUsername;
  final int totalScore;
  final int maxScore;
  final Map<String, int> criterionScores;
  final String? comment;

  const JudgeScoreBreakdownEntity({
    required this.judgeUsername,
    required this.totalScore,
    required this.maxScore,
    required this.criterionScores,
    this.comment,
  });

  @override
  List<Object?> get props => [
        judgeUsername,
        totalScore,
        maxScore,
        criterionScores,
        comment,
      ];
}

class CriterionResultBreakdownEntity extends Equatable {
  final int criteriaId;
  final String criteriaName;
  final double averageScore;
  final int maxScore;

  const CriterionResultBreakdownEntity({
    required this.criteriaId,
    required this.criteriaName,
    required this.averageScore,
    required this.maxScore,
  });

  @override
  List<Object?> get props => [
        criteriaId,
        criteriaName,
        averageScore,
        maxScore,
      ];
}
