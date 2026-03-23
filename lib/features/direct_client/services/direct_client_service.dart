import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/direct_client_data.dart';

class DirectClientService {
  final ApiClient _apiClient;

  DirectClientService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<DirectClientData> fetchData() async {
    final summaryFuture = _safeGetMap(ApiConfig.dashboardSummaryPath);
    final clientsFuture = _safeFetchPaginated('/clients');
    final shopsFuture = _safeFetchPaginated('/shops');

    final summary = await summaryFuture;
    final clients = await clientsFuture;
    final shops = await shopsFuture;

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
        'companyName': _firstString(
              client,
              const ['ccompanyname', 'company_name', 'companyName'],
            ) ??
            'N/A',
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
            _firstString(client, const ['cemail', 'email', 'cemailaddress']) ??
            '-',
        'contactNo': _firstString(
              shop,
              const ['scontactnum', 'contact_no', 'contact_number'],
            ) ??
            _firstString(client, const ['cphonenum', 'phonenum', 'phone']) ??
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

  Future<Map<String, dynamic>> fetchClientsPage({
    int page = 1,
    int perPage = 10,
    String q = '',
  }) async {
    final response = await _apiClient.get(
      '/clients',
      queryParameters: <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (q.trim().isNotEmpty) 'q': q.trim(),
      },
      requiresAuth: true,
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return <String, dynamic>{
        'current_page': page,
        'per_page': perPage,
        'total': 0,
        'last_page': 1,
        'data': const <Map<String, String>>[],
      };
    }

    final rows = payload['data'] is List
        ? (payload['data'] as List).whereType<Map<String, dynamic>>().toList()
        : const <Map<String, dynamic>>[];

    final mapped = rows.map((client) {
      final first = (client['cfirstname'] ?? '').toString().trim();
      final middle = (client['cmiddlename'] ?? '').toString().trim();
      final last = (client['csurname'] ?? '').toString().trim();
      final name = [first, middle, last]
          .where((part) => part.isNotEmpty)
          .join(' ')
          .trim();

      final shop = _extractRelatedShop(client);

      return <String, String>{
        'clientId': (_firstInt(client, const ['id', 'client_id']) ?? '').toString(),
        'shopId': (_firstInt(shop, const ['id', 'shop_id']) ?? '').toString(),
        'shop': _firstString(shop, const ['shopname', 'shop_name']) ?? '-',
        'name': name.isEmpty ? '-' : name,
        'address': _firstString(shop, const ['saddress', 'address']) ?? '-',
        'pinLocation': _firstString(shop, const ['pin_location']) ?? '-',
        'googleMaps': _firstString(shop, const ['location_link']) ?? '-',
        'branchType': _firstString(shop, const ['shop_type_id']) ?? '-',
        'contactPerson':
            _firstString(shop, const ['scontactperson']) ?? (name.isEmpty ? '-' : name),
        'contactEmail': _firstString(shop, const ['semailaddress']) ??
            _firstString(client, const ['cemail']) ??
            '-',
        'contactNo': _firstString(shop, const ['scontactnum']) ??
            _firstString(client, const ['cphonenum']) ??
            '-',
        'viberNo': _firstString(shop, const ['svibernum']) ?? '-',
      };
    }).toList();

    return <String, dynamic>{
      'current_page': int.tryParse('${payload['current_page'] ?? page}') ?? page,
      'per_page': int.tryParse('${payload['per_page'] ?? perPage}') ?? perPage,
      'total': int.tryParse('${payload['total'] ?? 0}') ?? 0,
      'last_page': int.tryParse('${payload['last_page'] ?? 1}') ?? 1,
      'data': mapped,
    };
  }

  Future<void> createClient({
    required String firstName,
    required String middleName,
    required String lastName,
    required String companyName,
    required String email,
    required String phone,
    required String notes,
    String clientTypeId = '1',
  }) async {
    final payload = _withoutEmptyValues({
      'cfirstname': firstName,
      'cmiddlename': middleName,
      'csurname': lastName,
      'client_type_id': clientTypeId,
      'ccompanyname': companyName,
      'cemail': email,
      'cphonenum': phone,
      'notes': notes,
    });

    await _apiClient.post('/clients', data: payload, requiresAuth: true);
  }

