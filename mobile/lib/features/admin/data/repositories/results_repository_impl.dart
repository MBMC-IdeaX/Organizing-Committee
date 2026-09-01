import '../../domain/entities/ranking_result_entity.dart';
import '../../domain/entities/results_summary_entity.dart';
import '../../domain/entities/team_result_entity.dart';
import '../../domain/repositories/results_repository.dart';
import '../datasources/results_remote_datasource.dart';

class ResultsRepositoryImpl implements ResultsRepository {
  final ResultsRemoteDataSource _remoteDataSource;

  ResultsRepositoryImpl({required ResultsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<ResultsSummaryEntity> getResultsSummary() async {
    final summaryModel = await _remoteDataSource.getResultsSummary();
    return summaryModel.toEntity();
  }

  @override
  Future<List<RankingResultEntity>> getRanking() async {
    final models = await _remoteDataSource.getRanking();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TeamResultEntity> getTeamResult(int teamId) async {
    final teamResultModel = await _remoteDataSource.getTeamResult(teamId);
    return teamResultModel.toEntity();
  }
}
