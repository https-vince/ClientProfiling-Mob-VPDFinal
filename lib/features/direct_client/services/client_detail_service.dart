import '../../../core/network/api_client.dart';
import '../models/client_detail_data.dart';

class ClientDetailService {
  final ApiClient _apiClient;

  ClientDetailService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ClientDetailData> fetchData(Map<String, String> client) async {
    final clientId = _asInt(client['clientId']);
    final shopId = _asInt(client['shopId']);

    // shop-products may or may not support filters server-side.
    final productsFuture = _tryFetchFiltered(
      preferredPath: '/shop-products',
      clientId: clientId,
      shopId: shopId,
    );
    // availed-services contract is paginated list under data[].
    final servicesFuture = _tryFetchPaginated(preferredPath: '/availed-services');

    final productsRaw = await productsFuture;
    final servicesRaw = await servicesFuture;

    final filteredProducts = productsRaw.where((item) {
      return _matchesProductByClientOrShop(
        item,
        clientId: clientId,
        shopId: shopId,
      );
    }).toList();

    final products = filteredProducts.map((item) {
      // Try to get model name from nested product relationship
      final product = item['product'] as Map<String, dynamic>?;
      final modelName = _firstString(product, const [
            'modelname',
            'model_name',
            'name',
          ]) ??
          _firstString(item, const [
            'modelname',
            'model_name',
            'product_model',
            'model',
            'name',
          ]) ??
          '-';

      // Try to get purchase order from various possible locations
      final purchaseOrder = _firstString(item, const [
            'purchase_order',
            'purchase_order_number',
            'po_number',
            'purchaseOrder',
            'po',
          ]) ??
          'To Follow';

      return <String, String>{
        'modelName': modelName,
        'purchaseOrder': purchaseOrder,
      };
    }).toList();

    final filteredServices = _applyClientFilter(servicesRaw, clientId, shopId);

    final services = filteredServices.map((item) {
      // Backend returns snake_case relation key: service_type
      final serviceTypeObj =
          (item['service_type'] ?? item['serviceType']) as Map<String, dynamic>?;
      final serviceTypeName = _firstString(serviceTypeObj, const [
            'setypename',
            'name',
            'type',
          ]) ??
          _firstString(item, const ['service_type_name']) ??
          _firstString(item, const ['service_type_id']) ??
          '-';

      return <String, String>{
        'reportNo': _firstString(item, const [
              'control_number',
              'service_order_report_no',
              'report_no',
              'service_report_no',
              'service_order_no',
              'id',
            ]) ??
            'N/A',
        'serviceType': serviceTypeName,
      };
    }).toList();

    return ClientDetailData(
      shopDetails: client,
      products: products,
      services: services,
      totalProducts: products.length,
      currentProductPage: 1,
      productsPerPage: 5,
    );
  }

