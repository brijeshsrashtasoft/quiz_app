import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/firebase/firestore_config.dart';
import '../models/game_session_model.dart';
import '../../domain/entities/game_session_entity.dart';

/// Real-time game session service for optimized performance
/// Implements connection state monitoring and recovery strategies
class GameSessionRealtimeService {
  static const int _reconnectDelayMs = 1000;
  static const int _maxReconnectAttempts = 5;
  static const int _batchUpdateIntervalMs = 100;

  final _connectivity = Connectivity();
  final _activeStreams = <String, StreamSubscription>{};
  final _connectionStateController =
      StreamController<ConnectionState>.broadcast();
  final _pendingUpdates = <String, List<Map<String, dynamic>>>{};

  Timer? _batchUpdateTimer;
  int _reconnectAttempts = 0;
  bool _isOnline = true;

  Stream<ConnectionState> get connectionState =>
      _connectionStateController.stream;

  /// Initialize connection monitoring
  void initialize() {
    _connectivity.onConnectivityChanged.listen((results) {
      // Handle List<ConnectivityResult> returned by newer connectivity_plus
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      _handleConnectivityChange(result);
    });

    // Check initial connectivity
    _checkConnectivity();
  }

  /// Monitor game session with optimized real-time updates
  Stream<GameSessionEntity?> monitorGameSession(
    String sessionId, {
    bool includeMetadataChanges = false,
  }) {
    final controller = StreamController<GameSessionEntity?>.broadcast();

    // Cancel existing stream if any
    _activeStreams[sessionId]?.cancel();

    // Create optimized query with specific fields to minimize data transfer
    final docRef = FirestoreConfig.getDocument('game_sessions', sessionId);

    final streamSub = docRef
        .snapshots(includeMetadataChanges: includeMetadataChanges)
        .listen(
          (snapshot) {
            if (snapshot.exists) {
              try {
                final data = snapshot.data()!;
                data['id'] = snapshot.id;

                // Check if data is from cache or server
                final isFromCache = snapshot.metadata.isFromCache;
                if (isFromCache) {
                  AppLogger.firebase(
                    'RealtimeService',
                    'Session $sessionId data from cache',
                  );
                }

                final session = GameSessionModel.fromFirestore(data);
                controller.add(session.toEntity());

                // Update connection state
                if (!isFromCache && !_isOnline) {
                  _isOnline = true;
                  _connectionStateController.add(ConnectionState.connected);
                }
              } catch (e) {
                AppLogger.error('Failed to parse session data', e);
                controller.addError(e);
              }
            } else {
              controller.add(null);
            }
          },
          onError: (error) {
            AppLogger.error('Stream error for session $sessionId', error);
            controller.addError(error);
            _handleStreamError(sessionId, error);
          },
        );

    // Store stream subscription
    _activeStreams[sessionId] = streamSub;

    // Handle controller lifecycle
    controller.onCancel = () {
      streamSub.cancel();
      _activeStreams.remove(sessionId);
    };

    return controller.stream;
  }

  /// Monitor player updates with reduced frequency for performance
  Stream<Map<String, PlayerEntity>> monitorPlayers(String sessionId) {
    return monitorGameSession(sessionId)
        .map((session) => session?.players ?? {})
        .distinct(); // Only emit when players actually change
  }

  /// Monitor current question with debouncing
  Stream<int> monitorCurrentQuestion(String sessionId) {
    return monitorGameSession(sessionId)
        .map((session) => session?.currentQuestionIndex ?? 0)
        .distinct() // Only emit when question changes
        .debounceTime(
          const Duration(milliseconds: 200),
        ); // Debounce rapid changes
  }

  /// Batch update for optimal write performance
  Future<void> batchUpdatePlayerScore(
    String sessionId,
    String playerId,
    Map<String, dynamic> updates,
  ) async {
    // Add to pending updates
    final key = '$sessionId:$playerId';
    _pendingUpdates[key] ??= [];
    _pendingUpdates[key]!.add(updates);

    // Schedule batch update
    _scheduleBatchUpdate();
  }

  /// Schedule batch update with debouncing
  void _scheduleBatchUpdate() {
    _batchUpdateTimer?.cancel();
    _batchUpdateTimer = Timer(
      Duration(milliseconds: _batchUpdateIntervalMs),
      _executeBatchUpdate,
    );
  }

