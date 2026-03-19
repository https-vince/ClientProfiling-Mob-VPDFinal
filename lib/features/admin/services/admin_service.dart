import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

class AdminScreenData {
  final List<Map<String, String>> admins;
  final List<Map<String, String>> employees;

  const AdminScreenData({
    required this.admins,
    required this.employees,
  });
}

class AdminService {
  final ApiClient _apiClient;

  AdminService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<AdminScreenData> fetchData() async {
    final usersFuture = _fetchPaginatedWithFallback(
      const ['/users'],
      allowFailure: false,
    );
    final employeesFuture = _fetchPaginatedWithFallback(
      const ['/employees', '/employee'],
      allowFailure: true,
    );

    final users = await usersFuture;
    final employees = await employeesFuture;

    final mappedAdmins = users.map((item) {
      final first = (item['firstname'] ?? '').toString().trim();
      final middle = (item['middlename'] ?? '').toString().trim();
      final last = (item['surname'] ?? '').toString().trim();
      final nameParts = [first, middle, last].where((p) => p.isNotEmpty).toList();
      final fullName = nameParts.isEmpty ? '-' : nameParts.join(' ');

      return <String, String>{
        'id': (item['id'] ?? '').toString(),
        'name': fullName,
        'firstName': first.isEmpty ? '-' : first,
        'middleName': middle.isEmpty ? 'N/A' : middle,
        'lastName': last.isEmpty ? '-' : last,
        'username': _firstString(item, const ['username']) ?? '-',
        'phone': _firstString(item, const ['phonenum', 'phone']) ?? '-',
        'email': _firstString(item, const ['email']) ?? '-',
        'role': _firstString(item, const ['role']) ?? '-',
        'address': _firstString(item, const ['address']) ?? '-',
      };
    }).toList();

    final mappedEmployees = employees.map((item) {
      return <String, String>{
        'id': (item['id'] ?? '').toString(),
        'name': _firstString(item, const ['efullname', 'name']) ?? '-',
        'position': _firstString(item, const ['employee_type_id', 'position']) ?? '-',
      };
    }).toList();

    return AdminScreenData(admins: mappedAdmins, employees: mappedEmployees);
  }

  Future<List<Map<String, dynamic>>> _fetchPaginatedWithFallback(
    List<String> paths, {
    required bool allowFailure,
  }) async {
    ApiException? lastApiError;
    Object? lastError;

    for (final path in paths) {
      try {
        return await _fetchPaginated(path);
      } on ApiException catch (e) {
        // If an optional endpoint is missing or unstable, keep UI available.
        if (allowFailure && (e.statusCode == 404 || e.statusCode == 500)) {
          return const [];
        }
        lastApiError = e;
      } catch (e) {
        lastError = e;
      }
    }

    if (allowFailure) {
      return const [];
    }

    if (lastApiError != null) {
      throw lastApiError;
    }
    if (lastError != null) {
      throw lastError;
    }

    return const [];
  }

  Future<void> createUser({
    required String username,
    required String firstname,
    required String? middlename,
    required String surname,
    required String phonenum,
    required String address,
    required String email,
    required String password,
    required String role,
  }) async {
    await _apiClient.post(
      '/users',
      requiresAuth: true,
      data: {
        'username': username,
        'firstname': firstname,
        'middlename': (middlename ?? '').trim().isEmpty ? null : middlename,
        'surname': surname,
        'phonenum': phonenum,
        'address': address,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
      },
    );
  }

  Future<void> updateUser({
    required String id,
    required String username,
    required String firstname,
    required String? middlename,
    required String surname,
    required String phonenum,
    required String address,
    required String email,
    required String role,
  }) async {
    await _apiClient.patch(
      '/users/$id',
      requiresAuth: true,
      data: {
        'username': username,
        'firstname': firstname,
        'middlename': (middlename ?? '').trim().isEmpty ? null : middlename,
        'surname': surname,
        'phonenum': phonenum,
        'address': address,
        'email': email,
        'role': role,
      },
    );
  }

  Future<void> createEmployee({
    required String fullName,
    required String employeeType,
  }) async {
    await _apiClient.post(
      '/employees',
      requiresAuth: true,
      data: {
        'efullname': fullName,
        'employee_type_id': employeeType,
      },
    );
  }

  Future<void> updateEmployee({
    required String id,
    required String fullName,
    required String employeeType,
  }) async {
    await _apiClient.patch(
      '/employees/$id',
      requiresAuth: true,
      data: {
        'efullname': fullName,
        'employee_type_id': employeeType,
      },
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
