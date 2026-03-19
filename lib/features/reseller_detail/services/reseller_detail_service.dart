import '../../../core/network/api_client.dart';
import '../models/reseller_detail_data.dart';

class ResellerDetailService {
  final ApiClient _apiClient;

  ResellerDetailService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ResellerDetailData> fetchDetail(Map<String, String> reseller) async {
    final resellerId = int.tryParse((reseller['id'] ?? '').trim());

    final detail = await _fetchReseller(resellerId, fallback: reseller);
    final products = await _fetchResellerProducts(resellerId);

    return ResellerDetailData(
      reseller: detail,
      products: products,
    );
  }

  Future<void> updateReseller({
    required String resellerId,
    required String companyName,
    required String email,
    required String phoneNumber,
    required String address,
  }) async {
    final payload = {
      'company_name': companyName,
      'email': email,
      'phone': phoneNumber,
      'address': address,
    };

    try {
      await _apiClient.put(
        '/resellers/$resellerId',
        data: payload,
        requiresAuth: true,
      );
    } catch (_) {
      await _apiClient.patch(
        '/resellers/$resellerId',
        data: payload,
        requiresAuth: true,
      );
    }
  }

  Future<void> deleteReseller(String resellerId) async {
    await _apiClient.delete('/resellers/$resellerId', requiresAuth: true);
  }

  Future<void> addProduct({
    required String resellerId,
    required String modelName,
    required String purchaseOrder,
  }) async {
    final payload = {
      'reseller_id': int.tryParse(resellerId) ?? resellerId,
      'model_name': modelName,
      'purchase_order': purchaseOrder,
    };

    await _apiClient.post('/shop-products', data: payload, requiresAuth: true);
  }

  Future<Map<String, String>> _fetchReseller(
    int? resellerId, {
    required Map<String, String> fallback,
  }) async {
    if (resellerId == null) {
      return fallback;
    }

    try {
      final response = await _apiClient.get('/resellers/$resellerId', requiresAuth: true);
      final payload = response.data;

      Map<String, dynamic>? item;
      if (payload is Map<String, dynamic>) {
        final data = payload['data'];
        if (data is Map<String, dynamic>) {
          item = data;
        } else {
          item = payload;
        }
      }

      if (item == null) {
        return fallback;
      }

      return <String, String>{
        'id': (item['id'] ?? fallback['id'] ?? '').toString(),
        'companyName': _firstString(item, const ['company_name', 'companyName']) ??
            fallback['companyName'] ??
            '-',
        'email': _firstString(item, const ['email']) ?? fallback['email'] ?? '-',
        'phoneNumber': _firstString(item, const ['phone', 'phone_number']) ??
            fallback['phoneNumber'] ??
            '-',
        'address': _firstString(item, const ['address']) ?? fallback['address'] ?? '-',
      };
    } catch (_) {
      return fallback;
    }
  }

  Future<List<Map<String, String>>> _fetchResellerProducts(int? resellerId) async {
    final items = await _tryFetchProducts(resellerId);

    return items.map((item) {
      final model = _firstString(item, const [
            'model_name',
            'modelname',
            'product_model',
            'name',
          ]) ??
          _firstString(item['product'] as Map<String, dynamic>?, const [
            'model_name',
            'modelname',
            'name',
          ]) ??
          '-';

      final po = _firstString(item, const [
            'purchase_order',
            'purchase_order_number',
            'po_number',
            'po',
          ]) ??
          'To Follow';

      return <String, String>{
        'modelName': model,
        'purchaseOrder': po,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _tryFetchProducts(int? resellerId) async {
    final urls = <String>[
      '/shop-products?per_page=100&page=1${resellerId != null ? '&reseller_id=$resellerId' : ''}',
      '/products?per_page=100&page=1${resellerId != null ? '&reseller_id=$resellerId' : ''}',
    ];

    for (final url in urls) {
      try {
        final firstPageResponse = await _apiClient.get(url, requiresAuth: true);
        final allItems = <Map<String, dynamic>>[];
        final firstPayload = firstPageResponse.data;
        allItems.addAll(_extractMapItems(firstPayload));

        if (firstPayload is Map<String, dynamic>) {
          final lastPage = int.tryParse((firstPayload['last_page'] ?? '1').toString()) ?? 1;
          if (lastPage > 1) {
            final remainingRequests = <Future<dynamic>>[];
            for (var page = 2; page <= lastPage; page++) {
              final pageUrl = url.replaceFirst('page=1', 'page=$page');
              remainingRequests.add(_apiClient.get(pageUrl, requiresAuth: true));
            }
            final remainingResponses = await Future.wait(remainingRequests);
            for (final response in remainingResponses) {
              allItems.addAll(_extractMapItems(response.data));
            }
          }
        }

        if (resellerId == null) {
          return allItems;
        }

        final filtered = allItems.where((item) {
          final topResellerId = _firstInt(item, const ['reseller_id']);
          final shop = item['shop'] as Map<String, dynamic>?;
          final shopResellerId = _firstInt(shop, const ['reseller_id']);
          return topResellerId == resellerId || shopResellerId == resellerId;
        }).toList();

        return filtered;
      } catch (_) {
        continue;
      }
    }

    return const [];
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
      final value = source[key];
      final parsed = int.tryParse((value ?? '').toString());
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }
}
