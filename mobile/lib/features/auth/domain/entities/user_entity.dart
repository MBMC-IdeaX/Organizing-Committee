import 'package:equatable/equatable.dart';
import '../../../../shared/models/user_role.dart';

class UserEntity extends Equatable {
  final int id;
  final String username;
  final UserRole role;
  final bool active;

  const UserEntity({
    required this.id,
    required this.username,
    required this.role,
    required this.active,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isJudge => role == UserRole.judge;

  @override
  List<Object?> get props => [id, username, role, active];
}
