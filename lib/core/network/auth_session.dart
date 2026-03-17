import 'package:flutter/foundation.dart';

class AuthSession {
  AuthSession._();

  static final ValueNotifier<int> logoutEvent = ValueNotifier<int>(0);

  static void triggerLogout() {
    logoutEvent.value = logoutEvent.value + 1;
  }
}
