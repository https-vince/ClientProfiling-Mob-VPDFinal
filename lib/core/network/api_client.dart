import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({Dio? dio, TokenStorage? tokenStorage})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                headers: const <String, String>{
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    CancelToken? cancelToken,
  }) {
    return _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    CancelToken? cancelToken,
  }) {
    return _request(
      method: 'POST',
      path: path,
      data: data,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    CancelToken? cancelToken,
  }) {
    return _request(
      method: 'PUT',
      path: path,
      data: data,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    CancelToken? cancelToken,
  }) {
    return _request(
      method: 'PATCH',
      path: path,
      data: data,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    CancelToken? cancelToken,
  }) {
    return _request(
      method: 'DELETE',
      path: path,
      data: data,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> _request({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required bool requiresAuth,
    CancelToken? cancelToken,
  }) async {
    try {
      final headers = <String, dynamic>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (requiresAuth) {
        final token = await _tokenStorage.readToken();
        if (token == null || token.trim().isEmpty) {
          throw const ApiException(
            message: 'Unauthorized (401). Missing token.',
            statusCode: 401,
          );
        }
        headers['Authorization'] = 'Bearer ${token.trim()}';
      }

      return await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method, headers: headers),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        throw const ApiException(message: 'Request cancelled.');
      }

      final statusCode = e.response?.statusCode;
      final payload = e.response?.data;
      throw ApiException.fromResponse(statusCode: statusCode, payload: payload);
    }
  }
}
