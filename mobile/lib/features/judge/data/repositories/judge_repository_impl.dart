import '../../domain/entities/judge_dashboard_entity.dart';
import '../../domain/entities/judge_team_entity.dart';
import '../../domain/entities/judging_session_entity.dart';
import '../../domain/repositories/judge_repository.dart';
import '../datasources/judge_remote_datasource.dart';

class JudgeRepositoryImpl implements JudgeRepository {
  final JudgeRemoteDataSource _remoteDataSource;

  JudgeRepositoryImpl({required JudgeRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<JudgeDashboardEntity> getDashboard() async {
    final model = await _remoteDataSource.getDashboard();
    return model.toEntity();
  }

  @override
  Future<List<JudgeTeamEntity>> getTeams() async {
    final models = await _remoteDataSource.getTeams();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<JudgingSessionEntity> getJudgingSession(int teamId) async {
    final model = await _remoteDataSource.getJudgingSession(teamId);
    return model.toEntity();
  }

  @override
  Future<JudgingSessionEntity> startJudging(int teamId) async {
    final model = await _remoteDataSource.startJudging(teamId);
    return model.toEntity();
  }

  @override
  Future<JudgingSessionEntity> saveScores(int teamId, List<Map<String, dynamic>> scores) async {
    final model = await _remoteDataSource.saveScores(teamId, scores);
    return model.toEntity();
  }

  @override
  Future<JudgingSessionEntity> saveComment(int teamId, String comment) async {
    final model = await _remoteDataSource.saveComment(teamId, comment);
    return model.toEntity();
  }

  @override
  Future<JudgingSessionEntity> completeJudging({
    required int teamId,
    String? comment,
    List<Map<String, dynamic>>? scores,
  }) async {
    final model = await _remoteDataSource.completeJudging(
      teamId: teamId,
      comment: comment,
      scores: scores,
    );
    return model.toEntity();
  }
}
