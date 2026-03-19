import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/token_storage.dart';
import '../models/auth_user.dart';
import '../models/login_response.dart';

class AuthService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
    UnauthorizedCallback? onUnauthorized,
  })  : _tokenStorage = tokenStorage ?? const TokenStorage(),
        _apiClient = apiClient ??
            ApiClient(
              tokenStorage: tokenStorage,
              onUnauthorized: onUnauthorized,
            );

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.loginPath,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const ApiException(message: 'Invalid login response format.');
    }

    final loginResponse = LoginResponse.fromJson(data);
    if (loginResponse.token.isEmpty) {
      throw const ApiException(message: 'Token missing from login response.');
    }

    await _tokenStorage.saveToken(loginResponse.token);
    return loginResponse;
  }

  Future<AuthUser> getAuthenticatedUser() async {
    final response = await _apiClient.get(
      ApiConfig.authenticatedUserPath,
      requiresAuth: true,
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const ApiException(message: 'Invalid user response format.');
    }

    final userJson = data['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'Profile response missing user object.',
      );
    }

    return AuthUser.fromJson(userJson);
  }

  Future<AuthUser> updateAuthenticatedUser({
    required String username,
    required String firstname,
    required String middlename,
    required String surname,
    required String phonenum,
    required String address,
    required String email,
    required String role,
  }) async {
    final payload = {
      'username': username,
      'firstname': firstname,
      'middlename': middlename,
      'surname': surname,
      'phonenum': phonenum,
      'address': address,
      'email': email,
      'role': role,
    };

    final response = await _apiClient.patch(
      ApiConfig.authenticatedUserPath,
      data: payload,
      requiresAuth: true,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final userJson = data['user'];
      if (userJson is Map<String, dynamic>) {
        return AuthUser.fromJson(userJson);
      }

      final rawData = data['data'];
      if (rawData is Map<String, dynamic>) {
        return AuthUser.fromJson(rawData);
      }
    }

    return getAuthenticatedUser();
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(
        ApiConfig.logoutPath,
        requiresAuth: true,
      );
    } finally {
      await _tokenStorage.clearToken();
    }
  }
}