  Future<Map<String, String>> fetchClientById(String clientId) async {
    final parsedId = int.tryParse(clientId.trim());

    if (parsedId == null) {
      return const <String, String>{};
    }

    try {
      final response = await _apiClient.get('/clients/$parsedId', requiresAuth: true);
      final payload = response.data;

      Map<String, dynamic>? client;
      if (payload is Map<String, dynamic>) {
        final data = payload['data'];
        if (data is Map<String, dynamic>) {
          client = data;
        } else {
          client = payload;
        }
      }

      if (client == null) {
        return const <String, String>{};
      }

      return _mapClientDetail(client);
    } catch (_) {
      try {
        final clients = await _safeFetchPaginated('/clients');
        final matched = clients.firstWhere(
          (item) => _firstInt(item, const ['id', 'client_id']) == parsedId,
          orElse: () => <String, dynamic>{},
        );

        if (matched.isEmpty) {
          return const <String, String>{};
        }

        return _mapClientDetail(matched);
      } catch (_) {
        return const <String, String>{};
      }
    }
  }

  Future<Map<String, String>> getProductById(String productId) async {
    final parsedId = int.tryParse(productId.trim());
    if (parsedId == null) {
      return const <String, String>{};
    }

    try {
      final response = await _apiClient.get('/products/$parsedId', requiresAuth: true);
      final payload = response.data;

      Map<String, dynamic>? product;
      if (payload is Map<String, dynamic>) {
        final data = payload['data'];
        if (data is Map<String, dynamic>) {
          product = data;
        } else {
          product = payload;
        }
      }

      if (product == null) {
        return const <String, String>{};
      }

      final employee = product['employee'] as Map<String, dynamic>?;

      return <String, String>{
        'productId': (_firstInt(product, const ['id', 'product_id']) ?? parsedId).toString(),
        'clientId': (_firstInt(product, const ['client_id']) ?? '').toString(),
        'modelName': _firstString(product, const ['model_name', 'modelname', 'name']) ?? '-',
        'modelCode': _firstString(product, const ['model_code']) ?? '-',
        'uom': _firstString(product, const ['unitsofmeasurement', 'units_of_measurement']) ?? '-',
        'quantity': _firstString(product, const ['quantity', 'qty']) ??
            _firstString(product, const ['unitsofmeasurement', 'units_of_measurement']) ??
            '-',
        'poNumber': _firstString(product, const ['purchase_order', 'po_number']) ?? '-',
        'drNumber': _firstString(product, const ['delivery_receipt', 'dr_number']) ?? '-',
        'contractDate': _firstString(product, const ['contract_date']) ?? '-',
        'deliveryDate': _firstString(product, const ['delivery_date']) ?? '-',
        'installationDate': _firstString(product, const ['installment_date', 'installation_date']) ?? '-',
        'supplierType': _firstString(product, const ['appliance_type']) ?? '-',
        'employeeId': (_firstInt(product, const ['employee_id']) ?? '').toString(),
        'employeeName': _firstString(employee, const ['name', 'firstname']) ??
            (_firstInt(product, const ['employee_id'])?.toString() ?? '-'),
        'serialNumber': _firstString(product, const ['serial_number']) ?? '',
        'notes': _firstString(product, const ['notes']) ?? '',
      };
    } catch (_) {
      return const <String, String>{};
    }
  }

  Future<Map<String, String>> fetchProductById(String productId) async {
    return getProductById(productId);
  }

  Future<void> updateClient({
    required String clientId,
    required String firstName,
    required String middleName,
    required String lastName,
    required String companyName,
    required String email,
    required String phone,
    required String notes,
    String clientTypeId = '1',
  }) async {
    final payload = _withoutEmptyValues({
      'cfirstname': firstName,
      'cmiddlename': middleName,
      'csurname': lastName,
      'client_type_id': clientTypeId,
      'ccompanyname': companyName,
      'cemail': email,
      'cphonenum': phone,
      'notes': notes,
    });

    try {
      await _apiClient.patch('/clients/$clientId', data: payload, requiresAuth: true);
    } catch (_) {
      await _apiClient.put('/clients/$clientId', data: payload, requiresAuth: true);
    }
  }

  Future<void> deleteClient(String clientId) async {
    await _apiClient.delete('/clients/$clientId', requiresAuth: true);
  }