  Future<List<Map<String, dynamic>>> _tryFetchFiltered({
    required String preferredPath,
    required int? clientId,
    required int? shopId,
  }) async {
    try {
      // Build query string with filters.
      final filters = <String>[];
      if (clientId != null) filters.add('client_id=$clientId');
      if (shopId != null) filters.add('shop_id=$shopId');
      
      final queryString = filters.isNotEmpty ? '&${filters.join('&')}' : '';
      final url = '$preferredPath?per_page=100&page=1$queryString';
      
      final firstPageResponse = await _apiClient.get(
        url,
        requiresAuth: true,
      );

      final allItems = <Map<String, dynamic>>[];
      final firstPayload = firstPageResponse.data;
      allItems.addAll(_extractMapItems(firstPayload));

      if (firstPayload is! Map<String, dynamic>) {
        return _applyClientFilter(allItems, clientId, shopId);
      }

      final lastPage =
          int.tryParse((firstPayload['last_page'] ?? '1').toString()) ?? 1;

      if (lastPage <= 1) {
        return _applyClientFilter(allItems, clientId, shopId);
      }

      // Fetch remaining pages with same filters.
      final remainingRequests = <Future<dynamic>>[];
      for (var page = 2; page <= lastPage; page++) {
        remainingRequests.add(
          _apiClient.get(
            '$preferredPath?per_page=100&page=$page$queryString',
            requiresAuth: true,
          ),
        );
      }

      final remainingResponses = await Future.wait(remainingRequests);
      for (final response in remainingResponses) {
        allItems.addAll(_extractMapItems(response.data));
      }

      return _applyClientFilter(allItems, clientId, shopId);
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  /// Fetch all paginated data without filters (for availed-services, etc.)
  Future<List<Map<String, dynamic>>> _tryFetchPaginated({
    required String preferredPath,
  }) async {
    try {
      final url = '$preferredPath?per_page=100&page=1';
      
      final firstPageResponse = await _apiClient.get(
        url,
        requiresAuth: true,
      );

      final allItems = <Map<String, dynamic>>[];
      final firstPayload = firstPageResponse.data;
      allItems.addAll(_extractMapItems(firstPayload));

      if (firstPayload is! Map<String, dynamic>) {
        return allItems;
      }

      final lastPage =
          int.tryParse((firstPayload['last_page'] ?? '1').toString()) ?? 1;

      if (lastPage <= 1) {
        return allItems;
      }

      // Fetch remaining pages.
      final remainingRequests = <Future<dynamic>>[];
      for (var page = 2; page <= lastPage; page++) {
        remainingRequests.add(
          _apiClient.get(
            '$preferredPath?per_page=100&page=$page',
            requiresAuth: true,
          ),
        );
      }

      final remainingResponses = await Future.wait(remainingRequests);
      for (final response in remainingResponses) {
        allItems.addAll(_extractMapItems(response.data));
      }

      return allItems;
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  List<Map<String, dynamic>> _extractMapItems(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
    }

    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }

    return const [];
  }

  /// Fallback client-side filtering in case API doesn't support query parameters.
  List<Map<String, dynamic>> _applyClientFilter(
    List<Map<String, dynamic>> items,
    int? clientId,
    int? shopId,
  ) {
    if (clientId == null && shopId == null) {
      return items;
    }

    return items.where((item) {
      final itemClientId = _firstInt(item, const ['client_id', 'clientid']);
      final itemShopId = _firstInt(item, const ['shop_id', 'shopid']);

      final sameClient = clientId != null && itemClientId == clientId;
      final sameShop = shopId != null && itemShopId == shopId;

      return sameClient || sameShop;
    }).toList();
  }

  bool _matchesProductByClientOrShop(
    Map<String, dynamic> item, {
    required int? clientId,
    required int? shopId,
  }) {
    if (clientId == null && shopId == null) {
      return true;
    }

    final topLevelClientId = _firstInt(item, const ['client_id', 'clientid']);
    final topLevelShopId = _firstInt(item, const ['shop_id', 'shopid']);

    final shop = item['shop'] as Map<String, dynamic>?;
    final shopClientId = _firstInt(shop, const ['client_id', 'clientid']);
    final nestedShopId = _firstInt(shop, const ['id']);

    final product = item['product'] as Map<String, dynamic>?;
    final productClientId = _firstInt(product, const ['client_id', 'clientid']);

    final clientMatches = clientId != null &&
        (topLevelClientId == clientId ||
            shopClientId == clientId ||
            productClientId == clientId);

    final shopMatches = shopId != null &&
        (topLevelShopId == shopId || nestedShopId == shopId);

    return clientMatches || shopMatches;
  }

  int? _asInt(String? value) {
    return int.tryParse((value ?? '').trim());
  }

  int? _firstInt(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) {
      return null;
    }

    for (final key in keys) {
      final value = source[key];
      final parsed = int.tryParse((value ?? '').toString());
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  String? _firstString(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) {
      return null;
    }

    for (final key in keys) {
      final value = source[key];
      if (value is Map<String, dynamic>) {
        // If value is a nested map, try to find a name-like field.
        final name = value['name']?.toString().trim() ??
                     value['modelname']?.toString().trim();
        if (name != null && name.isNotEmpty) {
          return name;
        }
      } else {
        final normalized = value?.toString().trim() ?? '';
        if (normalized.isNotEmpty) {
          return normalized;
        }
      }
    }

    return null;
  }

}