  /// Execute batched updates
  Future<void> _executeBatchUpdate() async {
    if (_pendingUpdates.isEmpty) return;

    final batch = FirestoreConfig.getBatch();
    final updates = Map<String, List<Map<String, dynamic>>>.from(
      _pendingUpdates,
    );
    _pendingUpdates.clear();

    try {
      for (final entry in updates.entries) {
        final parts = entry.key.split(':');
        final sessionId = parts[0];
        final playerId = parts[1];

        // Merge all updates for this player
        final mergedUpdate = entry.value.reduce((merged, update) {
          merged.addAll(update);
          return merged;
        });

        // Update player data in batch
        final docRef = FirestoreConfig.getDocument('game_sessions', sessionId);
        batch.update(docRef, {'players.$playerId': mergedUpdate});
      }

      await batch.commit();
      AppLogger.performance(
        'Batch update committed',
        Duration(milliseconds: _batchUpdateIntervalMs),
      );
    } catch (e) {
      AppLogger.error('Batch update failed', e);
      // Re-add failed updates for retry
      _pendingUpdates.addAll(updates);
      throw FirestoreException(
        message: 'Failed to commit batch updates',
        code: 'batch_update_error',
      );
    }
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    AppLogger.firebase(
      'RealtimeService',
      'Connectivity changed: $result (online: $_isOnline)',
    );

    if (_isOnline && !wasOnline) {
      // Coming back online - reconnect streams
      _connectionStateController.add(ConnectionState.reconnecting);
      _reconnectStreams();
    } else if (!_isOnline && wasOnline) {
      // Going offline
      _connectionStateController.add(ConnectionState.offline);
    }
  }

  /// Check current connectivity
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      // Handle List<ConnectivityResult> returned by newer connectivity_plus
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      _handleConnectivityChange(result);

      // Also check Firestore connectivity
      final isFirestoreConnected = await FirestoreConfig.checkConnectivity();
      if (!isFirestoreConnected && _isOnline) {
        _connectionStateController.add(ConnectionState.error);
      }
    } catch (e) {
      AppLogger.error('Connectivity check failed', e);
    }
  }

  /// Handle stream errors with reconnection logic
  void _handleStreamError(String sessionId, dynamic error) {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;

      Future.delayed(
        Duration(milliseconds: _reconnectDelayMs * _reconnectAttempts),
        () {
          AppLogger.firebase(
            'RealtimeService',
            'Attempting reconnect for session $sessionId (attempt $_reconnectAttempts)',
          );

          // Restart the stream
          if (_activeStreams.containsKey(sessionId)) {
            monitorGameSession(sessionId);
          }
        },
      );
    } else {
      _connectionStateController.add(ConnectionState.error);
    }
  }

  /// Reconnect all active streams
  void _reconnectStreams() {
    _reconnectAttempts = 0;
    final sessionIds = _activeStreams.keys.toList();

    for (final sessionId in sessionIds) {
      monitorGameSession(sessionId);
    }
  }

  /// Optimize query for specific fields
  Stream<Map<String, dynamic>> monitorSpecificFields(
    String sessionId,
    List<String> fields,
  ) {
    // Note: Firestore doesn't support field-level queries in real-time
    // but we can optimize client-side processing
    return monitorGameSession(sessionId).map((session) {
      if (session == null) return {};

      final data = <String, dynamic>{};
      for (final field in fields) {
        switch (field) {
          case 'status':
            data['status'] = session.status.name;
            break;
          case 'currentQuestionIndex':
            data['currentQuestionIndex'] = session.currentQuestionIndex;
            break;
          case 'playerCount':
            data['playerCount'] = session.playerCount;
            break;
          case 'players':
            data['players'] = session.players;
            break;
        }
      }
      return data;
    });
  }

  /// Prefetch session data for faster initial load
  Future<void> prefetchSession(String sessionId) async {
    try {
      final doc = await FirestoreConfig.getDocument(
        'game_sessions',
        sessionId,
      ).get(const GetOptions(source: Source.cache));

      if (!doc.exists) {
        // Fetch from server if not in cache
        await FirestoreConfig.getDocument(
          'game_sessions',
          sessionId,
        ).get(const GetOptions(source: Source.server));
      }

      AppLogger.firebase('RealtimeService', 'Prefetched session $sessionId');
    } catch (e) {
      AppLogger.error('Failed to prefetch session', e);
    }
  }

  /// Clean up resources
  void dispose() {
    _batchUpdateTimer?.cancel();

    // Cancel all active streams
    for (final sub in _activeStreams.values) {
      sub.cancel();
    }
    _activeStreams.clear();

    _connectionStateController.close();
  }
}

/// Connection state enum
enum ConnectionState { connected, connecting, reconnecting, offline, error }

/// Extension for debouncing streams
extension StreamDebounce<T> on Stream<T> {
  Stream<T> debounceTime(Duration duration) {
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) {
          Timer? timer;
          timer?.cancel();
          timer = Timer(duration, () => sink.add(data));
        },
      ),
    );
  }
}