  Future<void> createShop({
    required int? clientId,
    required String shopName,
    required String shopAddress,
    required String? shopType,
    required String pinLocation,
    required String googleMaps,
    required String contactPerson,
    required String contactNo,
    required String viberNo,
    required String contactEmail,
    required String notes,
  }) async {
    if (clientId == null) {
      throw const ApiException(
        message: 'Client id is required to create a shop.',
      );
    }

    final parsedShopTypeId = int.tryParse((shopType ?? '').trim());

    final payload = _withoutEmptyValues({
      'client_id': clientId,
      'shopname': shopName,
      'saddress': shopAddress,
      'shop_type_id': parsedShopTypeId,
      'pin_location': pinLocation,
      'location_link': googleMaps,
      'scontactperson': contactPerson,
      'scontactnum': contactNo,
      'svibernum': viberNo,
      'semailaddress': contactEmail,
      'notes': notes,
    });

    await _apiClient.post('/shops', data: payload, requiresAuth: true);
  }

  Future<void> updateShop({
    required int shopId,
    required int clientId,
    required String shopName,
    required String shopAddress,
    required String viberNo,
    required String contactPerson,
    required String contactNo,
    required String shopTypeId,
    required String contactEmail,
    required String notes,
    required String googleMaps,
    required String pinLocation,
  }) async {
    final parsedShopTypeId = int.tryParse(shopTypeId.trim());

    final payload = _withoutEmptyValues({
      'shopname': shopName,
      'saddress': shopAddress,
      'svibernum': viberNo,
      'scontactperson': contactPerson,
      'scontactnum': contactNo,
      'shop_type_id': parsedShopTypeId,
      'client_id': clientId,
      'semailaddress': contactEmail,
      'notes': notes,
      'location_link': googleMaps,
      'pin_location': pinLocation,
    });

    await _apiClient.put('/shops/$shopId', data: payload, requiresAuth: true);
  }

  Future<Map<String, String>> fetchShopById(String shopId) async {
    final parsedId = int.tryParse(shopId.trim());
    if (parsedId == null) {
      return const <String, String>{};
    }

    try {
      final response = await _apiClient.get('/shops/$parsedId', requiresAuth: true);
      final payload = response.data;

      Map<String, dynamic>? shop;
      if (payload is Map<String, dynamic>) {
        final data = payload['data'];
        if (data is Map<String, dynamic>) {
          shop = data;
        } else {
          shop = payload;
        }
      }

      if (shop == null) {
        return const <String, String>{};
      }

      return <String, String>{
        'shopId': (_firstInt(shop, const ['id', 'shop_id']) ?? parsedId).toString(),
        'clientId': (_firstInt(shop, const ['client_id']) ?? '').toString(),
        'shop': _firstString(shop, const ['shopname', 'shop_name', 'name']) ?? '-',
        'address': _firstString(shop, const ['saddress', 'address']) ?? '-',
        'pinLocation': _firstString(shop, const ['pin_location']) ?? '-',
        'googleMaps': _firstString(shop, const ['location_link']) ?? '-',
        'branchType': _firstString(shop, const ['shop_type_id']) ?? '-',
        'contactPerson': _firstString(shop, const ['scontactperson']) ?? '-',
        'contactEmail': _firstString(shop, const ['semailaddress']) ?? '-',
        'contactNo': _firstString(shop, const ['scontactnum']) ?? '-',
        'viberNo': _firstString(shop, const ['svibernum']) ?? '-',
        'notes': _firstString(shop, const ['notes']) ?? '',
      };
    } catch (_) {
      return const <String, String>{};
    }
  }

  Future<void> deleteShop(int shopId) async {
    await _apiClient.delete('/shops/$shopId', requiresAuth: true);
  }

  Future<List<Map<String, String>>> fetchEmployees() async {
    final items = await _safeFetchPaginated('/employees');

    return items.map((item) {
      final id = _firstInt(item, const ['id', 'employee_id'])?.toString() ?? '';
      final firstName = _firstString(item, const ['firstname', 'first_name']) ?? '';
      final middleName = _firstString(item, const ['middlename', 'middle_name']) ?? '';
      final lastName = _firstString(item, const ['surname', 'last_name', 'lastname']) ?? '';
      final fullName = [firstName, middleName, lastName]
          .where((part) => part.trim().isNotEmpty)
          .join(' ')
          .trim();

      return <String, String>{
        'id': id,
        'name': fullName.isEmpty
            ? (_firstString(item, const ['name', 'employee_name']) ?? 'Employee #$id')
            : fullName,
      };
    }).where((item) => item['id']!.isNotEmpty).toList();
  }

