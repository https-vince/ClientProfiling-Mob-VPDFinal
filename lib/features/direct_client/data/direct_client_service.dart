import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import 'direct_client_data.dart';

class DirectClientService {
  final ApiClient _apiClient;

  DirectClientService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<DirectClientData> fetchData() async {
    final summaryFuture = _apiClient.get(
      ApiConfig.dashboardSummaryPath,
      requiresAuth: true,
    );
    final clientsFuture = _fetchPaginated('/clients');
    final shopsFuture = _fetchPaginated('/shops');

    final summaryResponse = await summaryFuture;
    final clients = await clientsFuture;
    final shops = await shopsFuture;

    final summary = summaryResponse.data is Map<String, dynamic>
        ? summaryResponse.data as Map<String, dynamic>
        : <String, dynamic>{};

    final shopById = <int, Map<String, dynamic>>{};
    for (final shop in shops) {
      final id = int.tryParse((shop['id'] ?? '').toString());
      if (id != null) {
        shopById[id] = shop;
      }
    }

    final mappedClients = clients.map((client) {
      final shopId = int.tryParse((client['shop_id'] ?? '').toString());
      final shop = shopId != null ? shopById[shopId] : null;

      final first = (client['cfirstname'] ?? '').toString().trim();
      final middle = (client['cmiddlename'] ?? '').toString().trim();
      final last = (client['csurname'] ?? '').toString().trim();
      final fullNameParts =
          [first, middle, last].where((value) => value.isNotEmpty).toList();
      final fullName = fullNameParts.isEmpty ? '-' : fullNameParts.join(' ');

      return <String, String>{
        'shop': (shop?['shopname'] ?? 'No Shop').toString(),
        'name': fullName,
        'address': (client['address'] ?? '-').toString(),
        'pinLocation': (shop?['pin_location'] ?? '-').toString(),
        'googleMaps': (shop?['location_link'] ?? '-').toString(),
        'branchType': (shop?['shop_type_id'] ?? '-').toString(),
        'contactPerson': (shop?['scontactperson'] ?? '-').toString(),
        'contactEmail': (shop?['semailaddress'] ?? '-').toString(),
        'contactNo': (shop?['scontactnum'] ?? '-').toString(),
        'viberNo': (shop?['svibernum'] ?? '-').toString(),
      };
    }).toList();

    final overallOwner =
        int.tryParse((summary['total_clients'] ?? '').toString()) ??
            clients.length;
    final overallCoOwner = clients
        .where(
          (c) => (c['clientcoowner'] ?? '').toString().trim().isNotEmpty,
        )
        .length;
    final overallShops =
        int.tryParse((summary['total_shops'] ?? '').toString()) ?? shops.length;
    final soldProducts =
        int.tryParse((summary['total_sold_products'] ?? '').toString()) ?? 0;
    final successfulService =
        int.tryParse((summary['total_services'] ?? '').toString()) ?? 0;

    return DirectClientData(
      overallOwner: overallOwner,
      overallCoOwner: overallCoOwner,
      overallShops: overallShops,
      soldProducts: soldProducts,
      successfulService: successfulService,
      clients: mappedClients,
    );
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
}
