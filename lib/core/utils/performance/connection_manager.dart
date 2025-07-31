import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/logger.dart';

/// Connection manager for optimizing real-time connections
/// Handles connection pooling, recovery, and offline state
class ConnectionManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isInitialized = false;

  final _connectionStateController =
      StreamController<ConnectionState>.broadcast();
  Stream<ConnectionState> get connectionState =>
      _connectionStateController.stream;

  /// Initialize connection monitoring
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;

    // Enable Firestore offline persistence
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    AppLogger.info('ConnectionManager', 'Initialized with offline persistence');
    _connectionStateController.add(ConnectionState.online);
  }

  /// Optimize for offline mode
  Future<void> enableOfflineMode() async {
    await _firestore.disableNetwork();
    _connectionStateController.add(ConnectionState.offline);
  }

  /// Resume online mode
  Future<void> enableOnlineMode() async {
    await _firestore.enableNetwork();
    _connectionStateController.add(ConnectionState.online);
  }

  /// Dispose of resources
  void dispose() {
    _connectionStateController.close();
  }
}

/// Connection states
enum ConnectionState { online, offline, syncing, error }

/// Connection pooling for managing multiple listeners efficiently
class ListenerPool {
  final Map<String, StreamSubscription> _activeListeners = {};
  final Map<String, int> _listenerRefCounts = {};

  /// Add a listener with reference counting
  void addListener(
    String key,
    Stream stream,
    void Function(dynamic) onData, {
    void Function(Object, StackTrace)? onError,
  }) {
    if (_activeListeners.containsKey(key)) {
      // Increment reference count
      _listenerRefCounts[key] = (_listenerRefCounts[key] ?? 0) + 1;
      return;
    }

    // Create new listener
    final subscription = stream.listen(
      onData,
      onError:
          onError ??
          (error, stack) {
            AppLogger.error('Listener error for $key', error, stack);
          },
    );

    _activeListeners[key] = subscription;
    _listenerRefCounts[key] = 1;
  }

  /// Remove a listener with reference counting
  void removeListener(String key) {
    final refCount = _listenerRefCounts[key] ?? 0;
    if (refCount <= 1) {
      // Last reference, cancel subscription
      _activeListeners[key]?.cancel();
      _activeListeners.remove(key);
      _listenerRefCounts.remove(key);
    } else {
      // Decrement reference count
      _listenerRefCounts[key] = refCount - 1;
    }
  }

  /// Pause all listeners
  void pauseAll() {
    for (final subscription in _activeListeners.values) {
      subscription.pause();
    }
  }

  /// Resume all listeners
  void resumeAll() {
    for (final subscription in _activeListeners.values) {
      subscription.resume();
    }
  }

  /// Dispose of all listeners
  void dispose() {
    for (final subscription in _activeListeners.values) {
      subscription.cancel();
    }
    _activeListeners.clear();
    _listenerRefCounts.clear();
  }
}
