import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:iwitnez/core/network/auth_interceptor/auth_interceptor.dart';
import 'package:iwitnez/core/network/base_url/api_base_url.dart';

class DioClient {
  DioClient._();

  static Dio? _authDio;
  static Dio? _publicDio;

  /// Authenticated client
  static Dio get instance {
    return _authDio ??= _createDio(requireAuth: true);
  }

  /// Public client: login, signup, refresh without auth interceptor
  static Dio get instanceWithoutAuth {
    return _publicDio ??= _createDio(requireAuth: false);
  }

  /// Shared Dio configuration
  static Dio _createDio({required bool requireAuth}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiBaseUrl.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Auth interceptor only for protected APIs
    if (requireAuth) {
      dio.interceptors.add(AuthInterceptor(dio));
    }

    // Logging only in debug builds
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
          error: true,
        ),
      );
    }

    return dio;
  }

  /// Close and reset both clients
  static void reset() {
    _authDio?.close(force: true);
    _publicDio?.close(force: true);

    _authDio = null;
    _publicDio = null;
  }
}
