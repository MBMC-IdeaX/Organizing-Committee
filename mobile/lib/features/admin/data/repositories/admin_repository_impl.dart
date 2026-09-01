import '../../domain/entities/admin_summary_entity.dart';
import '../../domain/entities/criteria_entity.dart';
import '../../domain/entities/judge_entity.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl({required AdminRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<TeamEntity>> getTeams() async {
    final models = await _remoteDataSource.getTeams();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TeamEntity> createTeam({
    required String teamName,
    required String projectName,
    String? idea,
    int displayOrder = 0,
  }) async {
    final model = await _remoteDataSource.createTeam({
      'teamName': teamName,
      'projectName': projectName,
      'idea': idea,
      'displayOrder': displayOrder,
    });
    return model.toEntity();
  }

  @override
  Future<TeamEntity> updateTeam({
    required int id,
    required String teamName,
    required String projectName,
    String? idea,
    required int displayOrder,
  }) async {
    final model = await _remoteDataSource.updateTeam(id, {
      'teamName': teamName,
      'projectName': projectName,
      'idea': idea,
      'displayOrder': displayOrder,
    });
    return model.toEntity();
  }

  @override
  Future<TeamEntity> updateTeamStatus({required int id, required bool active}) async {
    final model = await _remoteDataSource.updateTeamStatus(id, active);
    return model.toEntity();
  }

  @override
  Future<List<TeamEntity>> reorderTeams(List<int> orderedIds) async {
    final models = await _remoteDataSource.reorderTeams(orderedIds);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteTeam(int id, {bool force = false}) async {
    await _remoteDataSource.deleteTeam(id, force: force);
  }

  @override
  Future<List<CriteriaEntity>> getCriteria() async {
    final models = await _remoteDataSource.getCriteria();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CriteriaEntity> createCriteria({
    required String name,
    String? description,
    required int maxScore,
    int displayOrder = 0,
  }) async {
    final model = await _remoteDataSource.createCriteria({
      'name': name,
      'description': description,
      'maxScore': maxScore,
      'displayOrder': displayOrder,
    });
    return model.toEntity();
  }

  @override
  Future<CriteriaEntity> updateCriteria({
    required int id,
    required String name,
    String? description,
    required int maxScore,
    required int displayOrder,
  }) async {
    final model = await _remoteDataSource.updateCriteria(id, {
      'name': name,
      'description': description,
      'maxScore': maxScore,
      'displayOrder': displayOrder,
    });
    return model.toEntity();
  }

  @override
  Future<CriteriaEntity> updateCriteriaStatus({required int id, required bool active}) async {
    final model = await _remoteDataSource.updateCriteriaStatus(id, active);
    return model.toEntity();
  }

  @override
  Future<List<CriteriaEntity>> reorderCriteria(List<int> orderedIds) async {
    final models = await _remoteDataSource.reorderCriteria(orderedIds);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> getTotalMaxScore() async {
    return await _remoteDataSource.getTotalMaxScore();
  }

  @override
  Future<List<JudgeEntity>> getJudges() async {
    final models = await _remoteDataSource.getJudges();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<JudgeEntity> createJudge({required String username, required String password}) async {
    final model = await _remoteDataSource.createJudge(username, password);
    return model.toEntity();
  }

  @override
  Future<JudgeEntity> updateJudge({required int id, required String username, String? password}) async {
    final model = await _remoteDataSource.updateJudge(id, username, password);
    return model.toEntity();
  }

  @override
  Future<JudgeEntity> updateJudgeStatus({required int id, required bool active}) async {
    final model = await _remoteDataSource.updateJudgeStatus(id, active);
    return model.toEntity();
  }

  @override
  Future<void> deleteJudge(int id, {bool force = false}) async {
    await _remoteDataSource.deleteJudge(id, force: force);
  }

  @override
  Future<AdminSummaryEntity> getDashboardSummary() async {
    final model = await _remoteDataSource.getDashboardSummary();
    return model.toEntity();
  }

  @override
  Future<Map<String, dynamic>> resetSystemData({
    required String adminPassword,
    bool clearJudgings = true,
    bool clearJudges = false,
    bool clearTeams = false,
  }) async {
    return await _remoteDataSource.resetSystemData(
      adminPassword: adminPassword,
      clearJudgings: clearJudgings,
      clearJudges: clearJudges,
      clearTeams: clearTeams,
    );
  }
}
