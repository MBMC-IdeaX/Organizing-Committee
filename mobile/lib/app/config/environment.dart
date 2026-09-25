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

  /// LAN IP address for multi-device testing over local Wi-Fi
  static const String lanHost = '192.168.1.164';

  /// LAN development environment for testing APK on real devices
  static const Environment lan = Environment(
    type: EnvironmentType.dev,
    apiBaseUrl: 'http://$lanHost:8080/api/v1',
  );

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

  /// Optional override via --dart-define=API_BASE_URL=http://...
  static const String _customApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Automatically resolves the correct environment based on platform
  static Environment get defaultEnvironment {
    if (_customApiBaseUrl.isNotEmpty) {
      return Environment(
        type: EnvironmentType.dev,
        apiBaseUrl: _customApiBaseUrl,
      );
    } else if (kIsWeb) {
      // On web, connect to port 8080 on the host serving the web page (or fallback to lanHost)
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : lanHost;
      return Environment(
        type: EnvironmentType.dev,
        apiBaseUrl: 'http://$host:8080/api/v1',
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Default to LAN IP so APKs on physical devices connect to this computer's server
      return lan;
    } else {
      return local; // Windows, macOS, iOS Simulator use localhost:8080
    }
  }
}
