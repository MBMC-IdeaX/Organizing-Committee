import 'package:equatable/equatable.dart';
import '../../core/utils/json_utils.dart';
import 'user_role.dart';

class UserModel extends Equatable {
  final int id;
  final String username;
  final UserRole role;
  final bool active;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.active,
    this.createdAt,
  });

  factory UserModel.fromJson(dynamic rawJson) {
    final json = asMap(rawJson);
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      active: json['active'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role.toServerValue(),
      'active': active,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, username, role, active, createdAt];
}
