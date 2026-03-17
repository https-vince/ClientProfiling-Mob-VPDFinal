import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../services/auth_service.dart';

class LoginState {
  final bool isSubmitting;
  final String? emailError;
  final String? passwordError;
  final String? message;

  const LoginState({
    this.isSubmitting = false,
    this.emailError,
    this.passwordError,
    this.message,
  });

  LoginState copyWith({
    bool? isSubmitting,
    String? emailError,
    String? passwordError,
    String? message,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearMessage = false,
  }) {
    return LoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref.watch(authServiceProvider));
});

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService _authService;

  LoginNotifier(this._authService) : super(const LoginState());

  Future<bool> submit({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearEmailError: true,
      clearPasswordError: true,
      clearMessage: true,
    );

    try {
      await _authService.login(email: email, password: password);
      await _authService.getAuthenticatedUser();
      state = state.copyWith(isSubmitting: false, clearMessage: true);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        emailError: e.fieldErrors['email'],
        passwordError: e.fieldErrors['password'],
        message: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        message: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }
}
