import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/game_session_entity.dart';
import '../../data/models/game_session_model.dart';
import '../../data/repositories/game_session_repository_impl.dart';
import '../../data/datasources/game_session_firestore_datasource.dart';
import '../../data/services/game_session_realtime_service.dart';
import '../../data/services/pin_lookup_service.dart';
import '../../domain/usecases/create_game_session.dart';
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

/// Real-time service provider for optimized game session monitoring
final gameSessionRealtimeServiceProvider = Provider<GameSessionRealtimeService>(
  (ref) {
    final service = GameSessionRealtimeService();
    service.initialize();

    ref.onDispose(() {
      service.dispose();
    });

    return service;
  },
);

/// PIN lookup service provider with caching
final pinLookupServiceProvider = Provider<PinLookupService>((ref) {
  return PinLookupService();
});

/// Create game session usecase provider
final createGameSessionUseCaseProvider = Provider<CreateGameSession>((ref) {
  final repository = ref.read(gameSessionRepositoryProvider);
  return CreateGameSession(repository);
});

/// Connection state stream provider
final connectionStateProvider = StreamProvider<ConnectionState>((ref) {
  final realtimeService = ref.watch(gameSessionRealtimeServiceProvider);
  return realtimeService.connectionState;
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

/// Optimized real-time session stream using the real-time service
final optimizedSessionStreamProvider =
    StreamProvider.family<GameSessionEntity?, String>((ref, sessionId) {
      final realtimeService = ref.watch(gameSessionRealtimeServiceProvider);

      return realtimeService.monitorGameSession(sessionId);
    });

/// Optimized PIN lookup provider with caching
final optimizedPinLookupProvider = FutureProvider.family<String?, String>((
  ref,
  pin,
) async {
  final pinService = ref.read(pinLookupServiceProvider);

  final result = await pinService.lookupSessionByPin(pin);

  return result.when(
    success: (sessionId) => sessionId,
    failure: (error) {
      AppLogger.error('PIN lookup failed: $pin', error);
      return null;
    },
  );
});

/// Players monitoring stream for a session
final sessionPlayersStreamProvider =
    StreamProvider.family<Map<String, PlayerEntity>, String>((ref, sessionId) {
      final realtimeService = ref.watch(gameSessionRealtimeServiceProvider);

      return realtimeService.monitorPlayers(sessionId);
    });

/// Current question monitoring stream
final currentQuestionStreamProvider = StreamProvider.family<int, String>((
  ref,
  sessionId,
) {
  final realtimeService = ref.watch(gameSessionRealtimeServiceProvider);

  return realtimeService.monitorCurrentQuestion(sessionId);
});

/// Session creation provider with PIN generation
final createSessionProvider = FutureProvider.family<GameSessionEntity?, String>(
  (ref, quizId) async {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      AppLogger.error('Cannot create session: User not authenticated');
      return null;
    }

    final dataSource = ref.read(gameSessionDataSourceProvider);

    // Create new session with generated PIN
    final newSession = GameSessionModel(
      id: '', // Will be set by Firestore
      quizId: quizId,
      hostId: currentUser.id,
      pin: '', // Will be generated by data source
      status: GameSessionStatus.waiting,
      players: {},
      currentQuestionIndex: 0,
      createdAt: DateTime.now(),
      settings: const GameSessionSettingsModel(),
    );

    final result = await dataSource.createGameSession(newSession);

    return result.when(
      success: (session) {
        AppLogger.firebase(
          'SessionProvider',
          'Created session ${session.id} with PIN ${session.pin}',
        );
        return session.toEntity();
      },
      failure: (error) {
        AppLogger.error('Failed to create session', error);
        return null;
      },
    );
  },
);

/// Join session with PIN provider
final joinSessionWithPinProvider =
    FutureProvider.family<bool, JoinSessionParams>((ref, params) async {
      final currentUser = ref.watch(currentUserProvider);
      if (currentUser == null) {
        AppLogger.error('Cannot join session: User not authenticated');
        return false;
      }

      // First, look up session by PIN
      final sessionId = await ref.read(
        optimizedPinLookupProvider(params.pin).future,
      );
      if (sessionId == null) {
        AppLogger.error('Session not found for PIN: ${params.pin}');
        return false;
      }

      // Join the session
      final dataSource = ref.read(gameSessionDataSourceProvider);
      final result = await dataSource.joinGameSession(
        sessionId,
        currentUser.id,
        params.playerName,
      );

      return result.when(
        success: (_) {
          AppLogger.firebase(
            'SessionProvider',
            'Successfully joined session $sessionId',
          );
          return true;
        },
        failure: (error) {
          AppLogger.error('Failed to join session', error);
          return false;
        },
      );
    });

/// Parameters for joining a session
class JoinSessionParams {
  final String pin;
  final String playerName;

  const JoinSessionParams({required this.pin, required this.playerName});
}

/// Host session state notifier provider
final hostSessionStateNotifierProvider =
    StateNotifierProvider<HostSessionStateNotifier, HostSessionState>(
      (ref) => HostSessionStateNotifier(
        createGameSessionUseCase: ref.read(createGameSessionUseCaseProvider),
        gameSessionRepository: ref.read(gameSessionRepositoryProvider),
        ref: ref,
      ),
    );

/// Host session state notifier class
class HostSessionStateNotifier extends StateNotifier<HostSessionState> {
  final CreateGameSession createGameSessionUseCase;
  final GameSessionRepositoryImpl gameSessionRepository;
  final Ref ref;
  
  GameSessionEntity? _currentSession;

  HostSessionStateNotifier({
    required this.createGameSessionUseCase,
    required this.gameSessionRepository,
    required this.ref,
  }) : super(const HostSessionState.initial());

  /// Create a new game session
  Future<void> createSession({required String quizId}) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const HostSessionState.error('User not authenticated');
      return;
    }

    state = const HostSessionState.creating();

    try {
      final result = await createGameSessionUseCase.call(
        quizId: quizId,
        hostId: currentUser.id,
      );

      result.when(
        success: (session) {
          _currentSession = session;
          state = HostSessionState.created(session);
          _listenToSessionUpdates(session.id);
        },
        failure: (error) {
          AppLogger.error('Failed to create session', error);
          state = HostSessionState.error(error.userMessage);
        },
      );
    } catch (e) {
      AppLogger.error('Error creating session', e);
      state = HostSessionState.error('Failed to create session: ${e.toString()}');
    }
  }

  /// Start the game session
  Future<void> startSession() async {
    if (_currentSession == null) {
      state = const HostSessionState.error('No active session');
      return;
    }

    state = HostSessionState.starting(_currentSession!);

    try {
      final result = await gameSessionRepository.startGameSession(_currentSession!.id);

      result.when(
        success: (updatedSession) {
          _currentSession = updatedSession;
          state = HostSessionState.active(updatedSession);
        },
        failure: (error) {
          AppLogger.error('Failed to start session', error);
          state = HostSessionState.error(error.userMessage);
        },
      );
    } catch (e) {
      AppLogger.error('Error starting session', e);
      state = HostSessionState.error('Failed to start session: ${e.toString()}');
    }
  }

  /// Cancel the session
  Future<void> cancelSession() async {
    if (_currentSession == null) {
      state = const HostSessionState.initial();
      return;
    }

    try {
      await gameSessionRepository.deleteGameSession(_currentSession!.id);
      _currentSession = null;
      state = const HostSessionState.initial();
    } catch (e) {
      AppLogger.error('Error canceling session', e);
      // Still reset state even if deletion fails
      _currentSession = null;
      state = const HostSessionState.initial();
    }
  }

  /// Listen to session updates for real-time player joins
  void _listenToSessionUpdates(String sessionId) {
    ref.listen(gameSessionStreamProvider(sessionId), (previous, next) {
      next.when(
        data: (session) {
          if (session != null && _currentSession != null) {
            _currentSession = session;
            // Update state based on current session status
            switch (session.status) {
              case GameSessionStatus.waiting:
                state = HostSessionState.created(session);
                break;
              case GameSessionStatus.active:
                state = HostSessionState.active(session);
                break;
              case GameSessionStatus.completed:
                state = HostSessionState.completed(session);
                break;
            }
          }
        },
        loading: () {
          // Keep current state during loading
        },
        error: (error, stackTrace) {
          AppLogger.error('Session stream error', error);
          state = HostSessionState.error(error.toString());
        },
      );
    });
  }

  /// Get current session
  GameSessionEntity? get currentSession => _currentSession;
}

