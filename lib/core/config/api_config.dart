class ApiConfig {
  ApiConfig._();

  // For real Android device in the same LAN.
  static const String baseUrl = 'http://192.168.254.93:8000/api';

  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String profilePath = '/profile';
  static const String logoutPath = '/logout';

  static const String dashboardSummaryPath = '/dashboard/summary';
}
