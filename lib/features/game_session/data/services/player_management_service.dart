import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../../../../core/firebase/firestore_config.dart';
import '../datasources/game_session_firestore_datasource.dart';
import '../models/game_session_model.dart';
import '../../domain/entities/game_session_entity.dart';

/// Player management service for real-time multiplayer features
/// Handles joining, leaving, ready states, and player activity tracking
class PlayerManagementService {
  final GameSessionFirestoreDataSource _dataSource;
  final Map<String, Timer> _playerHeartbeats = {};
  final Map<String, StreamSubscription> _playerWatchers = {};

  PlayerManagementService({required GameSessionFirestoreDataSource dataSource})
    : _dataSource = dataSource;

  /// Join game session with PIN validation and real-time setup
  Future<Result<GameSessionEntity>> joinSessionWithPin({
    required String pin,
    required String playerId,
    required String playerName,
  }) async {
    try {
      AppLogger.firebase(
        'PlayerManagementService',
        'Attempting to join session with PIN: $pin, Player: $playerName',
      );

      // Get session by PIN first
      final sessionResult = await _dataSource.getGameSessionByPin(pin);

      return await sessionResult.when(
        success: (session) async {
          // Validate session can accept new players
          if (session.status != GameSessionStatus.waiting) {
            return Result.failure(
              const ValidationException(
                message: 'Game session is not accepting new players',
              ).toFailure(),
            );
          }

          if (session.players.containsKey(playerId)) {
            return Result.failure(
              const ValidationException(
                message: 'Player already in this session',
              ).toFailure(),
            );
          }

          final maxPlayers = session.settings?.maxPlayers ?? 50;
          if (session.players.length >= maxPlayers) {
            return Result.failure(
              const ValidationException(
                message: 'Game session is full',
              ).toFailure(),
            );
          }

          // Join the session
          final joinResult = await _dataSource.joinGameSession(
            session.id,
            playerId,
            playerName,
          );

          return joinResult.when(
            success: (updatedSession) {
              AppLogger.firebase(
                'PlayerManagementService',
                'Player $playerName joined session ${session.id} successfully',
              );

              // Start player activity tracking
              _startPlayerHeartbeat(session.id, playerId);

              return Result.success(updatedSession.toEntity());
            },
            failure: (error) => Result.failure(error),
          );
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to join session with PIN: $pin', e, stackTrace);
      return Result.failure(
        ServerException(
          message: 'Failed to join session: ${e.toString()}',
          code: 'join_session_error',
        ).toFailure(),
      );
    }
  }

  /// Leave game session with cleanup
  Future<Result<GameSessionEntity>> leaveSession({
    required String sessionId,
    required String playerId,
  }) async {
    try {
      // Stop player heartbeat
      _stopPlayerHeartbeat(sessionId, playerId);

      final result = await _dataSource.leaveGameSession(sessionId, playerId);

      return result.when(
        success: (session) {
          AppLogger.firebase(
            'PlayerManagementService',
            'Player $playerId left session $sessionId',
          );
          return Result.success(session.toEntity());
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to leave session: $sessionId', e, stackTrace);
      return Result.failure(
        ServerException(
          message: 'Failed to leave session: ${e.toString()}',
          code: 'leave_session_error',
        ).toFailure(),
      );
    }
  }

  /// Set player ready status with validation
  Future<Result<GameSessionEntity>> setPlayerReady({
    required String sessionId,
    required String playerId,
    required bool isReady,
  }) async {
    try {
      final result = await _dataSource.setPlayerReady(
        sessionId,
        playerId,
        isReady,
      );

      return result.when(
        success: (session) {
          AppLogger.firebase(
            'PlayerManagementService',
            'Player $playerId ready status: $isReady in session $sessionId',
          );
          return Result.success(session.toEntity());
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set player ready: $sessionId', e, stackTrace);
      return Result.failure(
        ServerException(
          message: 'Failed to set player ready: ${e.toString()}',
          code: 'set_ready_error',
        ).toFailure(),
      );
    }
  }

  /// Watch real-time player list changes
  Stream<Result<List<PlayerInfo>>> watchPlayerList(String sessionId) {
    try {
      return FirestoreConfig.getDocument('game_sessions', sessionId)
          .snapshots()
          .map<Result<List<PlayerInfo>>>((doc) {
            if (!doc.exists) {
              return Result.failure(
                const FirestoreException(
                  message: 'Game session not found',
                  code: 'session_not_found',
                ).toFailure(),
              );
            }

            final data = doc.data()!;
            final playersData = data['players'] as Map<String, dynamic>? ?? {};

            final players = playersData.entries.map((entry) {
              final playerData = entry.value as Map<String, dynamic>;
              return PlayerInfo(
                id: entry.key,
                name: playerData['name'] ?? '',
                score: playerData['score'] ?? 0,
                isReady: playerData['isReady'] ?? false,
                joinedAt: playerData['joinedAt'] != null
                    ? (playerData['joinedAt'] as Timestamp).toDate()
                    : DateTime.now(),
                answersCount: (playerData['answers'] as List?)?.length ?? 0,
                isOnline: true, // Assume online if in Firestore
              );
            }).toList();

            // Sort by join order
            players.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

            return Result.success(players);
          })
          .handleError((error) {
            AppLogger.error('Player list watch error: $sessionId', error);
          });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to watch player list: $sessionId', e, stackTrace);
      return Stream.value(
        Result.failure(
          ServerException(
            message: 'Failed to watch player list: ${e.toString()}',
            code: 'watch_players_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Get player statistics
  Future<Result<PlayerStatistics>> getPlayerStatistics({
    required String sessionId,
    required String playerId,
  }) async {
    try {
      final sessionResult = await _dataSource.getGameSessionById(sessionId);

      return sessionResult.when(
        success: (session) {
          final player = session.players[playerId];
          if (player == null) {
            return Result.failure(
              const ValidationException(
                message: 'Player not found in session',
              ).toFailure(),
            );
          }

          final stats = PlayerStatistics(
            playerId: playerId,
            sessionId: sessionId,
            playerName: player.name,
            currentScore: player.score,
            totalAnswers: player.answers.length,
            correctAnswers: 0, // Would need question data to calculate
            averageResponseTime: 0, // Would need timing data
            rank: _calculatePlayerRank(session.toEntity(), playerId),
            sessionTime: DateTime.now().difference(player.joinedAt),
            isReady: player.isReady,
          );

          return Result.success(stats);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get player statistics: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        ServerException(
          message: 'Failed to get player statistics: ${e.toString()}',
          code: 'get_stats_error',
        ).toFailure(),
      );
    }
  }

  /// Kick player from session (host only)
  Future<Result<GameSessionEntity>> kickPlayer({
    required String sessionId,
    required String hostId,
    required String playerId,
    required String reason,
  }) async {
    try {
      // Validate host permissions
      final sessionResult = await _dataSource.getGameSessionById(sessionId);

      return await sessionResult.when(
        success: (session) async {
          if (session.hostId != hostId) {
            return Result.failure(
              const UnauthorizedException(
                message: 'Only the host can kick players',
              ).toFailure(),
            );
          }

          if (!session.players.containsKey(playerId)) {
            return Result.failure(
              const ValidationException(
                message: 'Player not found in session',
              ).toFailure(),
            );
          }

          // Remove player and log action
          final result = await _dataSource.leaveGameSession(
            sessionId,
            playerId,
          );

          return result.when(
            success: (updatedSession) {
              AppLogger.firebase(
                'PlayerManagementService',
                'Player $playerId kicked from session $sessionId by host. Reason: $reason',
              );

              // Stop heartbeat for kicked player
              _stopPlayerHeartbeat(sessionId, playerId);

              return Result.success(updatedSession.toEntity());
            },
            failure: (error) => Result.failure(error),
          );
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to kick player: $sessionId', e, stackTrace);
      return Result.failure(
        ServerException(
          message: 'Failed to kick player: ${e.toString()}',
          code: 'kick_player_error',
        ).toFailure(),
      );
    }
  }

  /// Validate nickname uniqueness in session
  Future<Result<bool>> validateNickname({
    required String sessionId,
    required String nickname,
    String? excludePlayerId,
  }) async {
    try {
      final sessionResult = await _dataSource.getGameSessionById(sessionId);

      return sessionResult.when(
        success: (session) {
          final isUnique = !session.players.entries.any(
            (entry) =>
                entry.key != excludePlayerId &&
                entry.value.name.toLowerCase() == nickname.toLowerCase(),
          );

          return Result.success(isUnique);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to validate nickname: $sessionId', e, stackTrace);
      return Result.failure(
        ServerException(
          message: 'Failed to validate nickname: ${e.toString()}',
          code: 'validate_nickname_error',
        ).toFailure(),
      );
    }
  }

  /// Start player heartbeat for connection monitoring
  void _startPlayerHeartbeat(String sessionId, String playerId) {
    final key = '$sessionId:$playerId';

    // Cancel existing heartbeat if any
    _playerHeartbeats[key]?.cancel();

    // Update player last seen every 30 seconds
    _playerHeartbeats[key] = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      try {
        await FirestoreConfig.getDocument(
          'game_sessions',
          sessionId,
        ).update({'players.$playerId.lastSeen': FieldValue.serverTimestamp()});
      } catch (e) {
        AppLogger.warning('Player heartbeat update failed: $key', e);
        // Don't cancel timer - network might be temporary
      }
    });

    AppLogger.firebase(
      'PlayerManagementService',
      'Started heartbeat for player: $key',
    );
  }

  /// Stop player heartbeat
  void _stopPlayerHeartbeat(String sessionId, String playerId) {
    final key = '$sessionId:$playerId';
    _playerHeartbeats[key]?.cancel();
    _playerHeartbeats.remove(key);

    AppLogger.firebase(
      'PlayerManagementService',
      'Stopped heartbeat for player: $key',
    );
  }

  /// Calculate player rank within session
  int _calculatePlayerRank(GameSessionEntity session, String playerId) {
    final player = session.players[playerId];
    if (player == null) return 0;

    final sortedPlayers = session.players.values.toList();
    sortedPlayers.sort((a, b) => b.score.compareTo(a.score));

    return sortedPlayers.indexOf(player) + 1;
  }

  /// Get session capacity info
  Future<Result<SessionCapacity>> getSessionCapacity(String sessionId) async {
    try {
      final sessionResult = await _dataSource.getGameSessionById(sessionId);

      return sessionResult.when(
        success: (session) {
          final capacity = SessionCapacity(
            currentPlayers: session.playerCount,
            maxPlayers: session.settings?.maxPlayers ?? 50,
            availableSlots:
                (session.settings?.maxPlayers ?? 50) - session.playerCount,
            canJoin:
                session.status == GameSessionStatus.waiting && !session.isFull,
          );

          return Result.success(capacity);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get session capacity: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        ServerException(
          message: 'Failed to get session capacity: ${e.toString()}',
          code: 'get_capacity_error',
        ).toFailure(),
      );
    }
  }

  /// Cleanup all player resources
  void dispose() {
    for (final timer in _playerHeartbeats.values) {
      timer.cancel();
    }
    _playerHeartbeats.clear();

    for (final subscription in _playerWatchers.values) {
      subscription.cancel();
    }
    _playerWatchers.clear();

    AppLogger.firebase(
      'PlayerManagementService',
      'Disposed all player resources',
    );
  }
}

/// Player information data model
class PlayerInfo {
  final String id;
  final String name;
  final int score;
  final bool isReady;
  final DateTime joinedAt;
  final int answersCount;
  final bool isOnline;

  const PlayerInfo({
    required this.id,
    required this.name,
    required this.score,
    required this.isReady,
    required this.joinedAt,
    required this.answersCount,
    required this.isOnline,
  });

  Duration get timeInSession => DateTime.now().difference(joinedAt);
}

/// Player statistics data model
class PlayerStatistics {
  final String playerId;
  final String sessionId;
  final String playerName;
  final int currentScore;
  final int totalAnswers;
  final int correctAnswers;
  final double averageResponseTime;
  final int rank;
  final Duration sessionTime;
  final bool isReady;

  const PlayerStatistics({
    required this.playerId,
    required this.sessionId,
    required this.playerName,
    required this.currentScore,
    required this.totalAnswers,
    required this.correctAnswers,
    required this.averageResponseTime,
    required this.rank,
    required this.sessionTime,
    required this.isReady,
  });

  double get accuracy => totalAnswers > 0 ? correctAnswers / totalAnswers : 0.0;
  double get scorePerMinute =>
      sessionTime.inMinutes > 0 ? currentScore / sessionTime.inMinutes : 0.0;
}

/// Session capacity data model
class SessionCapacity {
  final int currentPlayers;
  final int maxPlayers;
  final int availableSlots;
  final bool canJoin;

  const SessionCapacity({
    required this.currentPlayers,
    required this.maxPlayers,
    required this.availableSlots,
    required this.canJoin,
  });

  double get fillPercentage =>
      maxPlayers > 0 ? currentPlayers / maxPlayers : 0.0;
  bool get isFull => currentPlayers >= maxPlayers;
}
