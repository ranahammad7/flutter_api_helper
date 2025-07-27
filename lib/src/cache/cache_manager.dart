import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cache_config.dart';

/// Cache manager for API responses
class CacheManager {
  static CacheManager? _instance;
  static CacheManager get instance => _instance ??= CacheManager._();

  CacheManager._();

  SharedPreferences? _prefs;
  final Map<String, _CacheItem> _memoryCache = {};

  /// Initialize cache manager
  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get cached data
  Future<String?> get(String key) async {
    // Check memory cache first
    final memoryItem = _memoryCache[key];
    if (memoryItem != null && !memoryItem.isExpired) {
      return memoryItem.data;
    }

    // Check disk cache
    await _init();
    final diskData = _prefs!.getString(key);
    if (diskData != null) {
      try {
        final cacheData = jsonDecode(diskData);
        final expiryTime =
            DateTime.fromMillisecondsSinceEpoch(cacheData['expiry']);

        if (DateTime.now().isBefore(expiryTime)) {
          // Update memory cache
          _memoryCache[key] = _CacheItem(
            data: cacheData['data'],
            expiry: expiryTime,
          );
          return cacheData['data'];
        } else {
          // Remove expired data
          await remove(key);
        }
      } catch (e) {
        // Remove corrupted data
        await remove(key);
      }
    }

    return null;
  }

  /// Set cache data
  Future<void> set(String key, String data, CacheConfig config) async {
    final expiry = DateTime.now().add(config.duration);

    // Set memory cache
    if (config.useMemoryCache) {
      _memoryCache[key] = _CacheItem(data: data, expiry: expiry);
    }

    // Set disk cache
    if (config.useDiskCache) {
      await _init();
      final cacheData = {
        'data': data,
        'expiry': expiry.millisecondsSinceEpoch,
      };
      await _prefs!.setString(key, jsonEncode(cacheData));
    }
  }

  /// Remove cached data
  Future<void> remove(String key) async {
    _memoryCache.remove(key);

    await _init();
    await _prefs!.remove(key);
  }

  /// Clear all cache
  Future<void> clear() async {
    _memoryCache.clear();

    await _init();
    final keys = _prefs!.getKeys().where((key) => key.startsWith('api_cache_'));
    for (final key in keys) {
      await _prefs!.remove(key);
    }
  }

  /// Get cache size
  Future<int> getCacheSize() async {
    await _init();
    int size = 0;
    final keys = _prefs!.getKeys().where((key) => key.startsWith('api_cache_'));

    for (final key in keys) {
      final data = _prefs!.getString(key);
      if (data != null) {
        size += data.length;
      }
    }

    return size;
  }
}

/// Cache item model
class _CacheItem {
  final String data;
  final DateTime expiry;

  _CacheItem({required this.data, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}