  Future<List<Map<String, String>>> fetchShopsByClientId(String clientId) async {
    final parsedId = int.tryParse(clientId.trim());
    if (parsedId == null) {
      return const <Map<String, String>>[];
    }

    final items = await _safeFetchPaginated('/shops');
    final filtered = items.where((item) {
      final itemClientId = _firstInt(item, const ['client_id', 'clientid']);
      return itemClientId == parsedId;
    }).toList();

    return filtered.map((shop) {
      return <String, String>{
        'shopId': (_firstInt(shop, const ['id', 'shop_id']) ?? '').toString(),
        'shop': _firstString(shop, const ['shopname', 'shop_name', 'name']) ?? '-',
        'contactPerson':
            _firstString(shop, const ['scontactperson', 'contact_person']) ?? '-',
        'address': _firstString(shop, const ['saddress', 'address']) ?? '-',
        'contactEmail': _firstString(shop, const ['semailaddress', 'email']) ?? '-',
        'contactNo': _firstString(shop, const ['scontactnum', 'contact_no']) ?? '-',
      };
    }).toList();
  }

  Future<void> createProduct({
    required int? clientId,
    required int? shopId,
    required String modelName,
    required String unitsOfMeasurement,
    required String modelCode,
    required String applianceType,
    required int? employeeId,
    required String quantity,
    required String purchaseOrder,
    required String serialNumber,
    required DateTime? contractDate,
    required DateTime? deliveryDate,
    required DateTime? installationDate,
    required String laborPlan,
    required String notes,
  }) async {
    final payload = _withoutEmptyValues({
      'model_name': modelName,
      'unitsofmeasurement': unitsOfMeasurement,
      'contract_date': _formatDate(contractDate),
      'delivery_date': _formatDate(deliveryDate),
      'installment_date': _formatDate(installationDate),
      'notes': notes,
      'client_id': clientId,
      'model_code': modelCode,
      'appliance_type': applianceType,
      'employee_id': employeeId,
    });

    await _apiClient.post('/products', data: payload, requiresAuth: true);
  }

  Future<void> createService({
    required int? clientId,
    required int? shopId,
    required String serviceTypeId,
    required DateTime? serviceDate,
    required int? employeeId,
    required String eventId,
    required String controlNumber,
    required String serialNumberId,
    required String image,
    required String notes,
  }) async {
    final parsedServiceTypeId = serviceTypeId.trim();
    final parsedSerialNumberId = serialNumberId.trim();

    final payload = _withoutEmptyValues({
      'service_date': _formatDate(serviceDate),
      'service_type_id': parsedServiceTypeId,
      'client_id': clientId,
      'employee_id': employeeId,
      'shop_id': shopId,
      'event_id': int.tryParse(eventId.trim()),
      'control_number': controlNumber,
      'serial_number_id': parsedSerialNumberId,
      'image': image,
      'notes': notes,
    });

    await _apiClient.post('/availed-services', data: payload, requiresAuth: true);
  }

  Future<void> updateService({
    required int serviceId,
    required String serviceTypeId,
    required String serviceDate,
    required int clientId,
    int? employeeId,
    int? shopId,
    String? notes,
    String? eventId,
    String? serialNumberId,
    String? controlNumber,
    String? image,
  }) async {
    final payload = _withoutEmptyValues({
      'service_type_id': serviceTypeId,
      'service_date': serviceDate,
      'client_id': clientId,
      'employee_id': employeeId,
      'shop_id': shopId,
      'notes': notes,
      'event_id': int.tryParse((eventId ?? '').trim()),
      'serial_number_id': (serialNumberId ?? '').trim(),
      'control_number': controlNumber,
      'image': image,
    });

    await _apiClient.put('/availed-services/$serviceId', data: payload, requiresAuth: true);
  }

  Future<void> deleteService(int serviceId) async {
    await _apiClient.delete('/availed-services/$serviceId', requiresAuth: true);
  }

