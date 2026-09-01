class JudgeTeamEntity {
  final int id;
  final String teamName;
  final String projectName;
  final String? idea;
  final int displayOrder;
  final String status; // NOT_STARTED, IN_PROGRESS, COMPLETED
  final int totalScore;
  final int totalMaxScore;

  const JudgeTeamEntity({
    required this.id,
    required this.teamName,
    required this.projectName,
    this.idea,
    required this.displayOrder,
    required this.status,
    required this.totalScore,
    required this.totalMaxScore,
  });

  bool get isCompleted => status == 'COMPLETED';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isNotStarted => status == 'NOT_STARTED';
}
