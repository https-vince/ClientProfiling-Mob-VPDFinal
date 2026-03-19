import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'api_exception.dart';
import 'auth_session.dart';
import 'token_storage.dart';

typedef UnauthorizedCallback = Future<void> Function();

class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient({
    Dio? dio,
    TokenStorage? tokenStorage,
    UnauthorizedCallback? onUnauthorized,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
                headers: const {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ),
        _tokenStorage = tokenStorage ?? const TokenStorage() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requiresAuth'] == true;
          if (requiresAuth) {
            final token = await _tokenStorage.readToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            await _tokenStorage.clearToken();
            AuthSession.triggerLogout();
            if (onUnauthorized != null) {
              await onUnauthorized();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    bool requiresAuth = false,
  }) {
    return _request(() {
      return _dio.post<dynamic>(
        path,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    });
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool requiresAuth = false,
  }) {
    return _request(() {
      return _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    });
  }

  Future<Response<dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
    bool requiresAuth = false,
  }) {
    return _request(() {
      return _dio.put<dynamic>(
        path,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    });
  }

  Future<Response<dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
    bool requiresAuth = false,
  }) {
    return _request(() {
      return _dio.patch<dynamic>(
        path,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    });
  }

  Future<Response<dynamic>> delete(
    String path, {
    Map<String, dynamic>? data,
    bool requiresAuth = false,
  }) {
    return _request(() {
      return _dio.delete<dynamic>(
        path,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    });
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  ApiException _mapDioError(DioException e) {
    if (e.type == DioExceptionType.cancel) {
      return const ApiException(
        message: 'Request cancelled.',
        isCancelled: true,
      );
    }

    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    if (statusCode == 422 && data is Map<String, dynamic>) {
      final errors = <String, String>{};
      final rawErrors = data['errors'];
      if (rawErrors is Map<String, dynamic>) {
        rawErrors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            errors[key] = value.first.toString();
          } else if (value != null) {
            errors[key] = value.toString();
          }
        });
      }

      final message = data['message']?.toString() ?? 'Validation failed.';
      return ApiException(
        message: message,
        statusCode: statusCode,
        fieldErrors: errors,
      );
    }

    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString() ?? 'Request failed.';
      return ApiException(message: message, statusCode: statusCode);
    }

    return ApiException(
      message: e.message ?? 'Network error occurred.',
      statusCode: statusCode,
    );
  }
}
