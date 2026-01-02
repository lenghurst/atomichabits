import 'dart:async';

/// CacheManager - Standardized caching logic
///
/// Handles time-to-live (TTL), async refreshing, and cache validation.
/// Replaces ad-hoc caching patterns scattered across services.
class CacheManager<T> {
  final Duration ttl;
  Future<T> Function()? refresher;
  final Future<void> Function(T)? onRefresh;
  final String? debugLabel;

  T? _cached;
  DateTime? _lastFetch;
  bool _isFetching = false;

  CacheManager({
    this.ttl = const Duration(minutes: 15),
    this.refresher,
    this.onRefresh,
    this.debugLabel,
  });

  /// Get cached value or refresh if expired/missing
  ///
  /// Returns null if:
  /// 1. Cache is empty/expired AND no refresher provided
  /// 2. Refresh fails and no stale cache is available
  Future<T?> get({bool forceRefresh = false}) async {
    // Return valid cache if not forced
    if (!forceRefresh && _isValid()) {
      return _cached;
    }

    // Attempt refresh if configured
    if (refresher != null) {
      if (_isFetching) {
        // Debounce: return stale cache if a fetch is already in progress
        return _cached;
      }

      _isFetching = true;
      try {
        final val = await refresher!();
        await set(val);
        return val;
      } catch (e) {
        // Return stale cache on error
        if (_cached != null) {
          return _cached;
        }
        rethrow;
      } finally {
        _isFetching = false;
      }
    }

    return _cached;
  }

  /// Manually set the cached value
  Future<void> set(T value) async {
    _cached = value;
    _lastFetch = DateTime.now();
    if (onRefresh != null) {
      await onRefresh!(value);
    }
  }

  /// Check if cache is valid (exists and within TTL)
  bool _isValid() {
    if (_cached == null || _lastFetch == null) return false;
    return DateTime.now().difference(_lastFetch!) < ttl;
  }

  /// Invalidate cache (force refresh next time)
  void invalidate() {
    _cached = null;
    _lastFetch = null;
  }

  /// Check if cache exists (regardless of TTL)
  bool get hasValue => _cached != null;

  /// Get age of cache
  Duration? get age =>
      _lastFetch != null ? DateTime.now().difference(_lastFetch!) : null;
}
