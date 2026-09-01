import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json_utils.dart';
import '../models/judge_dashboard_model.dart';
import '../models/judge_team_model.dart';
import '../models/judging_session_model.dart';

abstract class JudgeRemoteDataSource {
  Future<JudgeDashboardModel> getDashboard();

  Future<List<JudgeTeamModel>> getTeams();

  Future<JudgingSessionModel> getJudgingSession(int teamId);

  Future<JudgingSessionModel> startJudging(int teamId);

  Future<JudgingSessionModel> saveScores(int teamId, List<Map<String, dynamic>> scores);

  Future<JudgingSessionModel> saveComment(int teamId, String comment);

  Future<JudgingSessionModel> completeJudging({
    required int teamId,
    String? comment,
    List<Map<String, dynamic>>? scores,
  });
}

class JudgeRemoteDataSourceImpl implements JudgeRemoteDataSource {
  final ApiClient _apiClient;

  JudgeRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<JudgeDashboardModel> getDashboard() async {
    final response = await _apiClient.get<JudgeDashboardModel>(
      ApiEndpoints.judgeDashboard,
      fromJson: (json) => JudgeDashboardModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load judge dashboard');
    }
    return response.data!;
  }

  @override
  Future<List<JudgeTeamModel>> getTeams() async {
    final response = await _apiClient.get<List<JudgeTeamModel>>(
      ApiEndpoints.judgeTeams,
      fromJson: (json) => asList(json)
          .map((item) => JudgeTeamModel.fromJson(item))
          .toList(),
    );
    return response.data ?? [];
  }

  @override
  Future<JudgingSessionModel> getJudgingSession(int teamId) async {
    final response = await _apiClient.get<JudgingSessionModel>(
      '${ApiEndpoints.judgeJudgings}/$teamId',
      fromJson: (json) => JudgingSessionModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load judging session');
    }
    return response.data!;
  }

  @override
  Future<JudgingSessionModel> startJudging(int teamId) async {
    final response = await _apiClient.post<JudgingSessionModel>(
      '${ApiEndpoints.judgeJudgings}/$teamId/start',
      fromJson: (json) => JudgingSessionModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to start judging session');
    }
    return response.data!;
  }

  @override
  Future<JudgingSessionModel> saveScores(int teamId, List<Map<String, dynamic>> scores) async {
    final response = await _apiClient.put<JudgingSessionModel>(
      '${ApiEndpoints.judgeJudgings}/$teamId/scores',
      data: {'scores': scores},
      fromJson: (json) => JudgingSessionModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to save scores');
    }
    return response.data!;
  }

  @override
  Future<JudgingSessionModel> saveComment(int teamId, String comment) async {
    final response = await _apiClient.put<JudgingSessionModel>(
      '${ApiEndpoints.judgeJudgings}/$teamId/comment',
      data: {'comment': comment},
      fromJson: (json) => JudgingSessionModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to save comment');
    }
    return response.data!;
  }

  @override
  Future<JudgingSessionModel> completeJudging({
    required int teamId,
    String? comment,
    List<Map<String, dynamic>>? scores,
  }) async {
    final Map<String, dynamic> body = {};
    if (comment != null) {
      body['comment'] = comment;
    }
    if (scores != null && scores.isNotEmpty) {
      body['scores'] = scores;
    }

    final response = await _apiClient.post<JudgingSessionModel>(
      '${ApiEndpoints.judgeJudgings}/$teamId/complete',
      data: body,
      fromJson: (json) => JudgingSessionModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to complete evaluation');
    }
    return response.data!;
  }
}
