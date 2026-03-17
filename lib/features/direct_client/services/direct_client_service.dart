import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../models/direct_client_data.dart';

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
    final shopsByClientId = <int, List<Map<String, dynamic>>>{};
    for (final shop in shops) {
      final id = _firstInt(shop, const ['id', 'shop_id', 'shopid']);
      if (id != null) {
        shopById[id] = shop;
      }

      final clientId = _firstInt(shop, const ['client_id', 'clientid']);
      if (clientId != null) {
        shopsByClientId.putIfAbsent(clientId, () => <Map<String, dynamic>>[]);
        shopsByClientId[clientId]!.add(shop);
      }
    }

    final mappedClients = clients.map((client) {
      final shopId = _firstInt(client, const ['shop_id', 'shopid', 'id_shop']);
      final clientId = _firstInt(client, const ['id', 'client_id']);
      final relatedShop = _extractRelatedShop(client);
      final matchedShopByClient =
          clientId != null ? _pickPrimaryShop(shopsByClientId[clientId]) : null;
      final shop = relatedShop ??
          (shopId != null ? shopById[shopId] : null) ??
          matchedShopByClient;

      final first = (client['cfirstname'] ?? '').toString().trim();
      final middle = (client['cmiddlename'] ?? '').toString().trim();
      final last = (client['csurname'] ?? '').toString().trim();
      final fullNameParts =
          [first, middle, last].where((value) => value.isNotEmpty).toList();
      final fullName = fullNameParts.isEmpty ? '-' : fullNameParts.join(' ');

      final shopName = _firstString(
            shop,
            const ['shopname', 'shop_name', 'name', 'sname'],
          ) ??
          _firstString(
            client,
            const ['shopname', 'shop_name', 'name_shop', 'sname'],
          ) ??
          'No Shop';

      return <String, String>{
        'clientId':
            (clientId ?? _firstInt(client, const ['id']))?.toString() ?? '',
        'shopId': (shopId ?? _firstInt(shop, const ['id']))?.toString() ?? '',
        'shop': shopName,
        'name': fullName,
        'address': _firstString(client, const ['address']) ?? '-',
        'pinLocation':
            _firstString(shop, const ['pin_location', 'pinLocation']) ?? '-',
        'googleMaps':
            _firstString(shop, const ['location_link', 'google_maps']) ?? '-',
        'branchType':
            _firstString(shop, const ['shop_type_id', 'branch_type']) ?? '-',
        'contactPerson': _firstString(
              shop,
              const ['scontactperson', 'contact_person', 'contactPerson'],
            ) ??
            '-',
        'contactEmail': _firstString(
              shop,
              const ['semailaddress', 'contact_email', 'email'],
            ) ??
            '-',
        'contactNo': _firstString(
              shop,
              const ['scontactnum', 'contact_no', 'contact_number'],
            ) ??
            '-',
        'viberNo':
            _firstString(shop, const ['svibernum', 'viber_no', 'viber']) ?? '-',
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
      final normalized = value?.toString().trim() ?? '';
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractRelatedShop(Map<String, dynamic> client) {
    final direct = client['shop'];
    if (direct is Map<String, dynamic>) {
      return direct;
    }

    final shops = client['shops'];
    if (shops is List &&
        shops.isNotEmpty &&
        shops.first is Map<String, dynamic>) {
      return shops.first as Map<String, dynamic>;
    }

    return null;
  }

  Map<String, dynamic>? _pickPrimaryShop(List<Map<String, dynamic>>? shops) {
    if (shops == null || shops.isEmpty) {
      return null;
    }

    final sorted = List<Map<String, dynamic>>.from(shops)
      ..sort((a, b) {
        final aId = _firstInt(a, const ['id']) ?? 0;
        final bId = _firstInt(b, const ['id']) ?? 0;
        return bId.compareTo(aId);
      });

    return sorted.first;
  }
}
