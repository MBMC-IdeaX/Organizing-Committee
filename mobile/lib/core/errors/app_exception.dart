import 'package:equatable/equatable.dart';

abstract class AppException extends Equatable implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  const AppException({
    required this.message,
    this.errorCode,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, errorCode, statusCode];

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Unable to connect to server. Please check your network connection.',
    super.errorCode = 'NETWORK_ERROR',
    super.statusCode,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Invalid credentials or session expired. Please login again.',
    super.errorCode = 'UNAUTHORIZED',
    super.statusCode = 401,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Access denied. You do not have permission to perform this action.',
    super.errorCode = 'ACCESS_DENIED',
    super.statusCode = 403,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Requested resource not found.',
    super.errorCode = 'RESOURCE_NOT_FOUND',
    super.statusCode = 404,
  });
}

class ConflictException extends AppException {
  const ConflictException({
    required super.message,
    String? errorCode,
    super.statusCode = 409,
  }) : super(errorCode: errorCode ?? 'DUPLICATE_RESOURCE');
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.errorCode = 'VALIDATION_ERROR',
    super.statusCode = 400,
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message = 'An unexpected server error occurred. Please try again later.',
    super.errorCode = 'INTERNAL_SERVER_ERROR',
    super.statusCode = 500,
  });
}
