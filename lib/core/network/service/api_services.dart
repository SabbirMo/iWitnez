import 'package:dio/dio.dart';
import 'package:iwitnez/core/network/dio_client/dio_client.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';

class ApiServices {
  ApiServices();

  Dio _getDio(bool requireAuth) {
    return requireAuth ? DioClient.instance : DioClient.instanceWithoutAuth;
  }

  //common error handler and API response handler
  Future<Response<T>> _request<T>(
    Future<Response<T>> Function(Dio dio) request, {
    bool requireAuth = true,
  }) async {
    try {
      final dio = _getDio(requireAuth);
      return await request(dio);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = true,
  }) async {
    return _request<T>(
      (dio) => dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      requireAuth: requireAuth,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = true,
  }) async {
    return _request<T>(
      (dio) => dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      requireAuth: requireAuth,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      (dio) => dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      requireAuth: requireAuth,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      (dio) => dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      requireAuth: requireAuth,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      (dio) => dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      requireAuth: requireAuth,
    );
  }
}
