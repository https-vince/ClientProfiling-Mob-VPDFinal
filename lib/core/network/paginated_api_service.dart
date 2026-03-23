import 'api_client.dart';

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final List<T> data;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  bool get isEmpty => data.isEmpty;

  factory PaginatedResponse.fromLaravelJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) fromJson,
  ) {
    final rows = json['data'];
    final rawList = rows is List ? rows.whereType<Map<String, dynamic>>().toList() : const <Map<String, dynamic>>[];

    return PaginatedResponse<T>(
      data: rawList.map(fromJson).toList(),
      currentPage: _parseInt(json['current_page']) ?? 1,
      perPage: _parseInt(json['per_page']) ?? rawList.length,
      total: _parseInt(json['total']) ?? rawList.length,
      lastPage: _parseInt(json['last_page']) ?? 1,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    return int.tryParse(value.toString());
  }
}

class PaginatedApiService {
  PaginatedApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<PaginatedResponse<T>> fetchPage<T>({
    required String path,
    required T Function(Map<String, dynamic> item) fromJson,
    int page = 1,
    int perPage = 10,
    String? q,
    bool requiresAuth = true,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      if ((q ?? '').trim().isNotEmpty) 'q': q!.trim(),
    };

    final response = await _apiClient.get(
      path,
      queryParameters: query,
      requiresAuth: requiresAuth,
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      return PaginatedResponse<T>.fromLaravelJson(payload, fromJson);
    }

    return PaginatedResponse<T>(
      data: <T>[],
      currentPage: 1,
      perPage: 10,
      total: 0,
      lastPage: 1,
    );
  }
}
