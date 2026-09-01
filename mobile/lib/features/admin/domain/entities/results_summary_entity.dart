import 'package:equatable/equatable.dart';

class ResultsSummaryEntity extends Equatable {
  final int totalTeams;
  final int activeTeams;
  final int totalJudges;
  final int activeJudges;
  final int totalCriteria;
  final int activeCriteria;
  final int totalPossibleScorePerJudge;
  final int totalRequiredEvaluations;
  final int completedEvaluations;
  final int remainingEvaluations;
  final double judgingCompletionPercentage;
  final bool judgingComplete;
  final bool resultsAvailable;

  const ResultsSummaryEntity({
    required this.totalTeams,
    required this.activeTeams,
    required this.totalJudges,
    required this.activeJudges,
    required this.totalCriteria,
    required this.activeCriteria,
    required this.totalPossibleScorePerJudge,
    required this.totalRequiredEvaluations,
    required this.completedEvaluations,
    required this.remainingEvaluations,
    required this.judgingCompletionPercentage,
    required this.judgingComplete,
    required this.resultsAvailable,
  });

  @override
  List<Object?> get props => [
        totalTeams,
        activeTeams,
        totalJudges,
        activeJudges,
        totalCriteria,
        activeCriteria,
        totalPossibleScorePerJudge,
        totalRequiredEvaluations,
        completedEvaluations,
        remainingEvaluations,
        judgingCompletionPercentage,
        judgingComplete,
        resultsAvailable,
      ];
}
