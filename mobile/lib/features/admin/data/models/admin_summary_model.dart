import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/admin_summary_entity.dart';

class AdminSummaryModel {
  final int totalTeams;
  final int activeTeams;
  final int totalCriteria;
  final int activeCriteria;
  final int totalMaxScore;
  final int totalJudges;
  final int activeJudges;
  final bool readyForJudging;

  AdminSummaryModel({
    required this.totalTeams,
    required this.activeTeams,
    required this.totalCriteria,
    required this.activeCriteria,
    required this.totalMaxScore,
    required this.totalJudges,
    required this.activeJudges,
    required this.readyForJudging,
  });

  factory AdminSummaryModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return AdminSummaryModel(
      totalTeams: (json['totalTeams'] as num?)?.toInt() ?? 0,
      activeTeams: (json['activeTeams'] as num?)?.toInt() ?? 0,
      totalCriteria: (json['totalCriteria'] as num?)?.toInt() ?? 0,
      activeCriteria: (json['activeCriteria'] as num?)?.toInt() ?? 0,
      totalMaxScore: (json['totalMaxScore'] as num?)?.toInt() ?? 0,
      totalJudges: (json['totalJudges'] as num?)?.toInt() ?? 0,
      activeJudges: (json['activeJudges'] as num?)?.toInt() ?? 0,
      readyForJudging: json['readyForJudging'] as bool? ?? false,
    );
  }

  AdminSummaryEntity toEntity() {
    return AdminSummaryEntity(
      totalTeams: totalTeams,
      activeTeams: activeTeams,
      totalCriteria: totalCriteria,
      activeCriteria: activeCriteria,
      totalMaxScore: totalMaxScore,
      totalJudges: totalJudges,
      activeJudges: activeJudges,
      readyForJudging: readyForJudging,
    );
  }
}
