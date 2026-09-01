import 'package:equatable/equatable.dart';
import '../../../../shared/models/user_role.dart';

class JudgeEntity extends Equatable {
  final int id;
  final String username;
  final UserRole role;
  final bool active;

  const JudgeEntity({
    required this.id,
    required this.username,
    required this.role,
    required this.active,
  });

  @override
  List<Object?> get props => [id, username, role, active];
}
