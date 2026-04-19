import 'package:flutter/foundation.dart';

/// Simple API response caching utility to prevent redundant API calls
class ApiCache {
  static final ApiCache _instance = ApiCache._internal();
  
  factory ApiCache() {
    return _instance;
  }
  
  ApiCache._internal();
  
  final Map<String, CacheEntry> _cache = {};
  final Duration _defaultCacheDuration = const Duration(minutes: 5);
  
  /// Get cached data if valid
  dynamic get(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      debugPrint('✅ Cache HIT for: $key');
      return entry.data;
    }
    if (entry != null && entry.isExpired) {
      _cache.remove(key);
    }
    return null;
  }
  
  /// Store data in cache
  void set(String key, dynamic data) {
    _cache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(_defaultCacheDuration),
    );
    debugPrint('💾 Cached: $key');
  }
  
  /// Clear specific cache entry
  void remove(String key) {
    _cache.remove(key);
    debugPrint('🗑️ Cleared cache: $key');
  }
  
  /// Clear all cache
  void clear() {
    _cache.clear();
    debugPrint('🗑️ Cleared all cache');
  }
  
  /// Get cache info for debugging
  Map<String, String> getCacheInfo() {
    final info = <String, String>{};
    for (var entry in _cache.entries) {
      info[entry.key] = 'Expires: ${entry.value.expiresAt}';
    }
    return info;
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiresAt;
  
  CacheEntry({
    required this.data,
    required this.expiresAt,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
