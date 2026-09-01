enum UserRole {
  admin,
  judge;

  static UserRole fromString(String? role) {
    if (role == null || role.trim().isEmpty) {
      throw const FormatException('User role cannot be null or empty');
    }
    switch (role) {
      case 'ADMIN':
        return UserRole.admin;
      case 'JUDGE':
        return UserRole.judge;
      default:
        throw FormatException('Invalid or unrecognized user role: $role');
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.judge:
        return 'Judge';
    }
  }

  String toServerValue() => name.toUpperCase();
}
