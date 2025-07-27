class ApiResponse<T> {
  final T data;
  final bool success;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.data,
    required this.success,
    this.message,
    this.statusCode,
    this.meta,
  });

  /// Create success response
  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      data: data,
      success: true,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Create error response
  factory ApiResponse.error(String message, {int? statusCode, T? data}) {
    return ApiResponse(
      data: data as T,
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'meta': meta,
    };
  }
}
