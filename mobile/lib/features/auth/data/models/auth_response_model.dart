import '../../../../core/utils/json_utils.dart';
import '../../../../shared/models/user_model.dart';
import '../../domain/entities/user_entity.dart';

class AuthResponseModel {
  final String token;
  final String tokenType;
  final UserModel user;

  const AuthResponseModel({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponseModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return AuthResponseModel(
      token: json['token'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      user: UserModel.fromJson(json['user']),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: user.id,
      username: user.username,
      role: user.role,
      active: user.active,
    );
  }
}
