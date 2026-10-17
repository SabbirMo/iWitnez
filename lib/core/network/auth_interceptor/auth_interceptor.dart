import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/base_url/api_base_url.dart';
import 'package:iwitnez/core/utils/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;

  Future<String?>? _refreshFuture;

  AuthInterceptor(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await TokenStorage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      handler.next(options);
    } catch (e, stackTrace) {
      log('Failed to read access token', error: e, stackTrace: stackTrace);

      handler.reject(DioException(requestOptions: options, error: e));
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;

    if (err.response?.statusCode != 401 ||
        request.extra['auth_retry'] == true) {
      handler.next(err);
      return;
    }

    try {
      final refreshFuture = _refreshFuture ??= _getNewToken();

      final newToken = await refreshFuture;

      if (identical(_refreshFuture, refreshFuture)) {
        _refreshFuture = null;
      }

      if (newToken == null || newToken.isEmpty) {
        await TokenStorage.clearTokens();
        handler.next(err);
        return;
      }

      request.extra['auth_retry'] = true;
      request.headers['Authorization'] = 'Bearer $newToken';

      final response = await _dio.fetch<dynamic>(request);

      handler.resolve(response);
    } catch (e, stackTrace) {
      _refreshFuture = null;

      log(
        'Token refresh or request retry failed',
        error: e,
        stackTrace: stackTrace,
      );

      handler.next(err);
    }
  }

  Future<String?> _getNewToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiBaseUrl.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await refreshDio.post<dynamic>(
        ApiEndPoints.refreshToken,
        data: {'refresh': refreshToken},
      );

      final data = response.data;

      if (response.statusCode != 200 || data is! Map<String, dynamic>) {
        return null;
      }

      final accessToken = data['access'];

      if (accessToken is! String || accessToken.isEmpty) {
        return null;
      }

      await TokenStorage.saveAccessToken(accessToken);

      final newRefreshToken = data['refresh'];

      if (newRefreshToken is String && newRefreshToken.isNotEmpty) {
        await TokenStorage.saveRefreshToken(newRefreshToken);
      }

      return accessToken;
    } on DioException catch (e, stackTrace) {
      log(
        'Refresh API failed: ${e.response?.statusCode}',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    } catch (e, stackTrace) {
      log('Unexpected token refresh error', error: e, stackTrace: stackTrace);

      return null;
    }
  }
}
