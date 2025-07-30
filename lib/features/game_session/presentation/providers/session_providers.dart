import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/game_session_entity.dart';
import '../../data/models/game_session_model.dart';
import '../../data/repositories/game_session_repository_impl.dart';
import '../../data/datasources/game_session_firestore_datasource.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

/// Game session data source provider
final gameSessionDataSourceProvider = Provider<GameSessionFirestoreDataSource>((
  ref,
) {
  return GameSessionFirestoreDataSource();
});

/// Game session repository provider
final gameSessionRepositoryProvider = Provider<GameSessionRepositoryImpl>((
  ref,
) {
  final dataSource = ref.read(gameSessionDataSourceProvider);
  return GameSessionRepositoryImpl(dataSource: dataSource);
});

/// Stream provider for watching a specific game session
final gameSessionStreamProvider =
    StreamProvider.family<GameSessionEntity?, String>((ref, sessionId) {
      final dataSource = ref.read(gameSessionDataSourceProvider);

      AppLogger.firebase(
        'GameSessionProvider',
        'Setting up stream for session: $sessionId',
      );

      return dataSource
          .watchGameSession(sessionId)
          .asyncMap(
            (result) => result.when(
              success: (session) {
                AppLogger.firebase(
                  'GameSessionProvider',
                  'Session data updated: $sessionId',
                );
                return session.toEntity();
              },
              failure: (error) {
                AppLogger.error('Failed to watch session: $sessionId', error);
                return null;
              },
            ),
          );
    });

/// Provider to get a specific game session by ID
final gameSessionProvider = FutureProvider.family<GameSessionEntity?, String>((
  ref,
  sessionId,
) async {
  final dataSource = ref.read(gameSessionDataSourceProvider);

  AppLogger.firebase('GameSessionProvider', 'Fetching session: $sessionId');

  final result = await dataSource.getGameSessionById(sessionId);
  return result.when(
    success: (session) {
      AppLogger.firebase(
        'GameSessionProvider',
        'Session fetched successfully: $sessionId',
      );
      return session.toEntity();
    },
    failure: (error) {
      AppLogger.error('Failed to fetch session: $sessionId', error);
      return null;
    },
  );
});

/// Provider to get a game session by PIN
final gameSessionByPinProvider =
    FutureProvider.family<GameSessionEntity?, String>((ref, pin) async {
      final dataSource = ref.read(gameSessionDataSourceProvider);

      AppLogger.firebase(
        'GameSessionProvider',
        'Fetching session by PIN: $pin',
      );

      final result = await dataSource.getGameSessionByPin(pin);
      return result.when(
        success: (session) {
          AppLogger.firebase(
            'GameSessionProvider',
            'Session found for PIN: $pin',
          );
          return session.toEntity();
        },
        failure: (error) {
          AppLogger.error('Failed to find session for PIN: $pin', error);
          return null;
        },
      );
    });

/// Provider for active game sessions
final activeGameSessionsProvider = FutureProvider<List<GameSessionEntity>>((
  ref,
) async {
  final dataSource = ref.read(gameSessionDataSourceProvider);

  AppLogger.firebase('GameSessionProvider', 'Fetching active game sessions');

  final result = await dataSource.getActiveGameSessions(limit: 20);
  return result.when(
    success: (sessions) {
      AppLogger.firebase(
        'GameSessionProvider',
        'Found ${sessions.length} active sessions',
      );
      return sessions.map((s) => s.toEntity()).toList();
    },
    failure: (error) {
      AppLogger.error('Failed to fetch active sessions', error);
      return [];
    },
  );
});

/// Provider for user's hosted sessions
final userHostedSessionsProvider = FutureProvider<List<GameSessionEntity>>((
  ref,
) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return [];
  }

  final dataSource = ref.read(gameSessionDataSourceProvider);

  AppLogger.firebase(
    'GameSessionProvider',
    'Fetching sessions for host: ${currentUser.id}',
  );

  final result = await dataSource.getGameSessionsByHost(currentUser.id);
  return result.when(
    success: (sessions) {
      AppLogger.firebase(
        'GameSessionProvider',
        'Found ${sessions.length} hosted sessions',
      );
      return sessions.map((s) => s.toEntity()).toList();
    },
    failure: (error) {
      AppLogger.error('Failed to fetch hosted sessions', error);
      return [];
    },
  );
});

