/// Safe JSON casting utility functions resilient across Dart VM, Flutter Web, and JS runtimes.
Map<String, dynamic> asMap(dynamic data) {
  if (data == null) return <String, dynamic>{};
  if (data is Map<String, dynamic>) return data;
  if (data is Map) {
    try {
      return Map<String, dynamic>.from(data);
    } catch (_) {
      final result = <String, dynamic>{};
      for (final entry in data.entries) {
        result[entry.key.toString()] = entry.value;
      }
      return result;
    }
  }
  return <String, dynamic>{};
}

List<dynamic> asList(dynamic data) {
  if (data == null) return <dynamic>[];
  if (data is List<dynamic>) return data;
  if (data is List) return List<dynamic>.from(data);
  return <dynamic>[];
}
