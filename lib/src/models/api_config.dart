import 'api_error.dart';
import 'cache_config.dart';
import 'retry_config.dart';

/// Configuration class for API Helper
class ApiConfig {
  /// Base URL for all API calls
  final String? baseUrl;

  /// Default headers to be added to all requests
  final Map<String, String>? defaultHeaders;

  /// Function to get authentication token
  final Future<String?> Function()? getToken;

  /// Function called when token expires (401 response)
  final Future<void> Function()? onTokenExpired;

  /// Function called when an error occurs
  final void Function(ApiError error)? onError;

  /// Default timeout for requests
  final Duration timeout;

  /// Default retry configuration
  final RetryConfig? retryConfig;

  /// Default cache configuration
  final CacheConfig? cacheConfig;

  /// Enable request/response logging
  final bool enableLogging;

  /// Enable debug mode
  final bool debugMode;

  const ApiConfig({
    this.baseUrl,
    this.defaultHeaders,
    this.getToken,
    this.onTokenExpired,
    this.onError,
    this.timeout = const Duration(seconds: 30),
    this.retryConfig,
    this.cacheConfig,
    this.enableLogging = false,
    this.debugMode = false,
  });

  /// Create a copy with updated values
  ApiConfig copyWith({
    String? baseUrl,
    Map<String, String>? defaultHeaders,
    Future<String?> Function()? getToken,
    Future<void> Function()? onTokenExpired,
    void Function(ApiError error)? onError,
    Duration? timeout,
    RetryConfig? retryConfig,
    CacheConfig? cacheConfig,
    bool? enableLogging,
    bool? debugMode,
  }) {
    return ApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      getToken: getToken ?? this.getToken,
      onTokenExpired: onTokenExpired ?? this.onTokenExpired,
      onError: onError ?? this.onError,
      timeout: timeout ?? this.timeout,
      retryConfig: retryConfig ?? this.retryConfig,
      cacheConfig: cacheConfig ?? this.cacheConfig,
      enableLogging: enableLogging ?? this.enableLogging,
      debugMode: debugMode ?? this.debugMode,
    );
  }
}
