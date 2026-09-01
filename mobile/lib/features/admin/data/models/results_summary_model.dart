import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/results_summary_entity.dart';

class ResultsSummaryModel {
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

  ResultsSummaryModel({
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

  factory ResultsSummaryModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return ResultsSummaryModel(
      totalTeams: (json['totalTeams'] as num?)?.toInt() ?? 0,
      activeTeams: (json['activeTeams'] as num?)?.toInt() ?? 0,
      totalJudges: (json['totalJudges'] as num?)?.toInt() ?? 0,
      activeJudges: (json['activeJudges'] as num?)?.toInt() ?? 0,
      totalCriteria: (json['totalCriteria'] as num?)?.toInt() ?? 0,
      activeCriteria: (json['activeCriteria'] as num?)?.toInt() ?? 0,
      totalPossibleScorePerJudge: (json['totalPossibleScorePerJudge'] as num?)?.toInt() ?? 0,
      totalRequiredEvaluations: (json['totalRequiredEvaluations'] as num?)?.toInt() ?? 0,
      completedEvaluations: (json['completedEvaluations'] as num?)?.toInt() ?? 0,
      remainingEvaluations: (json['remainingEvaluations'] as num?)?.toInt() ?? 0,
      judgingCompletionPercentage: (json['judgingCompletionPercentage'] as num?)?.toDouble() ?? 0.0,
      judgingComplete: json['judgingComplete'] as bool? ?? false,
      resultsAvailable: json['resultsAvailable'] as bool? ?? false,
    );
  }

  ResultsSummaryEntity toEntity() {
    return ResultsSummaryEntity(
      totalTeams: totalTeams,
      activeTeams: activeTeams,
      totalJudges: totalJudges,
      activeJudges: activeJudges,
      totalCriteria: totalCriteria,
      activeCriteria: activeCriteria,
      totalPossibleScorePerJudge: totalPossibleScorePerJudge,
      totalRequiredEvaluations: totalRequiredEvaluations,
      completedEvaluations: completedEvaluations,
      remainingEvaluations: remainingEvaluations,
      judgingCompletionPercentage: judgingCompletionPercentage,
      judgingComplete: judgingComplete,
      resultsAvailable: resultsAvailable,
    );
  }
}
