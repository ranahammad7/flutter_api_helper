enum ApiErrorType {
  network,
  timeout,
  server,
  client,
  parsing,
  authentication,
  unknown,
}

/// API Error class
class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorType type;
  final bool isRetryable;
  final String? responseBody;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.message,
    this.statusCode,
    required this.type,
    this.isRetryable = false,
    this.responseBody,
    this.details,
  });

  /// Check if error is network related
  bool get isNetworkError => type == ApiErrorType.network;

  /// Check if error is server related
  bool get isServerError => type == ApiErrorType.server;

  /// Check if error is client related
  bool get isClientError => type == ApiErrorType.client;

  /// Check if error is authentication related
  bool get isAuthError =>
      type == ApiErrorType.authentication || statusCode == 401;

  /// Check if error is timeout related
  bool get isTimeoutError => type == ApiErrorType.timeout;

  @override
  String toString() {
    return 'ApiError(message: $message, statusCode: $statusCode, type: $type)';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'type': type.name,
      'isRetryable': isRetryable,
      'responseBody': responseBody,
      'details': details,
    };
  }
}
