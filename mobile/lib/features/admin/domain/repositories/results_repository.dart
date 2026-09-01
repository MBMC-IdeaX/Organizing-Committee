import '../entities/results_summary_entity.dart';
import '../entities/ranking_result_entity.dart';
import '../entities/team_result_entity.dart';

abstract class ResultsRepository {
  Future<ResultsSummaryEntity> getResultsSummary();
  Future<List<RankingResultEntity>> getRanking();
  Future<TeamResultEntity> getTeamResult(int teamId);
}
