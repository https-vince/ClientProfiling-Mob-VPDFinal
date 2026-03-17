class ApiConfig {
  const ApiConfig._();

  // For Android emulator use 10.0.2.2 instead of 127.0.0.1.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  static const String loginPath = '/login';
  static const String authenticatedUserPath = '/profile';
  static const String logoutPath = '/logout';
  static const String dashboardSummaryPath = '/dashboard/summary';
}
