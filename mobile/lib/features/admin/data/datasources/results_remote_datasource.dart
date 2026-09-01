import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json_utils.dart';
import '../models/results_summary_model.dart';
import '../models/ranking_result_model.dart';
import '../models/team_result_model.dart';

abstract class ResultsRemoteDataSource {
  Future<ResultsSummaryModel> getResultsSummary();
  Future<List<RankingResultModel>> getRanking();
  Future<TeamResultModel> getTeamResult(int teamId);
}

class ResultsRemoteDataSourceImpl implements ResultsRemoteDataSource {
  final ApiClient _apiClient;

  ResultsRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ResultsSummaryModel> getResultsSummary() async {
    final response = await _apiClient.get<ResultsSummaryModel>(
      ApiEndpoints.adminResultsSummary,
      fromJson: (json) => ResultsSummaryModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load results summary');
    }
    return response.data!;
  }

  @override
  Future<List<RankingResultModel>> getRanking() async {
    final response = await _apiClient.get<List<RankingResultModel>>(
      ApiEndpoints.adminResultsRanking,
      fromJson: (json) => asList(json)
          .map((item) => RankingResultModel.fromJson(item))
          .toList(),
    );
    return response.data ?? [];
  }

  @override
  Future<TeamResultModel> getTeamResult(int teamId) async {
    final response = await _apiClient.get<TeamResultModel>(
      '${ApiEndpoints.adminResultsTeamDetails}/$teamId',
      fromJson: (json) => TeamResultModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load team result details');
    }
    return response.data!;
  }
}
