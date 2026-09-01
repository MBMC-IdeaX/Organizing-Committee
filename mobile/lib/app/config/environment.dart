import 'package:flutter/foundation.dart';

enum EnvironmentType {
  dev,
  prod,
}

class Environment {
  final EnvironmentType type;
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  const Environment({
    required this.type,
    required this.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
  });

  /// Default development environment for Android Emulator (10.0.2.2)
  static const Environment dev = Environment(
    type: EnvironmentType.dev,
    apiBaseUrl: 'http://10.0.2.2:8080/api/v1',
  );

  /// Local environment for Web, Windows, macOS, iOS Simulator (localhost)
  static const Environment local = Environment(
    type: EnvironmentType.dev,
    apiBaseUrl: 'http://localhost:8080/api/v1',
  );

  /// Production environment
  static const Environment prod = Environment(
    type: EnvironmentType.prod,
    apiBaseUrl: 'https://api.ideax.org/api/v1',
  );

  /// Automatically resolves the correct local environment based on platform
  static Environment get defaultEnvironment {
    if (kIsWeb) {
      return local; // Flutter Web uses localhost:8080
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return dev; // Android Emulator uses 10.0.2.2:8080
    } else {
      return local; // Windows, macOS, iOS Simulator use localhost:8080
    }
  }
}
