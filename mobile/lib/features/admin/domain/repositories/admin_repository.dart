import '../entities/admin_summary_entity.dart';
import '../entities/criteria_entity.dart';
import '../entities/judge_entity.dart';
import '../entities/team_entity.dart';

abstract class AdminRepository {
  // Teams
  Future<List<TeamEntity>> getTeams();
  Future<TeamEntity> createTeam({
    required String teamName,
    required String projectName,
    String? idea,
    int displayOrder = 0,
  });
  Future<TeamEntity> updateTeam({
    required int id,
    required String teamName,
    required String projectName,
    String? idea,
    required int displayOrder,
  });
  Future<TeamEntity> updateTeamStatus({required int id, required bool active});
  Future<List<TeamEntity>> reorderTeams(List<int> orderedIds);
  Future<void> deleteTeam(int id, {bool force = false});

  // Criteria
  Future<List<CriteriaEntity>> getCriteria();
  Future<CriteriaEntity> createCriteria({
    required String name,
    String? description,
    required int maxScore,
    int displayOrder = 0,
  });
  Future<CriteriaEntity> updateCriteria({
    required int id,
    required String name,
    String? description,
    required int maxScore,
    required int displayOrder,
  });
  Future<CriteriaEntity> updateCriteriaStatus({required int id, required bool active});
  Future<List<CriteriaEntity>> reorderCriteria(List<int> orderedIds);
  Future<int> getTotalMaxScore();

  // Judges
  Future<List<JudgeEntity>> getJudges();
  Future<JudgeEntity> createJudge({required String username, required String password});
  Future<JudgeEntity> updateJudge({required int id, required String username, String? password});
  Future<JudgeEntity> updateJudgeStatus({required int id, required bool active});
  Future<void> deleteJudge(int id, {bool force = false});

  // Dashboard & System
  Future<AdminSummaryEntity> getDashboardSummary();
  Future<Map<String, dynamic>> resetSystemData({
    required String adminPassword,
    bool clearJudgings = true,
    bool clearJudges = false,
    bool clearTeams = false,
  });
}
