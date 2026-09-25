import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'app/config/app_config.dart';
import 'app/config/environment.dart';
import 'core/network/api_client.dart';
import 'core/network/session_event_bus.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/admin/data/datasources/admin_remote_datasource.dart';
import 'features/admin/data/datasources/results_remote_datasource.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/data/repositories/results_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/judge/data/datasources/judge_remote_datasource.dart';
import 'features/judge/data/repositories/judge_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialize App Configuration (Platform-aware: Web/Desktop -> localhost, Android -> LAN 192.168.1.164)
  AppConfig.initialize(environment: Environment.defaultEnvironment);

  // Initialize Core Services
  final secureStorage = SecureStorageService();
  final sessionEventBus = SessionEventBusImpl();
  final apiClient = ApiClient(
    storageService: secureStorage,
    sessionEventBus: sessionEventBus,
  );

  // Initialize Feature Data & Repository Layer
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    storageService: secureStorage,
    sessionEventBus: sessionEventBus,
  );

  final adminRemoteDataSource = AdminRemoteDataSourceImpl(apiClient: apiClient);
  final adminRepository = AdminRepositoryImpl(remoteDataSource: adminRemoteDataSource);

  final judgeRemoteDataSource = JudgeRemoteDataSourceImpl(apiClient: apiClient);
  final judgeRepository = JudgeRepositoryImpl(remoteDataSource: judgeRemoteDataSource);

  final resultsRemoteDataSource = ResultsRemoteDataSourceImpl(apiClient: apiClient);
  final resultsRepository = ResultsRepositoryImpl(remoteDataSource: resultsRemoteDataSource);

  runApp(IdeaXApp(
    authRepository: authRepository,
    adminRepository: adminRepository,
    judgeRepository: judgeRepository,
    resultsRepository: resultsRepository,
  ));
}
