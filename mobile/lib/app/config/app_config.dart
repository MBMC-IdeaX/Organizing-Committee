import 'environment.dart';

class AppConfig {
  static Environment _environment = Environment.local;

  static void initialize({required Environment environment}) {
    _environment = environment;
  }

  static Environment get environment => _environment;
  static String get apiBaseUrl => _environment.apiBaseUrl;
  static bool get isDev => _environment.type == EnvironmentType.dev;
}
