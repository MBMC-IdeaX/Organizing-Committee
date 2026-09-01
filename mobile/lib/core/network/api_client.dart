import 'package:dio/dio.dart';
import '../../app/config/app_config.dart';
import '../errors/error_handler.dart';
import '../storage/storage_service_interface.dart';
import '../utils/json_utils.dart';
import 'api_response.dart';
import 'auth_interceptor.dart';
import 'session_event_bus.dart';

/// Centralized REST API Client with Dio, Interceptors, and robust Error Handling.
class ApiClient {
  late final Dio _dio;
  final StorageServiceInterface storageService;
  final SessionEventBus sessionEventBus;

  ApiClient({
    required this.storageService,
    required this.sessionEventBus,
    Dio? dio,
    String? baseUrl,
  }) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
            connectTimeout: AppConfig.environment.connectTimeout,
            receiveTimeout: AppConfig.environment.receiveTimeout,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );

    _dio.interceptors.add(
      AuthInterceptor(
        storageService: storageService,
        sessionEventBus: sessionEventBus,
      ),
    );
  }

  Dio get dio => _dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromJson(asMap(response.data), fromJson);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromJson(asMap(response.data), fromJson);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromJson(asMap(response.data), fromJson);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromJson(asMap(response.data), fromJson);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromJson(asMap(response.data), fromJson);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
