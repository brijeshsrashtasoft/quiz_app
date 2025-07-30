import 'dart:collection';
import '../../utils/logger.dart';

/// Memory cache with LRU eviction for optimizing data access
class MemoryCache<K, V> {
  final int maxSize;
  final Duration? ttl;
  
  final LinkedHashMap<K, _CacheEntry<V>> _cache = LinkedHashMap();
  
  MemoryCache({
    required this.maxSize,
    this.ttl,
  });

  /// Get value from cache
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    // Check if expired
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    
    // Move to end (most recently used)
    _cache.remove(key);
    _cache[key] = entry;
    
    return entry.value;
  }

  /// Put value in cache
  void put(K key, V value) {
    // Remove if already exists
    _cache.remove(key);
    
    // Add to end
    _cache[key] = _CacheEntry(
      value: value,
      timestamp: DateTime.now(),
      ttl: ttl,
    );
    
    // Evict oldest if over capacity
    if (_cache.length > maxSize) {
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
  }

  /// Remove value from cache
  void remove(K key) {
    _cache.remove(key);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
  }

  /// Get cache size
  int get size => _cache.length;

  /// Check if key exists
  bool containsKey(K key) {
    final entry = _cache[key];
    if (entry == null) return false;
    
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    
    return true;
  }

  /// Clean up expired entries
  void evictExpired() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    evictExpired();
    return {
      'size': _cache.length,
      'maxSize': maxSize,
      'utilization': (_cache.length / maxSize * 100).toStringAsFixed(1) + '%',
    };
  }
}

class _CacheEntry<V> {
  final V value;
  final DateTime timestamp;
  final Duration? ttl;

  _CacheEntry({
    required this.value,
    required this.timestamp,
    this.ttl,
  });

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(timestamp) > ttl!;
  }
}

/// Cached stream transformer for optimizing real-time data
class CachedStreamTransformer<T> {
  final Duration cacheDuration;
  final MemoryCache<String, T> _cache;
  
  CachedStreamTransformer({
    required this.cacheDuration,
    int maxCacheSize = 100,
  }) : _cache = MemoryCache<String, T>(
          maxSize: maxCacheSize,
          ttl: cacheDuration,
        );

  /// Transform stream with caching
  Stream<T> transform(Stream<T> source, String cacheKey) {
    // Get cached value first
    final cached = _cache.get(cacheKey);
    
    // Create stream that starts with cached value if available
    final transformedStream = source.map((data) {
      _cache.put(cacheKey, data);
      return data;
    });
    
    // If we have cached data, prepend it to the stream
    if (cached != null) {
      return Stream.value(cached).followedBy(transformedStream);
    }
    
    return transformedStream;
  }

  /// Get cached value
  T? getCached(String cacheKey) => _cache.get(cacheKey);

  /// Clear cache
  void clearCache() => _cache.clear();
}