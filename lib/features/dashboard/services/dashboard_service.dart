import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../models/dashboard_summary.dart';

class DashboardService {
  static DashboardSummary? _cachedSummary;
  static List<Map<String, dynamic>>? _cachedShopProducts;
  static final Map<String, List<int>> _cachedMonthlySeries = {};

  final ApiClient _apiClient;

  DashboardService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  DashboardSummary? get cachedSummary => _cachedSummary;

  List<int>? cachedSoldProductMonthly({
    required int year,
    int months = 4,
  }) {
    return _cachedMonthlySeries['$year-$months'];
  }

  Future<DashboardSummary> fetchSummary() async {
    final response = await _apiClient.get(
      ApiConfig.dashboardSummaryPath,
      requiresAuth: true,
    );

    final payload = response.data;
    final data =
        payload is Map<String, dynamic> ? payload : <String, dynamic>{};

    final totalClients =
        int.tryParse((data['total_clients'] ?? '0').toString()) ?? 0;
    final totalSoldProducts =
        int.tryParse((data['total_sold_products'] ?? '0').toString()) ?? 0;
    final totalServices =
        int.tryParse((data['total_services'] ?? '0').toString()) ?? 0;
    final totalShops =
        int.tryParse((data['total_shops'] ?? '0').toString()) ?? 0;

    final summary = DashboardSummary(
      totalClients: totalClients,
      totalSoldProducts: totalSoldProducts,
      totalServices: totalServices,
      totalShops: totalShops,
    );

    _cachedSummary = summary;
    return summary;
  }

  Future<List<int>> fetchSoldProductMonthly({
    required int year,
    int months = 4,
  }) async {
    final key = '$year-$months';
    final cached = _cachedMonthlySeries[key];
    if (cached != null) {
      return cached;
    }

    final products = await _fetchAllShopProducts();
    final totals = List<int>.filled(months, 0);

    for (final item in products) {
      final createdAtRaw = item['created_at']?.toString();
      if (createdAtRaw == null || createdAtRaw.isEmpty) {
        continue;
      }

      final createdAt = DateTime.tryParse(createdAtRaw);
      if (createdAt == null || createdAt.year != year) {
        continue;
      }

      final monthIndex = createdAt.month - 1;
      if (monthIndex < 0 || monthIndex >= months) {
        continue;
      }

      final quantity = int.tryParse((item['quantity'] ?? '0').toString()) ?? 0;
      totals[monthIndex] += quantity;
    }

    _cachedMonthlySeries[key] = totals;
    return totals;
  }

  Future<List<Map<String, dynamic>>> _fetchAllShopProducts() async {
    final cached = _cachedShopProducts;
    if (cached != null) {
      return cached;
    }

    final firstPageResponse = await _apiClient.get(
      '/shop-products?per_page=100&page=1',
      requiresAuth: true,
    );

    final firstPayload = firstPageResponse.data;
    final allItems = <Map<String, dynamic>>[];
    allItems.addAll(_extractMapItems(firstPayload));

    if (firstPayload is! Map<String, dynamic>) {
      _cachedShopProducts = allItems;
      return allItems;
    }

    final lastPage =
        int.tryParse((firstPayload['last_page'] ?? '1').toString()) ?? 1;
    if (lastPage > 1) {
      final remainingPageRequests = <Future<dynamic>>[];
      for (var page = 2; page <= lastPage; page++) {
        remainingPageRequests.add(
          _apiClient.get(
            '/shop-products?per_page=100&page=$page',
            requiresAuth: true,
          ),
        );
      }

      final remainingResponses = await Future.wait(remainingPageRequests);
      for (final response in remainingResponses) {
        allItems.addAll(_extractMapItems(response.data));
      }
    }

    _cachedShopProducts = allItems;
    return allItems;
  }

  List<Map<String, dynamic>> _extractMapItems(dynamic payload) {
    final items = _extractDataList(payload);
    final maps = <Map<String, dynamic>>[];
    for (final item in items) {
      if (item is Map<String, dynamic>) {
        maps.add(item);
      }
    }
    return maps;
  }

  List<dynamic> _extractDataList(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) {
        return data;
      }
    }

    if (payload is List) {
      return payload;
    }

    return const [];
  }
}
