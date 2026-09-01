import 'package:dio/dio.dart';
import 'app_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  static AppException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        String message = 'An unexpected error occurred.';
        String? errorCode;

        if (responseData is Map) {
          message = responseData['message'] as String? ?? message;
          errorCode = responseData['errorCode'] as String?;
        }

        switch (statusCode) {
          case 400:
            return ValidationException(message: message);
          case 401:
            return UnauthorizedException(message: message, statusCode: statusCode);
          case 403:
            return ForbiddenException(message: message, statusCode: statusCode);
          case 404:
            return NotFoundException(message: message, statusCode: statusCode);
          case 409:
            return ConflictException(message: message, errorCode: errorCode, statusCode: statusCode);
          case 500:
          default:
            return ServerException(message: message, errorCode: errorCode, statusCode: statusCode);
        }

      case DioExceptionType.cancel:
        return const ServerException(message: 'Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException(message: 'Security certificate verification failed.');

      case DioExceptionType.unknown:
      default:
        return ServerException(message: error.message ?? 'Unknown network error.');
    }
  }
}