/// Provider for checking if a PIN is available
final pinAvailabilityProvider = FutureProvider.family<bool, String>((
  ref,
  pin,
) async {
  final dataSource = ref.read(gameSessionDataSourceProvider);

  AppLogger.firebase('GameSessionProvider', 'Checking PIN availability: $pin');

  final result = await dataSource.isPinAvailable(pin);
  return result.when(
    success: (isAvailable) {
      AppLogger.firebase(
        'GameSessionProvider',
        'PIN $pin availability: $isAvailable',
      );
      return isAvailable;
    },
    failure: (error) {
      AppLogger.error('Failed to check PIN availability: $pin', error);
      return false;
    },
  );
});

/// Session validation provider - validates session access for current user
final sessionValidationProvider =
    FutureProvider.family<SessionValidationResult, String>((
      ref,
      sessionId,
    ) async {
      final currentUser = ref.watch(currentUserProvider);
      if (currentUser == null) {
        return SessionValidationResult.notAuthenticated();
      }

      final sessionResult = await ref.read(
        gameSessionProvider(sessionId).future,
      );
      if (sessionResult == null) {
        return SessionValidationResult.sessionNotFound();
      }

      final session = sessionResult;

      // Check various validation conditions
      if (session.hasExpired) {
        return SessionValidationResult.sessionExpired();
      }

      if (!session.isValid) {
        return SessionValidationResult.sessionInvalid();
      }

      final userId = currentUser.id;
      final isHost = session.isHost(userId);
      final isPlayer = session.isPlayer(userId);
      final canJoin = session.canUserJoin(userId);

      return SessionValidationResult.valid(
        session: session,
        isHost: isHost,
        isPlayer: isPlayer,
        canJoin: canJoin,
      );
    });

/// Current user's role in a specific session
final userSessionRoleProvider = FutureProvider.family<UserSessionRole, String>((
  ref,
  sessionId,
) async {
  final validation = await ref.read(
    sessionValidationProvider(sessionId).future,
  );

  if (!validation.isValid) {
    return UserSessionRole.none;
  }

  if (validation.isHost) {
    return UserSessionRole.host;
  } else if (validation.isPlayer) {
    return UserSessionRole.player;
  } else if (validation.canJoin) {
    return UserSessionRole.canJoin;
  } else {
    return UserSessionRole.spectator;
  }
});

/// Session state notifier for managing session operations
final sessionStateNotifierProvider =
    StateNotifierProvider.family<SessionStateNotifier, SessionState, String>(
      (ref, sessionId) => SessionStateNotifier(
        sessionId: sessionId,
        dataSource: ref.read(gameSessionDataSourceProvider),
        ref: ref,
      ),
    );

/// Session state notifier class
class SessionStateNotifier extends StateNotifier<SessionState> {
  final String sessionId;
  final GameSessionFirestoreDataSource dataSource;
  final Ref ref;

  SessionStateNotifier({
    required this.sessionId,
    required this.dataSource,
    required this.ref,
  }) : super(const SessionState.loading()) {
    _initialize();
  }

  void _initialize() {
    // Listen to session stream
    ref.listen(gameSessionStreamProvider(sessionId), (previous, next) {
      next.when(
        data: (session) {
          if (session != null) {
            state = SessionState.loaded(session);
          } else {
            state = const SessionState.error('Session not found');
          }
        },
        loading: () => state = const SessionState.loading(),
        error: (error, stackTrace) =>
            state = SessionState.error(error.toString()),
      );
    });
  }

