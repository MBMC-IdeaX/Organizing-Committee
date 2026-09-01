import 'package:dio/dio.dart';
import '../storage/storage_service_interface.dart';
import 'session_event_bus.dart';

class AuthInterceptor extends Interceptor {
  final StorageServiceInterface _storageService;
  final SessionEventBus _sessionEventBus;

  AuthInterceptor({
    required StorageServiceInterface storageService,
    required SessionEventBus sessionEventBus,
  })  : _storageService = storageService,
        _sessionEventBus = sessionEventBus;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear token from secure storage and notify session event bus
      _storageService.clearSession();
      _sessionEventBus.notifyUnauthorized();
    }
    return handler.next(err);
  }
}
