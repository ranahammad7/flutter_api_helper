class CacheConfig {
  /// Cache duration
  final Duration duration;

  /// Cache key prefix
  final String? keyPrefix;

  /// Whether to use memory cache
  final bool useMemoryCache;

  /// Whether to use disk cache
  final bool useDiskCache;

  /// Maximum cache size in bytes
  final int? maxCacheSize;

  const CacheConfig({
    this.duration = const Duration(minutes: 5),
    this.keyPrefix,
    this.useMemoryCache = true,
    this.useDiskCache = true,
    this.maxCacheSize,
  });

  /// Create a copy with updated values
  CacheConfig copyWith({
    Duration? duration,
    String? keyPrefix,
    bool? useMemoryCache,
    bool? useDiskCache,
    int? maxCacheSize,
  }) {
    return CacheConfig(
      duration: duration ?? this.duration,
      keyPrefix: keyPrefix ?? this.keyPrefix,
      useMemoryCache: useMemoryCache ?? this.useMemoryCache,
      useDiskCache: useDiskCache ?? this.useDiskCache,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
    );
  }
}