  /// Join the session as a player
  Future<void> joinSession(String playerName) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const SessionState.error('User not authenticated');
      return;
    }

    state = const SessionState.loading();

    try {
      final result = await dataSource.joinGameSession(
        sessionId,
        currentUser.id,
        playerName,
      );

      result.when(
        success: (session) {
          AppLogger.firebase(
            'SessionNotifier',
            'Successfully joined session: $sessionId',
          );
          state = SessionState.loaded(session.toEntity());
        },
        failure: (error) {
          AppLogger.error('Failed to join session: $sessionId', error);
          state = SessionState.error(error.userMessage);
        },
      );
    } catch (e) {
      AppLogger.error('Error joining session: $sessionId', e);
      state = SessionState.error('Failed to join session: ${e.toString()}');
    }
  }

  /// Leave the session
  Future<void> leaveSession() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const SessionState.error('User not authenticated');
      return;
    }

    state = const SessionState.loading();

    try {
      final result = await dataSource.leaveGameSession(
        sessionId,
        currentUser.id,
      );

      result.when(
        success: (session) {
          AppLogger.firebase(
            'SessionNotifier',
            'Successfully left session: $sessionId',
          );
          state = SessionState.loaded(session.toEntity());
        },
        failure: (error) {
          AppLogger.error('Failed to leave session: $sessionId', error);
          state = SessionState.error(error.userMessage);
        },
      );
    } catch (e) {
      AppLogger.error('Error leaving session: $sessionId', e);
      state = SessionState.error('Failed to leave session: ${e.toString()}');
    }
  }

  /// Start the session (host only)
  Future<void> startSession() async {
    state = const SessionState.loading();

    try {
      final result = await dataSource.startGameSession(sessionId);

      result.when(
        success: (session) {
          AppLogger.firebase(
            'SessionNotifier',
            'Successfully started session: $sessionId',
          );
          state = SessionState.loaded(session.toEntity());
        },
        failure: (error) {
          AppLogger.error('Failed to start session: $sessionId', error);
          state = SessionState.error(error.userMessage);
        },
      );
    } catch (e) {
      AppLogger.error('Error starting session: $sessionId', e);
      state = SessionState.error('Failed to start session: ${e.toString()}');
    }
  }

  /// Update player score
  Future<void> updatePlayerScore(int score, List<int> answers) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const SessionState.error('User not authenticated');
      return;
    }

    try {
      final result = await dataSource.updatePlayerScore(
        sessionId,
        currentUser.id,
        score,
        answers,
      );

      result.when(
        success: (session) {
          AppLogger.firebase(
            'SessionNotifier',
            'Successfully updated score for session: $sessionId',
          );
          state = SessionState.loaded(session.toEntity());
        },
        failure: (error) {
          AppLogger.error(
            'Failed to update score for session: $sessionId',
            error,
          );
          state = SessionState.error(error.userMessage);
        },
      );
    } catch (e) {
      AppLogger.error('Error updating score for session: $sessionId', e);
      state = SessionState.error('Failed to update score: ${e.toString()}');
    }
  }

  /// Update current question index (host only)
  Future<void> updateCurrentQuestion(int questionIndex) async {
    try {
      final result = await dataSource.updateCurrentQuestion(
        sessionId,
        questionIndex,
      );

      result.when(
        success: (session) {
          AppLogger.firebase(
            'SessionNotifier',
            'Successfully updated question for session: $sessionId',
          );
          state = SessionState.loaded(session.toEntity());
        },
        failure: (error) {
          AppLogger.error(
            'Failed to update question for session: $sessionId',
            error,
          );
          state = SessionState.error(error.userMessage);
        },
      );
    } catch (e) {
      AppLogger.error('Error updating question for session: $sessionId', e);
      state = SessionState.error('Failed to update question: ${e.toString()}');
    }
  }
}

/// Session state model
sealed class SessionState {
  const SessionState();

  const factory SessionState.loading() = _LoadingState;
  const factory SessionState.loaded(GameSessionEntity session) = _LoadedState;
  const factory SessionState.error(String message) = _ErrorState;
}

class _LoadingState extends SessionState {
  const _LoadingState();
}

class _LoadedState extends SessionState {
  final GameSessionEntity session;
  const _LoadedState(this.session);
}

class _ErrorState extends SessionState {
  final String message;
  const _ErrorState(this.message);
}

/// Session validation result
class SessionValidationResult {
  final bool isValid;
  final String? errorMessage;
  final GameSessionEntity? session;
  final bool isHost;
  final bool isPlayer;
  final bool canJoin;

  const SessionValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.session,
    this.isHost = false,
    this.isPlayer = false,
    this.canJoin = false,
  });

  factory SessionValidationResult.valid({
    required GameSessionEntity session,
    required bool isHost,
    required bool isPlayer,
    required bool canJoin,
  }) => SessionValidationResult._(
    isValid: true,
    session: session,
    isHost: isHost,
    isPlayer: isPlayer,
    canJoin: canJoin,
  );

  factory SessionValidationResult.notAuthenticated() =>
      const SessionValidationResult._(
        isValid: false,
        errorMessage: 'User not authenticated',
      );

  factory SessionValidationResult.sessionNotFound() =>
      const SessionValidationResult._(
        isValid: false,
        errorMessage: 'Session not found',
      );

  factory SessionValidationResult.sessionExpired() =>
      const SessionValidationResult._(
        isValid: false,
        errorMessage: 'Session has expired',
      );

  factory SessionValidationResult.sessionInvalid() =>
      const SessionValidationResult._(
        isValid: false,
        errorMessage: 'Session is invalid',
      );
}

/// User's role in a session
enum UserSessionRole { none, host, player, spectator, canJoin }

/// Extension for session state
extension SessionStateX on SessionState {
  bool get isLoading => this is _LoadingState;
  bool get isLoaded => this is _LoadedState;
  bool get hasError => this is _ErrorState;

  GameSessionEntity? get session => switch (this) {
    _LoadedState(session: final session) => session,
    _ => null,
  };

  String? get errorMessage => switch (this) {
    _ErrorState(message: final message) => message,
    _ => null,
  };
}

// Extensions removed as they already exist in the models file
