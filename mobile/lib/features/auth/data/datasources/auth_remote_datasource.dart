import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/user_model.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final response = await _apiClient.post<AuthResponseModel>(
      ApiEndpoints.login,
      data: request.toJson(),
      fromJson: (json) => AuthResponseModel.fromJson(json),
    );

    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Login failed');
    }

    return response.data!;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get<UserModel>(
      ApiEndpoints.me,
      fromJson: (json) => UserModel.fromJson(json),
    );

    if (response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch user');
    }

    return response.data!;
  }
}
