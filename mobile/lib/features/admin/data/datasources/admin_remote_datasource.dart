import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json_utils.dart';
import '../models/admin_summary_model.dart';
import '../models/criteria_model.dart';
import '../models/judge_model.dart';
import '../models/team_model.dart';

abstract class AdminRemoteDataSource {
  // Teams
  Future<List<TeamModel>> getTeams();
  Future<TeamModel> createTeam(Map<String, dynamic> data);
  Future<TeamModel> updateTeam(int id, Map<String, dynamic> data);
  Future<TeamModel> updateTeamStatus(int id, bool active);
  Future<List<TeamModel>> reorderTeams(List<int> orderedIds);
  Future<void> deleteTeam(int id, {bool force = false});

  // Criteria
  Future<List<CriteriaModel>> getCriteria();
  Future<CriteriaModel> createCriteria(Map<String, dynamic> data);
  Future<CriteriaModel> updateCriteria(int id, Map<String, dynamic> data);
  Future<CriteriaModel> updateCriteriaStatus(int id, bool active);
  Future<List<CriteriaModel>> reorderCriteria(List<int> orderedIds);
  Future<int> getTotalMaxScore();

  // Judges
  Future<List<JudgeModel>> getJudges();
  Future<JudgeModel> createJudge(String username, String password);
  Future<JudgeModel> updateJudge(int id, String username, String? password);
  Future<JudgeModel> updateJudgeStatus(int id, bool active);
  Future<void> deleteJudge(int id, {bool force = false});

