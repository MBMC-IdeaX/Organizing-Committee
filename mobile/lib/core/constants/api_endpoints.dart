class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Health
  static const String health = '/health';

  // Admin
  static const String adminDashboardSummary = '/admin/dashboard/summary';
  static const String adminTeams = '/admin/teams';
  static const String adminTeamsReorder = '/admin/teams/reorder';
  static const String adminCriteria = '/admin/criteria';
  static const String adminCriteriaReorder = '/admin/criteria/reorder';
  static const String adminCriteriaTotalScore = '/admin/criteria/total-score';
  static const String adminJudges = '/admin/judges';
  static const String adminPing = '/admin/ping';
  static const String adminResultsSummary = '/admin/results/summary';
  static const String adminResultsRanking = '/admin/results/ranking';
  static const String adminResultsTeamDetails = '/admin/results/teams';
  static const String adminSystemReset = '/admin/system/reset-data';

  // Judge
  static const String judgeDashboard = '/judge/dashboard';
  static const String judgeTeams = '/judge/teams';
  static const String judgeJudgings = '/judge/judgings';
  static const String judgePing = '/judge/ping';
}
