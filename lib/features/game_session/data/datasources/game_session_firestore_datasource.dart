import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/exception_mapper.dart';
import '../../../../core/base/base_datasource.dart';
import '../models/game_session_model.dart';
import '../../domain/entities/game_session_entity.dart';

/// Game Session Firestore data source implementation
/// Following CLAUDE.md patterns and Firestore integration with real-time support
class GameSessionFirestoreDataSource extends BaseFirebaseDataSource {
  static const String _collection = 'game_sessions';

  /// Create new game session with unique PIN
  Future<Result<GameSessionModel>> createGameSession(
    GameSessionModel gameSession,
  ) async {
    try {
      final startTime = DateTime.now();

      // Generate unique 6-digit PIN
      final pin = await _generateUniquePin();
      final sessionWithPin = gameSession.copyWith(pin: pin);

      final data = sessionWithPin.toFirestore();
      data.remove('id'); // Remove ID for creation

      final docRef = await FirestoreConfig.gameSessionsCollection.add(data);

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Create game session', duration);

      final createdSession = sessionWithPin.copyWith(id: docRef.id);

      AppLogger.firebase(
        'GameSessionDataSource',
        'Created game session: ${createdSession.id} with PIN: ${createdSession.pin}',
      );
      return Result.success(createdSession);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create game session', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to create game session: ${e.toString()}',
          code: 'create_game_session_error',
        ).toFailure(),
      );
    }
  }

  /// Get game session by ID
  Future<Result<GameSessionModel>> getGameSessionById(String sessionId) async {
    try {
      final startTime = DateTime.now();

      final doc = await FirestoreConfig.getDocument(
        _collection,
        sessionId,
      ).get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get game session by ID', duration);

      if (!doc.exists) {
        return Result.failure(
          const FirestoreException(
            message: 'Game session not found',
            code: 'game_session_not_found',
          ).toFailure(),
        );
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      final gameSession = GameSessionModel.fromFirestore(data);
      return Result.success(gameSession);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get game session by ID: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to get game session: ${e.toString()}',
          code: 'get_game_session_error',
        ).toFailure(),
      );
    }
  }

  /// Get game session by PIN
  Future<Result<GameSessionModel>> getGameSessionByPin(String pin) async {
    try {
      final startTime = DateTime.now();

      final query = await FirestoreConfig.gameSessionsCollection
          .where('pin', isEqualTo: pin)
          .limit(1)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get game session by PIN', duration);

      if (query.docs.isEmpty) {
        return Result.failure(
          const FirestoreException(
            message: 'Game session not found',
            code: 'game_session_not_found',
          ).toFailure(),
        );
      }

      final doc = query.docs.first;
      final data = doc.data();
      data['id'] = doc.id;

      final gameSession = GameSessionModel.fromFirestore(data);
      return Result.success(gameSession);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get game session by PIN: $pin', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get game session: ${e.toString()}',
          code: 'get_game_session_error',
        ).toFailure(),
      );
    }
  }

  /// Update game session
  Future<Result<GameSessionModel>> updateGameSession(
    GameSessionModel gameSession,
  ) async {
    try {
      final startTime = DateTime.now();

      final data = gameSession.toFirestore();
      data.remove('id'); // Remove ID for update
      data.remove('createdAt'); // Don't update creation timestamp

      await FirestoreConfig.getDocument(
        _collection,
        gameSession.id,
      ).update(data);

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Update game session', duration);

      AppLogger.firebase(
        'GameSessionDataSource',
        'Updated game session: ${gameSession.id}',
      );
      return Result.success(gameSession);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update game session: ${gameSession.id}',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to update game session: ${e.toString()}',
          code: 'update_game_session_error',
        ).toFailure(),
      );
    }
  }

  /// Join game session
  Future<Result<GameSessionModel>> joinGameSession(
    String sessionId,
    String playerId,
    String playerName,
  ) async {
    try {
      final startTime = DateTime.now();

      // Use transaction to ensure atomic update
      final result = await FirestoreConfig.runTransaction<GameSessionModel>((
        transaction,
      ) async {
        final docRef = FirestoreConfig.getDocument(_collection, sessionId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw const FirestoreException(
            message: 'Game session not found',
            code: 'game_session_not_found',
          );
        }

        final data = doc.data()!;
        data['id'] = doc.id;
        final gameSession = GameSessionModel.fromFirestore(data);

        // Check if player can join
        if (gameSession.status != GameSessionStatus.waiting) {
          throw const FirestoreException(
            message: 'Game session is not accepting new players',
            code: 'game_session_not_joinable',
          );
        }

        if (gameSession.players.containsKey(playerId)) {
          throw const FirestoreException(
            message: 'Player already in session',
            code: 'player_already_joined',
          );
        }

        final maxPlayers = gameSession.settings?.maxPlayers ?? 50;
        if (gameSession.players.length >= maxPlayers) {
          throw const FirestoreException(
            message: 'Game session is full',
            code: 'game_session_full',
          );
        }

        // Add player
        final newPlayer = PlayerModel(
          name: playerName,
          joinedAt: DateTime.now(),
        );

        final updatedPlayers = Map<String, PlayerModel>.from(
          gameSession.players,
        );
        updatedPlayers[playerId] = newPlayer;

        final updatedSession = gameSession.copyWith(players: updatedPlayers);
        final updateData = updatedSession.toFirestore();
        updateData.remove('id');
        updateData.remove('createdAt');

        transaction.update(docRef, updateData);

        return updatedSession;
      });

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Join game session', duration);

      AppLogger.firebase(
        'GameSessionDataSource',
        'Player $playerId joined session: $sessionId',
      );
      return Result.success(result);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to join game session: $sessionId', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to join game session: ${e.toString()}',
          code: 'join_game_session_error',
        ).toFailure(),
      );
    }
  }

  /// Leave game session
  Future<Result<GameSessionModel>> leaveGameSession(
    String sessionId,
    String playerId,
  ) async {
    try {
      final startTime = DateTime.now();

      // Use transaction to ensure atomic update
      final result = await FirestoreConfig.runTransaction<GameSessionModel>((
        transaction,
      ) async {
        final docRef = FirestoreConfig.getDocument(_collection, sessionId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw const FirestoreException(
            message: 'Game session not found',
            code: 'game_session_not_found',
          );
        }

        final data = doc.data()!;
        data['id'] = doc.id;
        final gameSession = GameSessionModel.fromFirestore(data);

        if (!gameSession.players.containsKey(playerId)) {
          throw const FirestoreException(
            message: 'Player not in session',
            code: 'player_not_in_session',
          );
        }

        // Remove player
        final updatedPlayers = Map<String, PlayerModel>.from(
          gameSession.players,
        );
        updatedPlayers.remove(playerId);

        final updatedSession = gameSession.copyWith(players: updatedPlayers);
        final updateData = updatedSession.toFirestore();
        updateData.remove('id');
        updateData.remove('createdAt');

        transaction.update(docRef, updateData);

        return updatedSession;
      });

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Leave game session', duration);

      AppLogger.firebase(
        'GameSessionDataSource',
        'Player $playerId left session: $sessionId',
      );
      return Result.success(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to leave game session: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to leave game session: ${e.toString()}',
          code: 'leave_game_session_error',
        ).toFailure(),
      );
    }
  }

  /// Update player score
  Future<Result<GameSessionModel>> updatePlayerScore(
    String sessionId,
    String playerId,
    int score,
    List<int> answers,
  ) async {
    try {
      final startTime = DateTime.now();

      // Use transaction to ensure atomic update
      final result = await FirestoreConfig.runTransaction<GameSessionModel>((
        transaction,
      ) async {
        final docRef = FirestoreConfig.getDocument(_collection, sessionId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw const FirestoreException(
            message: 'Game session not found',
            code: 'game_session_not_found',
          );
        }

        final data = doc.data()!;
        data['id'] = doc.id;
        final gameSession = GameSessionModel.fromFirestore(data);

        if (!gameSession.players.containsKey(playerId)) {
          throw const FirestoreException(
            message: 'Player not in session',
            code: 'player_not_in_session',
          );
        }

        // Update player score and answers
        final updatedPlayers = Map<String, PlayerModel>.from(
          gameSession.players,
        );
        final currentPlayer = updatedPlayers[playerId]!;
        updatedPlayers[playerId] = currentPlayer.copyWith(
          score: score,
          answers: answers,
        );

        final updatedSession = gameSession.copyWith(players: updatedPlayers);
        final updateData = updatedSession.toFirestore();
        updateData.remove('id');
        updateData.remove('createdAt');

        transaction.update(docRef, updateData);

        return updatedSession;
      });

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Update player score', duration);

      AppLogger.firebase(
        'GameSessionDataSource',
        'Updated score for player $playerId in session: $sessionId',
      );
      return Result.success(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update player score: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to update player score: ${e.toString()}',
          code: 'update_player_score_error',
        ).toFailure(),
      );
    }
  }

  /// Get active game sessions
  Future<Result<List<GameSessionModel>>> getActiveGameSessions({
    int limit = 20,
  }) async {
    try {
      final startTime = DateTime.now();

      final query = await FirestoreConfig.gameSessionsCollection
          .where(
            'status',
            whereIn: [
              GameSessionStatus.waiting.name,
              GameSessionStatus.active.name,
            ],
          )
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get active game sessions', duration);

      final sessions = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GameSessionModel.fromFirestore(data);
      }).toList();

      return Result.success(sessions);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get active game sessions', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get active sessions: ${e.toString()}',
          code: 'get_active_sessions_error',
        ).toFailure(),
      );
    }
  }

  /// Stream game session for real-time updates (CRITICAL for multiplayer)
  Stream<Result<GameSessionModel>> watchGameSession(String sessionId) {
    try {
      return FirestoreConfig.getDocument(_collection, sessionId)
          .snapshots()
          .map<Result<GameSessionModel>>((doc) {
            if (!doc.exists) {
              return Result.failure(
                const FirestoreException(
                  message: 'Game session not found',
                  code: 'game_session_not_found',
                ).toFailure(),
              );
            }

            final data = doc.data()!;
            data['id'] = doc.id;

            final gameSession = GameSessionModel.fromFirestore(data);
            return Result.success(gameSession);
          })
          .handleError((error, stackTrace) {
            AppLogger.error(
              'Error watching game session: $sessionId',
              error,
              stackTrace,
            );
          });
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to setup game session watch: $sessionId',
        e,
        stackTrace,
      );
      return Stream.value(
        Result.failure(
          FirestoreException(
            message: 'Failed to setup game session watch: ${e.toString()}',
            code: 'watch_setup_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Clean up expired sessions
  Future<Result<void>> cleanupExpiredSessions() async {
    try {
      final startTime = DateTime.now();

      final cutoffDate = DateTime.now().subtract(const Duration(hours: 24));

      final query = await FirestoreConfig.gameSessionsCollection
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = FirestoreConfig.getBatch();
      for (final doc in query.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Cleanup expired sessions', duration);

      AppLogger.firebase(
        'GameSessionDataSource',
        'Cleaned up ${query.docs.length} expired sessions',
      );
      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cleanup expired sessions', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to cleanup expired sessions: ${e.toString()}',
          code: 'cleanup_sessions_error',
        ).toFailure(),
      );
    }
  }

  /// Delete game session
  Future<Result<void>> deleteGameSession(String sessionId) async {
    try {
      final startTime = DateTime.now();

      await FirestoreConfig.getDocument(_collection, sessionId).delete();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Delete game session', duration);

      AppLogger.firebase(
        'GameSessionDataSource',
        'Deleted session: $sessionId',
      );
      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete game session: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to delete game session: ${e.toString()}',
          code: 'delete_game_session_error',
        ).toFailure(),
      );
    }
  }

  /// Generate unique 6-digit PIN
  Future<String> _generateUniquePin() async {
    final random = Random();
    const maxAttempts = 100;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      // Generate 6-digit PIN
      final pin = (100000 + random.nextInt(900000)).toString();

      // Check if PIN is already in use
      final query = await FirestoreConfig.gameSessionsCollection
          .where('pin', isEqualTo: pin)
          .where(
            'status',
            whereIn: [
              GameSessionStatus.waiting.name,
              GameSessionStatus.active.name,
            ],
          )
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return pin;
      }
    }

    // Fallback: use timestamp-based PIN
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return (timestamp % 1000000).toString().padLeft(6, '0');
  }

  /// Check if PIN exists and is active
  Future<Result<bool>> isPinActive(String pin) async {
    try {
      final startTime = DateTime.now();

      final query = await FirestoreConfig.gameSessionsCollection
          .where('pin', isEqualTo: pin)
          .where(
            'status',
            whereIn: [
              GameSessionStatus.waiting.name,
              GameSessionStatus.active.name,
            ],
          )
          .limit(1)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Check PIN active', duration);

      return Result.success(query.docs.isNotEmpty);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check PIN active: $pin', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to check PIN: ${e.toString()}',
          code: 'check_pin_error',
        ).toFailure(),
      );
    }
  }

  /// Get sessions by host
  Future<Result<List<GameSessionModel>>> getSessionsByHost(
    String hostId, {
    int limit = 20,
  }) async {
    try {
      final startTime = DateTime.now();

      final query = await FirestoreConfig.gameSessionsCollection
          .where('hostId', isEqualTo: hostId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get sessions by host', duration);

      final sessions = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GameSessionModel.fromFirestore(data);
      }).toList();

      return Result.success(sessions);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get sessions by host: $hostId', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get host sessions: ${e.toString()}',
          code: 'get_host_sessions_error',
        ).toFailure(),
      );
    }
  }

  // Repository compatibility methods (aliases)

  /// Add player to session (alias for joinGameSession)
  Future<Result<GameSessionModel>> addPlayerToSession(
    String sessionId,
    String playerId,
    PlayerModel player,
  ) async {
    return joinGameSession(sessionId, playerId, player.name);
  }

  /// Remove player from session (alias for leaveGameSession)
  Future<Result<GameSessionModel>> removePlayerFromSession(
    String sessionId,
    String playerId,
  ) async {
    return leaveGameSession(sessionId, playerId);
  }

  /// Update player in session (alias for updatePlayerScore)
  Future<Result<GameSessionModel>> updatePlayerInSession(
    String sessionId,
    String playerId,
    PlayerModel player,
  ) async {
    return updatePlayerScore(sessionId, playerId, player.score, player.answers);
  }

  /// Start game session
  Future<Result<GameSessionModel>> startGameSession(String sessionId) async {
    try {
      final startTime = DateTime.now();

      // Use transaction to ensure atomic update
      final result = await FirestoreConfig.runTransaction<GameSessionModel>((
        transaction,
      ) async {
        final docRef = FirestoreConfig.getDocument(_collection, sessionId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw const FirestoreException(
            message: 'Game session not found',
            code: 'game_session_not_found',
          );
        }

        final data = doc.data()!;
        data['id'] = doc.id;
        final gameSession = GameSessionModel.fromFirestore(data);

        final updatedSession = gameSession.copyWith(
          status: GameSessionStatus.active,
          startedAt: DateTime.now(),
        );

        final updateData = updatedSession.toFirestore();
        updateData.remove('id');
        updateData.remove('createdAt');

        transaction.update(docRef, updateData);

        return updatedSession;
      });

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Start game session', duration);

      AppLogger.firebase(
        'GameSessionDataSource',
        'Started game session: $sessionId',
      );
      return Result.success(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to start game session: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to start game session: ${e.toString()}',
          code: 'start_game_session_error',
        ).toFailure(),
      );
    }
  }

  /// Complete game session
  Future<Result<GameSessionModel>> completeGameSession(String sessionId) async {
    try {
      final startTime = DateTime.now();

      // Use transaction to ensure atomic update
      final result = await FirestoreConfig.runTransaction<GameSessionModel>((
        transaction,
      ) async {
        final docRef = FirestoreConfig.getDocument(_collection, sessionId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw const FirestoreException(
            message: 'Game session not found',
            code: 'game_session_not_found',
          );
        }

        final data = doc.data()!;
        data['id'] = doc.id;
        final gameSession = GameSessionModel.fromFirestore(data);

        final updatedSession = gameSession.copyWith(
          status: GameSessionStatus.completed,
          completedAt: DateTime.now(),
        );

        final updateData = updatedSession.toFirestore();
        updateData.remove('id');
        updateData.remove('createdAt');

        transaction.update(docRef, updateData);

        return updatedSession;
      });

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Complete game session', duration);

      AppLogger.firebase(
        'GameSessionDataSource',
        'Completed game session: $sessionId',
      );
      return Result.success(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to complete game session: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to complete game session: ${e.toString()}',
          code: 'complete_game_session_error',
        ).toFailure(),
      );
    }
  }

  /// Update current question index
  Future<Result<GameSessionModel>> updateCurrentQuestion(
    String sessionId,
    int questionIndex,
  ) async {
    try {
      final startTime = DateTime.now();

      // Use transaction to ensure atomic update
      final result = await FirestoreConfig.runTransaction<GameSessionModel>((
        transaction,
      ) async {
        final docRef = FirestoreConfig.getDocument(_collection, sessionId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw const FirestoreException(
            message: 'Game session not found',
            code: 'game_session_not_found',
          );
        }

        final data = doc.data()!;
        data['id'] = doc.id;
        final gameSession = GameSessionModel.fromFirestore(data);

        final updatedSession = gameSession.copyWith(
          currentQuestionIndex: questionIndex,
        );

        final updateData = updatedSession.toFirestore();
        updateData.remove('id');
        updateData.remove('createdAt');

        transaction.update(docRef, updateData);

        return updatedSession;
      });

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Update current question', duration);

      AppLogger.firebase(
        'GameSessionDataSource',
        'Updated current question for session: $sessionId to index: $questionIndex',
      );
      return Result.success(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update current question: $sessionId',
        e,
        stackTrace,
      );
      return Result.failure(
        FirestoreException(
          message: 'Failed to update current question: ${e.toString()}',
          code: 'update_current_question_error',
        ).toFailure(),
      );
    }
  }

  // Additional repository compatibility methods

  /// Get game sessions by host (alias for getSessionsByHost)
  Future<Result<List<GameSessionModel>>> getGameSessionsByHost(
    String hostId, {
    int limit = 20,
  }) async {
    return getSessionsByHost(hostId, limit: limit);
  }

  /// Get game sessions by quiz
  Future<Result<List<GameSessionModel>>> getGameSessionsByQuiz(
    String quizId, {
    int limit = 20,
  }) async {
    try {
      final startTime = DateTime.now();

      final query = await FirestoreConfig.gameSessionsCollection
          .where('quizId', isEqualTo: quizId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get sessions by quiz', duration);

      final sessions = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GameSessionModel.fromFirestore(data);
      }).toList();

      return Result.success(sessions);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get sessions by quiz: $quizId', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get quiz sessions: ${e.toString()}',
          code: 'get_quiz_sessions_error',
        ).toFailure(),
      );
    }
  }

  /// Get recent game sessions
  Future<Result<List<GameSessionModel>>> getRecentGameSessions({
    int limit = 20,
    int daysBack = 7,
  }) async {
    try {
      final startTime = DateTime.now();

      final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));

      final query = await FirestoreConfig.gameSessionsCollection
          .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffDate))
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get recent sessions', duration);

      final sessions = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GameSessionModel.fromFirestore(data);
      }).toList();

      return Result.success(sessions);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get recent sessions', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get recent sessions: ${e.toString()}',
          code: 'get_recent_sessions_error',
        ).toFailure(),
      );
    }
  }

  /// Check if PIN is available (alias for isPinActive with negation)
  Future<Result<bool>> isPinAvailable(String pin) async {
    final result = await isPinActive(pin);
    return result.when(
      success: (isActive) => Result.success(!isActive),
      failure: (error) => Result.failure(error),
    );
  }

  /// Get expired sessions
  Future<Result<List<GameSessionModel>>> getExpiredSessions({
    int limit = 50,
  }) async {
    try {
      final startTime = DateTime.now();

      final cutoffDate = DateTime.now().subtract(const Duration(hours: 24));

      final query = await FirestoreConfig.gameSessionsCollection
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .limit(limit)
          .get();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Get expired sessions', duration);

      final sessions = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GameSessionModel.fromFirestore(data);
      }).toList();

      return Result.success(sessions);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get expired sessions', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to get expired sessions: ${e.toString()}',
          code: 'get_expired_sessions_error',
        ).toFailure(),
      );
    }
  }

  /// Watch active game sessions stream
  Stream<Result<List<GameSessionModel>>> watchActiveGameSessions({
    int limit = 20,
  }) {
    try {
      return FirestoreConfig.gameSessionsCollection
          .where(
            'status',
            whereIn: [
              GameSessionStatus.waiting.name,
              GameSessionStatus.active.name,
            ],
          )
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map<Result<List<GameSessionModel>>>((snapshot) {
            final sessions = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return GameSessionModel.fromFirestore(data);
            }).toList();

            return Result.success(sessions);
          })
          .handleError((error, stackTrace) {
            AppLogger.error(
              'Error watching active sessions',
              error,
              stackTrace,
            );
          });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to setup active sessions watch', e, stackTrace);
      return Stream.value(
        Result.failure(
          FirestoreException(
            message: 'Failed to setup active sessions watch: ${e.toString()}',
            code: 'watch_active_sessions_error',
          ).toFailure(),
        ),
      );
    }
  }

  /// Batch update multiple sessions
  Future<Result<void>> batchUpdateSessions(
    List<GameSessionModel> sessions,
  ) async {
    try {
      final startTime = DateTime.now();

      final batch = FirestoreConfig.getBatch();

      for (final session in sessions) {
        final data = session.toFirestore();
        data.remove('id');
        data.remove('createdAt');

        final docRef = FirestoreConfig.getDocument(_collection, session.id);
        batch.update(docRef, data);
      }

      await batch.commit();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Batch update sessions', duration);

      AppLogger.firebase(
        'GameSessionDataSource',
        'Batch updated ${sessions.length} sessions',
      );
      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to batch update sessions', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to batch update sessions: ${e.toString()}',
          code: 'batch_update_sessions_error',
        ).toFailure(),
      );
    }
  }

  /// Batch delete multiple sessions
  Future<Result<void>> batchDeleteSessions(List<String> sessionIds) async {
    try {
      final startTime = DateTime.now();

      final batch = FirestoreConfig.getBatch();

      for (final sessionId in sessionIds) {
        final docRef = FirestoreConfig.getDocument(_collection, sessionId);
        batch.delete(docRef);
      }

      await batch.commit();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Batch delete sessions', duration);

      AppLogger.firebase(
        'GameSessionDataSource',
        'Batch deleted ${sessionIds.length} sessions',
      );
      return const Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to batch delete sessions', e, stackTrace);
      return Result.failure(
        FirestoreException(
          message: 'Failed to batch delete sessions: ${e.toString()}',
          code: 'batch_delete_sessions_error',
        ).toFailure(),
      );
    }
  }

  /// Get session analytics
  Future<Result<Map<String, dynamic>>> getSessionAnalytics(
    String sessionId,
  ) async {
    try {
      final sessionResult = await getGameSessionById(sessionId);
      return sessionResult.when(
        success: (session) {
          // Calculate analytics based on session data
          final analytics = {
            'totalPlayers': session.players.length,
            'averageScore': session.players.isEmpty
                ? 0.0
                : session.players.values
                          .map((p) => p.score)
                          .reduce((a, b) => a + b) /
                      session.players.length,
            'completionRate': session.status == GameSessionStatus.completed
                ? 1.0
                : 0.0,
            'sessionDuration':
                session.completedAt
                    ?.difference(session.startedAt ?? session.createdAt)
                    .inMinutes ??
                0,
          };

          return Result.success(analytics);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get session analytics: ${e.toString()}',
          code: 'analytics_error',
        ).toFailure(),
      );
    }
  }

  /// Get host analytics
  Future<Result<Map<String, dynamic>>> getHostAnalytics(String hostId) async {
    try {
      final sessionsResult = await getGameSessionsByHost(hostId);
      return sessionsResult.when(
        success: (sessions) {
          // Calculate host analytics
          final analytics = {
            'totalSessions': sessions.length,
            'totalPlayers': sessions.fold(
              0,
              (total, session) => total + session.players.length,
            ),
            'averagePlayersPerSession': sessions.isEmpty
                ? 0.0
                : sessions.fold(
                        0,
                        (total, session) => total + session.players.length,
                      ) /
                      sessions.length,
            'completedSessions': sessions
                .where((s) => s.status == GameSessionStatus.completed)
                .length,
          };

          return Result.success(analytics);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        ServerException(
          message: 'Failed to get host analytics: ${e.toString()}',
          code: 'host_analytics_error',
        ).toFailure(),
      );
    }
  }
}