  // Dashboard & System
  Future<AdminSummaryModel> getDashboardSummary();
  Future<Map<String, dynamic>> resetSystemData({
    required String adminPassword,
    bool clearJudgings = true,
    bool clearJudges = false,
    bool clearTeams = false,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient _apiClient;

  AdminRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<TeamModel>> getTeams() async {
    final response = await _apiClient.get<List<TeamModel>>(
      ApiEndpoints.adminTeams,
      fromJson: (json) => asList(json)
          .map((item) => TeamModel.fromJson(item))
          .toList(),
    );
    return response.data ?? [];
  }

  @override
  Future<TeamModel> createTeam(Map<String, dynamic> data) async {
    final response = await _apiClient.post<TeamModel>(
      ApiEndpoints.adminTeams,
      data: data,
      fromJson: (json) => TeamModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to create team');
    }
    return response.data!;
  }

  @override
  Future<TeamModel> updateTeam(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put<TeamModel>(
      '${ApiEndpoints.adminTeams}/$id',
      data: data,
      fromJson: (json) => TeamModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to update team');
    }
    return response.data!;
  }

  @override
  Future<TeamModel> updateTeamStatus(int id, bool active) async {
    final response = await _apiClient.patch<TeamModel>(
      '${ApiEndpoints.adminTeams}/$id/status',
      data: {'active': active},
      fromJson: (json) => TeamModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to update team status');
    }
    return response.data!;
  }

  @override
  Future<List<TeamModel>> reorderTeams(List<int> orderedIds) async {
    final response = await _apiClient.put<List<TeamModel>>(
      ApiEndpoints.adminTeamsReorder,
      data: {'orderedIds': orderedIds},
      fromJson: (json) => asList(json)
          .map((item) => TeamModel.fromJson(item))
          .toList(),
    );
    return response.data ?? [];
  }

  @override
  Future<void> deleteTeam(int id, {bool force = false}) async {
    final query = force ? '?force=true' : '';
    await _apiClient.delete('${ApiEndpoints.adminTeams}/$id$query');
  }

  @override
  Future<List<CriteriaModel>> getCriteria() async {
    final response = await _apiClient.get<List<CriteriaModel>>(
      ApiEndpoints.adminCriteria,
      fromJson: (json) => asList(json)
          .map((item) => CriteriaModel.fromJson(item))
          .toList(),
    );
    return response.data ?? [];
  }

  @override
  Future<CriteriaModel> createCriteria(Map<String, dynamic> data) async {
    final response = await _apiClient.post<CriteriaModel>(
      ApiEndpoints.adminCriteria,
      data: data,
      fromJson: (json) => CriteriaModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to create criteria');
    }
    return response.data!;
  }

  @override
  Future<CriteriaModel> updateCriteria(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put<CriteriaModel>(
      '${ApiEndpoints.adminCriteria}/$id',
      data: data,
      fromJson: (json) => CriteriaModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to update criteria');
    }
    return response.data!;
  }

  @override
  Future<CriteriaModel> updateCriteriaStatus(int id, bool active) async {
    final response = await _apiClient.patch<CriteriaModel>(
      '${ApiEndpoints.adminCriteria}/$id/status',
      data: {'active': active},
      fromJson: (json) => CriteriaModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to update criteria status');
    }
    return response.data!;
  }

  @override
  Future<List<CriteriaModel>> reorderCriteria(List<int> orderedIds) async {
    final response = await _apiClient.put<List<CriteriaModel>>(
      ApiEndpoints.adminCriteriaReorder,
      data: {'orderedIds': orderedIds},
      fromJson: (json) => asList(json)
          .map((item) => CriteriaModel.fromJson(item))
          .toList(),
    );
    return response.data ?? [];
  }

  @override
  Future<int> getTotalMaxScore() async {
    final response = await _apiClient.get<int>(
      ApiEndpoints.adminCriteriaTotalScore,
      fromJson: (json) => (asMap(json)['totalMaxScore'] as num?)?.toInt() ?? 0,
    );
    return response.data ?? 0;
  }

  @override
  Future<List<JudgeModel>> getJudges() async {
    final response = await _apiClient.get<List<JudgeModel>>(
      ApiEndpoints.adminJudges,
      fromJson: (json) => asList(json)
          .map((item) => JudgeModel.fromJson(item))
          .toList(),
    );
    return response.data ?? [];
  }

  @override
  Future<JudgeModel> createJudge(String username, String password) async {
    final response = await _apiClient.post<JudgeModel>(
      ApiEndpoints.adminJudges,
      data: {'username': username, 'password': password},
      fromJson: (json) => JudgeModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to create judge');
    }
    return response.data!;
  }

  @override
  Future<JudgeModel> updateJudge(int id, String username, String? password) async {
    final Map<String, dynamic> data = {'username': username};
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }
    final response = await _apiClient.put<JudgeModel>(
      '${ApiEndpoints.adminJudges}/$id',
      data: data,
      fromJson: (json) => JudgeModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to update judge');
    }
    return response.data!;
  }

  @override
  Future<JudgeModel> updateJudgeStatus(int id, bool active) async {
    final response = await _apiClient.patch<JudgeModel>(
      '${ApiEndpoints.adminJudges}/$id/status',
      data: {'active': active},
      fromJson: (json) => JudgeModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to update judge status');
    }
    return response.data!;
  }

  @override
  Future<void> deleteJudge(int id, {bool force = false}) async {
    final query = force ? '?force=true' : '';
    await _apiClient.delete('${ApiEndpoints.adminJudges}/$id$query');
  }

  @override
  Future<AdminSummaryModel> getDashboardSummary() async {
    final response = await _apiClient.get<AdminSummaryModel>(
      ApiEndpoints.adminDashboardSummary,
      fromJson: (json) => AdminSummaryModel.fromJson(json),
    );
    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load dashboard summary');
    }
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> resetSystemData({
    required String adminPassword,
    bool clearJudgings = true,
    bool clearJudges = false,
    bool clearTeams = false,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.adminSystemReset,
      data: {
        'adminPassword': adminPassword,
        'clearJudgings': clearJudgings,
        'clearJudges': clearJudges,
        'clearTeams': clearTeams,
      },
      fromJson: (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
    return response.data ?? {};
  }
}
