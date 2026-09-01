import 'package:equatable/equatable.dart';

class RankingResultEntity extends Equatable {
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

  const RankingResultEntity({
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

  @override
  List<Object?> get props => [
        rank,
        teamId,
        teamName,
        projectName,
        aggregateTotal,
        aggregateMaxScore,
        averageScore,
        averageMaxScore,
        percentage,
        completedJudges,
        totalJudges,
        complete,
      ];
}
