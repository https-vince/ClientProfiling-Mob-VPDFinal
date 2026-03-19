import 'package:dio/dio.dart';

import 'api_client.dart';
import 'models/paginated_response.dart';

class PaginatedApiService {
  final ApiClient _apiClient;

  PaginatedApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<PaginatedResponse<T>> getPaginated<T>({
    required String path,
    required T Function(Map<String, dynamic> item) mapper,
    int page = 1,
    int perPage = 20,
    String? q,
    bool requiresAuth = true,
    Map<String, dynamic>? extraQuery,
    CancelToken? cancelToken,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      ...?extraQuery,
    };

    final trimmedQuery = (q ?? '').trim();
    if (trimmedQuery.isNotEmpty) {
      query['q'] = trimmedQuery;
    }

    final response = await _apiClient.get(
      path,
      queryParameters: query,
      cancelToken: cancelToken,
      requiresAuth: requiresAuth,
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      return PaginatedResponse<T>.fromJson(payload, mapper);
    }

    return PaginatedResponse<T>(
      currentPage: 1,
      lastPage: 1,
      total: 0,
      nextPageUrl: null,
      data: <T>[],
    );
  }
}
