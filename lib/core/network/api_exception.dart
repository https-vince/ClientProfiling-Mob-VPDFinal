class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  bool get isUnauthorized => statusCode == 401;

  bool get isValidationError => statusCode == 422 || fieldErrors.isNotEmpty;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}
