class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const <String, String>{},
  });

  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  factory ApiException.fromResponse({
    required int? statusCode,
    required dynamic payload,
  }) {
    final message = _extractMessage(statusCode, payload);
    final fieldErrors = _extractFieldErrors(payload);

    return ApiException(
      message: message,
      statusCode: statusCode,
      fieldErrors: fieldErrors,
    );
  }

  static String _extractMessage(int? statusCode, dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final payloadMessage = payload['message']?.toString().trim() ?? '';
      if (payloadMessage.isNotEmpty) {
        return payloadMessage;
      }
    }

    switch (statusCode) {
      case 401:
        return 'Unauthorized (401). Please log in again.';
      case 404:
        return 'Resource not found (404).';
      case 422:
        return 'Validation failed.';
      case 500:
        return 'Server error (500). Please try again later.';
      default:
        return 'Request failed. Please try again.';
    }
  }

  static Map<String, String> _extractFieldErrors(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      return const <String, String>{};
    }

    final rawErrors = payload['errors'];
    if (rawErrors is! Map) {
      return const <String, String>{};
    }

    final result = <String, String>{};
    rawErrors.forEach((key, value) {
      final field = key.toString();
      if (value is List && value.isNotEmpty) {
        result[field] = value.first.toString();
        return;
      }
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        result[field] = text;
      }
    });

    return result;
  }

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, message: $message, fieldErrors: $fieldErrors)';
  }
}
