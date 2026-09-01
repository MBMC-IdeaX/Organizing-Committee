import '../entities/judge_dashboard_entity.dart';
import '../entities/judge_team_entity.dart';
import '../entities/judging_session_entity.dart';

abstract class JudgeRepository {
  Future<JudgeDashboardEntity> getDashboard();

  Future<List<JudgeTeamEntity>> getTeams();

  Future<JudgingSessionEntity> getJudgingSession(int teamId);

  Future<JudgingSessionEntity> startJudging(int teamId);

  Future<JudgingSessionEntity> saveScores(int teamId, List<Map<String, dynamic>> scores);

  Future<JudgingSessionEntity> saveComment(int teamId, String comment);

  Future<JudgingSessionEntity> completeJudging({
    required int teamId,
    String? comment,
    List<Map<String, dynamic>>? scores,
  });
}
