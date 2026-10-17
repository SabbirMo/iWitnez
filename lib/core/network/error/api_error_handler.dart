import 'dart:io';
import 'package:dio/dio.dart';
import 'package:iwitnez/core/network/error/api_error.dart';

export 'api_error.dart';

class ApiErrorHandler {
  ApiErrorHandler._();

  /// Returns an [ApiError] instance from any error/exception.
  static ApiError handle(dynamic error) {
    if (error is DioException) {
      return _handleDioException(error);
    } else if (error is SocketException) {
      return const ApiError(
        message: 'No internet connection. Please check your network.',
      );
    } else if (error is FormatException) {
      return const ApiError(
        message: 'Bad response format received from server.',
      );
    } else if (error is ApiError) {
      return error;
    } else {
      return ApiError(
        message: error?.toString() ?? 'An unexpected error occurred.',
      );
    }
  }

  /// Extracts a human-readable error message directly.
  static String getMessage(dynamic error) {
    return handle(error).message;
  }

  static ApiError _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiError(
          message: 'Connection timeout with the server. Please try again.',
        );
      case DioExceptionType.sendTimeout:
        return const ApiError(
          message: 'Send timeout in connection with server. Please try again.',
        );
      case DioExceptionType.receiveTimeout:
        return const ApiError(
          message: 'Receive timeout in connection with server. Please try again.',
        );
      case DioExceptionType.badCertificate:
        return const ApiError(
          message: 'SSL certificate verification failed.',
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return const ApiError(
          message: 'Request to the server was cancelled.',
        );
      case DioExceptionType.connectionError:
        return const ApiError(
          message: 'No internet connection or server is unreachable.',
        );
      default:
        if (error.error is SocketException) {
          return const ApiError(
            message: 'No internet connection. Please check your network.',
          );
        }
        return ApiError(
          message: error.message ?? 'An unexpected network error occurred.',
        );
    }
  }

  static ApiError _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    final message = _extractErrorMessage(data) ?? _getDefaultStatusMessage(statusCode);

    return ApiError(
      message: message,
      statusCode: statusCode,
      errors: data,
    );
  }

  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isNotEmpty && !trimmed.startsWith('<')) {
        return trimmed;
      }
      return null;
    }

    if (data is Map) {
      // Check common error message keys
      for (final key in ['message', 'detail', 'error', 'msg']) {
        if (data.containsKey(key) && data[key] != null) {
          final val = data[key];
          if (val is String && val.trim().isNotEmpty) {
            return val.trim();
          }
          if (val is List && val.isNotEmpty) {
            return val.first.toString();
          }
        }
      }

      // Check Django REST framework 'non_field_errors'
      if (data.containsKey('non_field_errors') && data['non_field_errors'] != null) {
        final nfe = data['non_field_errors'];
        if (nfe is List && nfe.isNotEmpty) {
          return nfe.first.toString();
        }
        if (nfe is String && nfe.trim().isNotEmpty) {
          return nfe.trim();
        }
      }

      // Check field-specific errors: e.g. {"email": ["Enter a valid email."], ...}
      final errorMessages = <String>[];
      data.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          errorMessages.add('$key: ${value.join(', ')}');
        } else if (value is String && value.trim().isNotEmpty) {
          errorMessages.add('$key: $value');
        }
      });

      if (errorMessages.isNotEmpty) {
        return errorMessages.join('\n');
      }
    }

    if (data is List && data.isNotEmpty) {
      return data.first.toString();
    }

    return null;
  }

  static String _getDefaultStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please verify your data.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied. You do not have permission.';
      case 404:
        return 'Requested resource not found.';
      case 408:
        return 'Request timeout. Please try again.';
      case 409:
        return 'Conflict occurred. Please try again.';
      case 422:
        return 'Unprocessable entity. Please verify input data.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. The server encountered an issue.';
      case 503:
        return 'Service unavailable. Server is temporarily down.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        return 'Something went wrong. Status code: ${statusCode ?? 'Unknown'}';
    }
  }
}