/// Host session state model
sealed class HostSessionState {
  const HostSessionState();

  const factory HostSessionState.initial() = _InitialState;
  const factory HostSessionState.creating() = _CreatingState;
  const factory HostSessionState.created(GameSessionEntity session) = _CreatedState;
  const factory HostSessionState.starting(GameSessionEntity session) = _StartingState;
  const factory HostSessionState.active(GameSessionEntity session) = _ActiveState;
  const factory HostSessionState.completed(GameSessionEntity session) = _CompletedState;
  const factory HostSessionState.error(String message) = _HostErrorState;
}

class _InitialState extends HostSessionState {
  const _InitialState();
}

class _CreatingState extends HostSessionState {
  const _CreatingState();
}

class _CreatedState extends HostSessionState {
  final GameSessionEntity session;
  const _CreatedState(this.session);
}

class _StartingState extends HostSessionState {
  final GameSessionEntity session;
  const _StartingState(this.session);
}

class _ActiveState extends HostSessionState {
  final GameSessionEntity session;
  const _ActiveState(this.session);
}

class _CompletedState extends HostSessionState {
  final GameSessionEntity session;
  const _CompletedState(this.session);
}

class _HostErrorState extends HostSessionState {
  final String message;
  const _HostErrorState(this.message);
}

/// Extension for host session state
extension HostSessionStateX on HostSessionState {
  bool get isInitial => this is _InitialState;
  bool get isCreating => this is _CreatingState;
  bool get isCreated => this is _CreatedState;
  bool get isStarting => this is _StartingState;
  bool get isActive => this is _ActiveState;
  bool get isCompleted => this is _CompletedState;
  bool get hasError => this is _HostErrorState;
  bool get isLoading => isCreating || isStarting;

  GameSessionEntity? get session => switch (this) {
    _CreatedState(session: final session) => session,
    _StartingState(session: final session) => session,
    _ActiveState(session: final session) => session,
    _CompletedState(session: final session) => session,
    _ => null,
  };

  String? get errorMessage => switch (this) {
    _HostErrorState(message: final message) => message,
    _ => null,
  };
}
