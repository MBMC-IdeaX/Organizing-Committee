import '../../../../core/utils/json_utils.dart';
import '../../../../shared/models/user_role.dart';
import '../../domain/entities/judge_entity.dart';

class JudgeModel {
  final int id;
  final String username;
  final UserRole role;
  final bool active;

  JudgeModel({
    required this.id,
    required this.username,
    required this.role,
    required this.active,
  });

  factory JudgeModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return JudgeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      active: json['active'] as bool? ?? true,
    );
  }

  JudgeEntity toEntity() {
    return JudgeEntity(
      id: id,
      username: username,
      role: role,
      active: active,
    );
  }
}
