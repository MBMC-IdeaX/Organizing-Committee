import 'package:equatable/equatable.dart';

class AdminSummaryEntity extends Equatable {
  final int totalTeams;
  final int activeTeams;
  final int totalCriteria;
  final int activeCriteria;
  final int totalMaxScore;
  final int totalJudges;
  final int activeJudges;
  final bool readyForJudging;

  const AdminSummaryEntity({
    required this.totalTeams,
    required this.activeTeams,
    required this.totalCriteria,
    required this.activeCriteria,
    required this.totalMaxScore,
    required this.totalJudges,
    required this.activeJudges,
    required this.readyForJudging,
  });

  @override
  List<Object?> get props => [
        totalTeams,
        activeTeams,
        totalCriteria,
        activeCriteria,
        totalMaxScore,
        totalJudges,
        activeJudges,
        readyForJudging,
      ];
}
