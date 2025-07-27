class RetryConfig {
  /// Maximum number of retries
  final int maxRetries;

  /// Delay between retries
  final Duration retryDelay;

  /// Whether to use exponential backoff
  final bool useExponentialBackoff;

  /// Maximum delay between retries
  final Duration maxRetryDelay;

  /// HTTP status codes that should trigger a retry
  final List<int> retryStatusCodes;

  const RetryConfig({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.useExponentialBackoff = true,
    this.maxRetryDelay = const Duration(seconds: 10),
    this.retryStatusCodes = const [408, 429, 500, 502, 503, 504],
  });

  /// Create a copy with updated values
  RetryConfig copyWith({
    int? maxRetries,
    Duration? retryDelay,
    bool? useExponentialBackoff,
    Duration? maxRetryDelay,
    List<int>? retryStatusCodes,
  }) {
    return RetryConfig(
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      useExponentialBackoff:
          useExponentialBackoff ?? this.useExponentialBackoff,
      maxRetryDelay: maxRetryDelay ?? this.maxRetryDelay,
      retryStatusCodes: retryStatusCodes ?? this.retryStatusCodes,
    );
  }
}
