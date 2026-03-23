import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/token_storage.dart';

class AuthService {
  AuthService({ApiClient? apiClient, TokenStorage? tokenStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.loginPath,
      data: <String, dynamic>{
        'email': email.trim(),
        'password': password,
      },
      requiresAuth: false,
    );

    final payload = response.data;
    final token = _extractToken(payload);
    if (token == null || token.isEmpty) {
      throw const FormatException('Login succeeded but token was missing.');
    }

    await _tokenStorage.saveToken(token);
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _apiClient.get(
      ApiConfig.profilePath,
      requiresAuth: true,
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return payload;
    }

    return const <String, dynamic>{};
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConfig.logoutPath, requiresAuth: true);
    } finally {
      await _tokenStorage.clearToken();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.readToken();
    return (token ?? '').trim().isNotEmpty;
  }

  String? _extractToken(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      return null;
    }

    final direct = payload['token']?.toString().trim();
    if ((direct ?? '').isNotEmpty) {
      return direct;
    }

    final accessToken = payload['access_token']?.toString().trim();
    if ((accessToken ?? '').isNotEmpty) {
      return accessToken;
    }

    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['token']?.toString().trim();
      if ((nested ?? '').isNotEmpty) {
        return nested;
      }
      final nestedAccessToken = data['access_token']?.toString().trim();
      if ((nestedAccessToken ?? '').isNotEmpty) {
        return nestedAccessToken;
      }
    }

    return null;
  }
}
