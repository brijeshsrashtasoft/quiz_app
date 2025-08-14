import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../../../../core/firebase/firestore_config.dart';
import '../datasources/game_session_firestore_datasource.dart';
import '../../domain/entities/game_session_entity.dart';

/// Real-time game state synchronization service
/// Handles live multiplayer game state updates across all devices
class GameStateSyncService {
  final GameSessionFirestoreDataSource _dataSource;
  final Map<String, StreamController<GameSessionEntity>> _sessionControllers =
      {};
  final Map<String, StreamSubscription> _sessionSubscriptions = {};

  GameStateSyncService({required GameSessionFirestoreDataSource dataSource})
    : _dataSource = dataSource;

  /// Start real-time synchronization for a game session
  Stream<Result<GameSessionEntity>> startSessionSync(String sessionId) {
    try {
      // Cancel existing stream if any
      stopSessionSync(sessionId);

      final controller = StreamController<GameSessionEntity>.broadcast();
      _sessionControllers[sessionId] = controller;

      // Subscribe to Firestore real-time updates
      final subscription =
          FirestoreConfig.getDocument(
            'game_sessions',
            sessionId,
          ).snapshots().listen(
            (snapshot) {
              if (snapshot.exists) {
                try {
                  final data = snapshot.data()!;
                  data['id'] = snapshot.id;

                  final session = GameSessionEntity.fromMap(data);

                  // Check if data is from server or cache
                  final isFromCache = snapshot.metadata.isFromCache;
                  final hasPendingWrites = snapshot.metadata.hasPendingWrites;

                  AppLogger.firebase(
                    'GameStateSyncService',
                    'Session $sessionId update: fromCache=$isFromCache, '
                        'pendingWrites=$hasPendingWrites',
                  );

                  controller.add(session);
                } catch (e, stackTrace) {
                  AppLogger.error(
                    'Failed to parse session data: $sessionId',
                    e,
                    stackTrace,
                  );
                  controller.addError(
                    FirestoreException(
                      message: 'Failed to parse session data: ${e.toString()}',
                      code: 'session_parse_error',
                    ),
                  );
                }
              } else {
                controller.addError(
                  const FirestoreException(
                    message: 'Game session not found',
                    code: 'session_not_found',
                  ),
                );
              }
            },
            onError: (error) {
              AppLogger.error('Session sync stream error: $sessionId', error);
              controller.addError(error);
            },
          );

      _sessionSubscriptions[sessionId] = subscription;

      // Handle controller cleanup
      controller.onCancel = () {
        stopSessionSync(sessionId);
      };

      return controller.stream.map((session) => Result.success(session));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to start session sync: $sessionId',
        e,
        stackTrace,
      );
      return Stream.value(
        Result.failure(
          FirestoreException(
            message: 'Failed to start session sync: ${e.toString()}',
            code: 'sync_start_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Stop synchronization for a session
  void stopSessionSync(String sessionId) {
    _sessionSubscriptions[sessionId]?.cancel();
    _sessionSubscriptions.remove(sessionId);

    _sessionControllers[sessionId]?.close();
    _sessionControllers.remove(sessionId);

    AppLogger.firebase(
      'GameStateSyncService',
      'Stopped sync for session: $sessionId',
    );
  }

  /// Sync game phase changes in real-time
  Stream<Result<GamePhaseUpdate>> watchGamePhase(String sessionId) {
    try {
      return FirestoreConfig.getDocument('game_sessions', sessionId)
          .snapshots()
          .map<Result<GamePhaseUpdate>>((doc) {
            if (!doc.exists) {
              return Result.failure(
                const FirestoreException(
                  message: 'Game session not found',
                  code: 'session_not_found',
                ).toFailure(),
              );
            }

            final data = doc.data()!;
            final phaseUpdate = GamePhaseUpdate(
              sessionId: sessionId,
              currentQuestionIndex: data['currentQuestionIndex'] ?? 0,
              phase: data['currentPhase'] ?? 'waiting',
              phaseStartTime: data['phaseStartTime'] != null
                  ? (data['phaseStartTime'] as Timestamp).toDate()
                  : null,
              phaseEndTime: data['phaseEndTime'] != null
                  ? (data['phaseEndTime'] as Timestamp).toDate()
                  : null,
              status: GameSessionStatus.values.firstWhere(
                (s) => s.name == (data['status'] ?? 'waiting'),
                orElse: () => GameSessionStatus.waiting,
              ),
              updatedAt: DateTime.now(),
            );

            return Result.success(phaseUpdate);
          })
          .handleError((error) {
            AppLogger.error('Game phase watch error: $sessionId', error);
          });
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to setup game phase watch: $sessionId',
        e,
        stackTrace,
      );
      return Stream.value(
        Result.failure(
          FirestoreException(
            message: 'Failed to watch game phase: ${e.toString()}',
            code: 'phase_watch_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Update game phase with real-time broadcast
  Future<Result<void>> updateGamePhase({
    required String sessionId,
    required int questionIndex,
    required String phase,
    required DateTime phaseStartTime,
    required int phaseDurationSeconds,
  }) async {
    try {
      final result = await _dataSource.updateQuestionPhase(
        sessionId: sessionId,
        questionIndex: questionIndex,
        phase: phase,
        phaseStartTime: phaseStartTime,
        phaseDurationSeconds: phaseDurationSeconds,
      );

      return result.when(
        success: (_) {
          AppLogger.firebase(
            'GameStateSyncService',
            'Phase updated: $sessionId -> q$questionIndex:$phase',
          );
          return const Result.success(null);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update game phase: $sessionId', e, stackTrace);
      return Result.failure(
        ServerException(
          message: 'Failed to update game phase: ${e.toString()}',
          code: 'phase_update_error',
        ).toFailure(),
      );
    }
  }

  /// Sync player connections and status
  Stream<Result<List<PlayerConnectionStatus>>> watchPlayerConnections(
    String sessionId,
  ) {
    try {
      return startSessionSync(sessionId).map((sessionResult) {
        return sessionResult.when(
          success: (session) {
            final connections = session.players.entries.map((entry) {
              return PlayerConnectionStatus(
                playerId: entry.key,
                playerName: entry.value.name,
                isConnected: true, // Assume connected if in session
                isReady: entry.value.isReady,
                lastSeen: DateTime.now(), // Would need to track this properly
                score: entry.value.score,
                answersCount: entry.value.answers.length,
              );
            }).toList();

            return Result.success(connections);
          },
          failure: (error) => Result.failure(error),
        );
      });
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to watch player connections: $sessionId',
        e,
        stackTrace,
      );
      return Stream.value(
        Result.failure(
          ServerException(
            message: 'Failed to watch player connections: ${e.toString()}',
            code: 'watch_connections_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Broadcast host message to all players
  Future<Result<void>> broadcastHostMessage({
    required String sessionId,
    required String message,
    required String messageType,
  }) async {
    try {
      // Create a temporary notification document for real-time broadcast
      final notificationRef = FirestoreConfig.getDocument(
        'game_sessions',
        sessionId,
      ).collection('host_messages').doc();

      await notificationRef.set({
        'message': message,
        'messageType': messageType,
        'timestamp': FieldValue.serverTimestamp(),
        'hostId': await _getCurrentHostId(sessionId),
      });

      // Auto-delete after 30 seconds to keep collection clean
      Timer(const Duration(seconds: 30), () async {
        try {
          await notificationRef.delete();
        } catch (e) {
          AppLogger.warning('Failed to cleanup host message', e);
        }
      });

      AppLogger.firebase(
        'GameStateSyncService',
        'Broadcast host message in session: $sessionId',
      );

      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to broadcast host message: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        ServerException(
          message: 'Failed to broadcast message: ${e.toString()}',
          code: 'broadcast_error',
        ).toFailure(),
      );
    }
  }

  /// Watch for host messages
  Stream<Result<HostMessage>> watchHostMessages(String sessionId) {
    try {
      return FirestoreConfig.getDocument('game_sessions', sessionId)
          .collection('host_messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .map<Result<HostMessage>>((snapshot) {
            if (snapshot.docs.isEmpty) {
              return Result.failure(
                const ServerException(
                  message: 'No host messages',
                  code: 'no_messages',
                ).toFailure(),
              );
            }

            final doc = snapshot.docs.first;
            final data = doc.data();

            final message = HostMessage(
              id: doc.id,
              sessionId: sessionId,
              message: data['message'] ?? '',
              messageType: data['messageType'] ?? 'info',
              timestamp: data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate()
                  : DateTime.now(),
              hostId: data['hostId'] ?? '',
            );

            return Result.success(message);
          })
          .handleError((error) {
            AppLogger.error('Host messages watch error: $sessionId', error);
          });
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to watch host messages: $sessionId',
        e,
        stackTrace,
      );
      return Stream.value(
        Result.failure(
          ServerException(
            message: 'Failed to watch host messages: ${e.toString()}',
            code: 'watch_messages_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Get current host ID for a session
  Future<String> _getCurrentHostId(String sessionId) async {
    try {
      final result = await _dataSource.getGameSessionById(sessionId);
      return result.when(
        success: (session) => session.hostId,
        failure: (_) => '',
      );
    } catch (e) {
      AppLogger.error('Failed to get host ID: $sessionId', e);
      return '';
    }
  }

  /// Force refresh session data from server
  Future<Result<GameSessionEntity>> forceRefreshSession(
    String sessionId,
  ) async {
    try {
      final doc = await FirestoreConfig.getDocument(
        'game_sessions',
        sessionId,
      ).get(const GetOptions(source: Source.server));

      if (!doc.exists) {
        return Result.failure(
          const FirestoreException(
            message: 'Game session not found',
            code: 'session_not_found',
          ).toFailure(),
        );
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      final session = GameSessionEntity.fromMap(data);
      return Result.success(session);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to force refresh session: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to refresh session: ${e.toString()}',
          code: 'refresh_error',
        ).toFailure(),
      );
    }
  }

  /// Cleanup all active synchronizations
  void dispose() {
    for (final sessionId in _sessionControllers.keys.toList()) {
      stopSessionSync(sessionId);
    }
    AppLogger.firebase('GameStateSyncService', 'Disposed all session syncs');
  }
}

/// Game phase update data model
class GamePhaseUpdate {
  final String sessionId;
  final int currentQuestionIndex;
  final String phase;
  final DateTime? phaseStartTime;
  final DateTime? phaseEndTime;
  final GameSessionStatus status;
  final DateTime updatedAt;

  const GamePhaseUpdate({
    required this.sessionId,
    required this.currentQuestionIndex,
    required this.phase,
    this.phaseStartTime,
    this.phaseEndTime,
    required this.status,
    required this.updatedAt,
  });

  Duration? get remainingTime {
    if (phaseEndTime == null) return null;
    final now = DateTime.now();
    if (now.isAfter(phaseEndTime!)) return Duration.zero;
    return phaseEndTime!.difference(now);
  }

  bool get isActive => phase != 'waiting' && status == GameSessionStatus.active;
}

/// Player connection status data model
class PlayerConnectionStatus {
  final String playerId;
  final String playerName;
  final bool isConnected;
  final bool isReady;
  final DateTime lastSeen;
  final int score;
  final int answersCount;

  const PlayerConnectionStatus({
    required this.playerId,
    required this.playerName,
    required this.isConnected,
    required this.isReady,
    required this.lastSeen,
    required this.score,
    required this.answersCount,
  });

  Duration get timeSinceLastSeen => DateTime.now().difference(lastSeen);
  bool get isOnline => isConnected && timeSinceLastSeen.inMinutes < 2;
}

/// Host message data model
class HostMessage {
  final String id;
  final String sessionId;
  final String message;
  final String messageType;
  final DateTime timestamp;
  final String hostId;

  const HostMessage({
    required this.id,
    required this.sessionId,
    required this.message,
    required this.messageType,
    required this.timestamp,
    required this.hostId,
  });
}
