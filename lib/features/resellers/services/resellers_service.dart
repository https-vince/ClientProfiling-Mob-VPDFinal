import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/models/paginated_response.dart';
import '../../../core/network/paginated_api_service.dart';

class ResellersSummary {
  final int overallResellers;
  final int soldProducts;

  const ResellersSummary({
    required this.overallResellers,
    required this.soldProducts,
  });
}

class ResellersService {
  final ApiClient _apiClient;
  final PaginatedApiService _paginatedApiService;

  ResellersService({ApiClient? apiClient})
      : this._internal(apiClient ?? ApiClient());

  ResellersService._internal(this._apiClient)
      : _paginatedApiService = PaginatedApiService(apiClient: _apiClient);

  Future<PaginatedResponse<Map<String, String>>> fetchResellersPage({
    int page = 1,
    int perPage = 20,
    String? q,
    CancelToken? cancelToken,
  }) {
    return _paginatedApiService.getPaginated<Map<String, String>>(
      path: '/resellers',
      page: page,
      perPage: perPage,
      q: q,
      cancelToken: cancelToken,
      mapper: (item) => _mapReseller(item),
    );
  }

  Future<List<Map<String, String>>> fetchResellers() async {
    final response = await fetchResellersPage(page: 1, perPage: 20);
    return response.data;
  }

  Future<ResellersSummary> fetchSummary() async {
    final summaryResponse = await _apiClient.get(
      ApiConfig.dashboardSummaryPath,
      requiresAuth: true,
    );

    final payload = summaryResponse.data;
    final summary = payload is Map<String, dynamic>
        ? payload
        : <String, dynamic>{};

    final overallResellers =
        _firstInt(summary, const ['total_resellers', 'overall_resellers']) ?? 0;
    final soldProducts = _firstInt(
          summary,
          const ['total_sold_products', 'sold_products'],
        ) ??
        0;

    return ResellersSummary(
      overallResellers: overallResellers,
      soldProducts: soldProducts,
    );
  }

  /// Add a new reseller to the backend
  Future<void> addReseller({
    required String companyName,
    required String address,
    required String email,
    required String phoneNumber,
  }) async {
    final payload = {
      'company_name': companyName,
      'address': address,
      'email': email,
      'phone': phoneNumber,
    };
    await _apiClient.post('/resellers', data: payload, requiresAuth: true);
  }

  Map<String, String> _mapReseller(Map<String, dynamic> item) {
    return <String, String>{
      'id': (item['id'] ?? '').toString(),
      'companyName': _firstString(item, const ['company_name', 'companyName']) ?? '-',
      'email': _firstString(item, const ['email']) ?? '-',
      'phoneNumber': _firstString(item, const ['phone', 'phone_number']) ?? '-',
      'address': _firstString(item, const ['address']) ?? '-',
      'notes': _firstString(item, const ['notes']) ?? '-',
    };
  }

  String? _firstString(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) {
      return null;
    }

    for (final key in keys) {
      final value = source[key];
      final normalized = value?.toString().trim() ?? '';
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    return null;
  }

  int? _firstInt(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) {
      return null;
    }

    for (final key in keys) {
      final parsed = int.tryParse((source[key] ?? '').toString());
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }
}
