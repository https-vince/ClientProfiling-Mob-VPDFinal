import '../../../core/network/api_client.dart';

class ResellersService {
  final ApiClient _apiClient;

  ResellersService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<Map<String, String>>> fetchResellers() async {
    final rows = await _fetchPaginated('/resellers');

    return rows.map((item) {
      return <String, String>{
        'id': (item['id'] ?? '').toString(),
        'companyName': _firstString(item, const ['company_name', 'companyName']) ?? '-',
        'email': _firstString(item, const ['email']) ?? '-',
        'phoneNumber': _firstString(item, const ['phone', 'phone_number']) ?? '-',
        'address': _firstString(item, const ['address']) ?? '-',
        'notes': _firstString(item, const ['notes']) ?? '-',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchPaginated(String path) async {
    final firstPageResponse = await _apiClient.get(
      '$path?per_page=100&page=1',
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

    final remainingRequests = <Future<dynamic>>[];
    for (var page = 2; page <= lastPage; page++) {
      remainingRequests.add(
        _apiClient.get('$path?per_page=100&page=$page', requiresAuth: true),
      );
    }

    final remainingResponses = await Future.wait(remainingRequests);
    for (final response in remainingResponses) {
      allItems.addAll(_extractMapItems(response.data));
    }

    return allItems;
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
}
