class Validators {
  Validators._();

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateScore(String? value, int maxScore) {
    if (value == null || value.trim().isEmpty) {
      return 'Score is required';
    }
    final score = int.tryParse(value.trim());
    if (score == null) {
      return 'Please enter a valid number';
    }
    if (score < 0) {
      return 'Score cannot be negative';
    }
    if (score > maxScore) {
      return 'Score cannot exceed $maxScore';
    }
    return null;
  }
}