  Future<void> updateProduct({
    required int productId,
    required String modelName,
    required String unitsOfMeasurement,
    required String contractDate,
    required String deliveryDate,
    required String installmentDate,
    required String notes,
    required int? clientId,
    required String modelCode,
    required String applianceType,
    required int? employeeId,
  }) async {
    final payload = _withoutEmptyValues({
      'model_name': modelName,
      'unitsofmeasurement': unitsOfMeasurement,
      'contract_date': contractDate,
      'delivery_date': deliveryDate,
      'installment_date': installmentDate,
      'notes': notes,
      'client_id': clientId,
      'model_code': modelCode,
      'appliance_type': applianceType,
      'employee_id': employeeId,
    });

    await _apiClient.put('/products/$productId', data: payload, requiresAuth: true);
  }

  Future<void> deleteProduct(int productId) async {
    await _apiClient.delete('/products/$productId', requiresAuth: true);
  }

  Future<List<Map<String, String>>> fetchServiceTypes() async {
    final items = await _safeFetchPaginated('/service-types');
    return items.map((item) {
      final id = (_firstInt(item, const ['id']) ?? '').toString();
      final name = _firstString(item, const ['setypename', 'name']) ?? 'Service #$id';
      return <String, String>{'id': id, 'name': name};
    }).where((item) => item['id']!.isNotEmpty).toList();
  }

  Future<List<Map<String, String>>> fetchSerialNumbers() async {
    final items = await _safeFetchPaginated('/serial-numbers');
    return items.map((item) {
      final id = (_firstInt(item, const ['id']) ?? '').toString();
      final serial = _firstString(item, const ['serial_number', 'serial']) ?? 'SN #$id';
      return <String, String>{'id': id, 'name': serial};
    }).where((item) => item['id']!.isNotEmpty).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchPaginated(String path) async {
    final separator = path.contains('?') ? '&' : '?';
    final firstPageResponse = await _apiClient.get(
      '$path${separator}per_page=100&page=1',
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
      final nextSeparator = path.contains('?') ? '&' : '?';
      remainingRequests.add(
        _apiClient.get('$path${nextSeparator}per_page=100&page=$page', requiresAuth: true),
      );
    }

    final remainingResponses = await Future.wait(remainingRequests);
    for (final response in remainingResponses) {
      allItems.addAll(_extractMapItems(response.data));
    }

    return allItems;
  }

  Future<Map<String, dynamic>> _safeGetMap(String path) async {
    try {
      final response = await _apiClient.get(path, requiresAuth: true);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  Future<List<Map<String, dynamic>>> _safeFetchPaginated(String path) async {
    try {
      return await _fetchPaginated(path);
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

  Map<String, String> _mapClientDetail(Map<String, dynamic> client) {
    final first = _firstString(client, const ['cfirstname', 'first_name']) ?? '';
    final middle = _firstString(client, const ['cmiddlename', 'middle_name']) ?? '';
    final last = _firstString(client, const ['csurname', 'last_name']) ?? '';
    final fullNameParts = [first, middle, last].where((v) => v.trim().isNotEmpty).toList();
    final fullName = fullNameParts.isEmpty ? '-' : fullNameParts.join(' ');

    return <String, String>{
      'clientId': (_firstInt(client, const ['id', 'client_id']) ?? '').toString(),
      'shopId': (_firstInt(client, const ['shop_id', 'shopid']) ?? '').toString(),
      'firstName': first,
      'middleName': middle,
      'lastName': last,
      'name': fullName,
      'contactPerson': fullName,
      'companyName': _firstString(client, const ['ccompanyname', 'company_name']) ?? 'N/A',
      'contactEmail': _firstString(client, const ['cemail', 'email', 'cemailaddress']) ?? '-',
      'contactNo': _firstString(client, const ['cphonenum', 'phonenum', 'phone']) ?? '-',
      'address': _firstString(client, const ['address']) ?? '-',
      'notes': _firstString(client, const ['notes']) ?? '',
      'shop': _firstString(client, const ['shopname', 'shop_name']) ?? '-',
    };
  }

  String? _formatDate(DateTime? date) {
    if (date == null) {
      return null;
    }

    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Map<String, dynamic> _withoutEmptyValues(Map<String, dynamic> input) {
    final output = <String, dynamic>{};

    input.forEach((key, value) {
      if (value == null) {
        return;
      }

      if (value is String && value.trim().isEmpty) {
        return;
      }

      if (value is List && value.isEmpty) {
        return;
      }

      output[key] = value;
    });

    return output;
  }
}
