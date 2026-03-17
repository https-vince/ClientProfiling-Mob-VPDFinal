import 'auth_user.dart';

class LoginResponse {
  final String message;
  final AuthUser user;
  final String token;

  const LoginResponse({
    required this.message,
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: (json['message'] ?? '').toString(),
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      token: (json['token'] ?? '').toString(),
    );
  }
}
