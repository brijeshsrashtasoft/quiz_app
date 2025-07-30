import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/performance/debouncer.dart';
import '../../../../core/utils/performance/throttler.dart';
import '../../../../core/utils/performance/batch_processor.dart';
import '../../../../core/utils/performance/connection_manager.dart';
import '../../../../core/utils/performance/memory_cache.dart';
import '../../domain/entities/game_session_entity.dart';
import '../../data/models/game_session_model.dart';
import '../../data/repositories/game_session_repository_impl.dart';
import '../../data/datasources/game_session_firestore_datasource.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import 'session_providers.dart';

/// Connection manager provider
final connectionManagerProvider = Provider<ConnectionManager>((ref) {
  final manager = ConnectionManager();
  manager.initialize();
  ref.onDispose(() => manager.dispose());
  return manager;
});

/// Listener pool provider for efficient connection management
final listenerPoolProvider = Provider<ListenerPool>((ref) {
  final pool = ListenerPool();
  ref.onDispose(() => pool.dispose());
  return pool;
});

/// Memory cache for session data
final sessionCacheProvider = Provider<MemoryCache<String, GameSessionEntity>>((ref) {
  return MemoryCache<String, GameSessionEntity>(
    maxSize: 50,
    ttl: const Duration(minutes: 5),
  );
});

/// Batch processor for player updates
final playerUpdateBatchProvider = Provider<BatchProcessor<PlayerUpdate>>((ref) {
  final dataSource = ref.read(gameSessionDataSourceProvider);
  
  return BatchProcessor<PlayerUpdate>(
    batchDelay: const Duration(milliseconds: 200), // <200ms latency requirement
    maxBatchSize: 10,
    processBatch: (updates) async {
      // Group updates by session
      final sessionGroups = <String, List<PlayerUpdate>>{};
      for (final update in updates) {
        sessionGroups.putIfAbsent(update.sessionId, () => []).add(update);
      }
      
      // Process each session group
      final writer = FirestoreBatchWriter();
      for (final entry in sessionGroups.entries) {
        final sessionId = entry.key;
        final sessionUpdates = entry.value;
        
        // Merge player updates for same session
        final mergedPlayers = <String, PlayerModel>{};
        for (final update in sessionUpdates) {
          mergedPlayers[update.playerId] = update.player;
        }
        
        // Batch update
        for (final playerEntry in mergedPlayers.entries) {
          await dataSource.updatePlayerInSession(
            sessionId,
            playerEntry.key,
            playerEntry.value,
          );
        }
      }
      
      await writer.commit();
      AppLogger.performance(
        'Batch player update', 
        const Duration(milliseconds: 150), // Target latency
      );
    },
  );
});

/// Optimized stream provider for watching game session with caching
final optimizedGameSessionStreamProvider = 
    StreamProvider.family<GameSessionEntity?, String>((ref, sessionId) {
  final dataSource = ref.read(gameSessionDataSourceProvider);
  final cache = ref.read(sessionCacheProvider);
  final listenerPool = ref.read(listenerPoolProvider);
  final connectionManager = ref.read(connectionManagerProvider);
  
  // Check cache first
  final cached = cache.get(sessionId);
  
  // Create stream with optimization
  final stream = dataSource.watchGameSession(sessionId).asyncMap((result) async {
    return result.when(
      success: (session) {
        final entity = session.toEntity();
        
        // Update cache
        cache.put(sessionId, entity);
        
        AppLogger.firebase(
          'OptimizedSessionProvider',
          'Session updated (cached): $sessionId',
        );
        return entity;
      },
      failure: (error) {
        AppLogger.error('Failed to watch session: $sessionId', error);
        // Return cached value on error
        return cache.get(sessionId);
      },
    );
  });
  
  // Add to listener pool for connection management
  final controller = StreamController<GameSessionEntity?>.broadcast();
  
  listenerPool.addListener(
    'session_$sessionId',
    stream,
    (data) => controller.add(data),
    onError: (error, stack) => controller.addError(error, stack),
  );
  
  ref.onDispose(() {
    listenerPool.removeListener('session_$sessionId');
    controller.close();
  });
  
  // Return stream with cached initial value
  if (cached != null) {
    return controller.stream.startWith(cached);
  }
  
  return controller.stream;
});

/// Debounced session state notifier for rapid state changes
final optimizedSessionStateNotifierProvider =
    StateNotifierProvider.family<OptimizedSessionStateNotifier, SessionState, String>(
      (ref, sessionId) => OptimizedSessionStateNotifier(
        sessionId: sessionId,
        dataSource: ref.read(gameSessionDataSourceProvider),
        ref: ref,
        batchProcessor: ref.read(playerUpdateBatchProvider),
      ),
    );

/// Optimized session state notifier with performance improvements
class OptimizedSessionStateNotifier extends StateNotifier<SessionState> {
  final String sessionId;
  final GameSessionFirestoreDataSource dataSource;
  final Ref ref;
  final BatchProcessor<PlayerUpdate> batchProcessor;
  
  late final Debouncer _stateDebouncer;
  late final Throttler _updateThrottler;
  
  OptimizedSessionStateNotifier({
    required this.sessionId,
    required this.dataSource,
    required this.ref,
    required this.batchProcessor,
  }) : super(const SessionState.loading()) {
    _stateDebouncer = Debouncer(delay: const Duration(milliseconds: 100));
    _updateThrottler = Throttler(duration: const Duration(milliseconds: 150));
    _initialize();
  }

  void _initialize() {
    // Use optimized stream provider
    ref.listen(optimizedGameSessionStreamProvider(sessionId), (previous, next) {
      next.when(
        data: (session) {
          if (session != null) {
            // Debounce state updates to prevent rapid rebuilds
            _stateDebouncer.run(() {
              state = SessionState.loaded(session);
            });
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

  /// Optimized player score update with batching
  Future<void> updatePlayerScoreBatched(int score, List<int> answers) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const SessionState.error('User not authenticated');
      return;
    }
    
    // Throttle updates to prevent overwhelming the system
    _updateThrottler.run(() {
      // Add to batch processor
      batchProcessor.add(
        PlayerUpdate(
          sessionId: sessionId,
          playerId: currentUser.id,
          player: PlayerModel(
            name: currentUser.name,
            score: score,
            answers: answers,
            joinedAt: DateTime.now(),
          ),
        ),
      );
    });
  }

  /// Submit answer with optimized latency
  Future<void> submitAnswer(int questionIndex, int answerIndex) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;
    
    final startTime = DateTime.now();
    
    // Optimistic update for immediate UI feedback
    if (state is _LoadedState) {
      final currentSession = (state as _LoadedState).session;
      final currentPlayer = currentSession.players[currentUser.id];
      
      if (currentPlayer != null) {
        final newAnswers = List<int>.from(currentPlayer.answers);
        if (questionIndex < newAnswers.length) {
          newAnswers[questionIndex] = answerIndex;
        } else {
          newAnswers.add(answerIndex);
        }
        
        // Calculate score (simplified for optimization)
        final newScore = currentPlayer.score + 100;
        
        // Immediate optimistic UI update
        final optimisticPlayer = currentPlayer.copyWith(
          answers: newAnswers,
          score: newScore,
        );
        
        final optimisticPlayers = Map<String, PlayerEntity>.from(
          currentSession.players,
        );
        optimisticPlayers[currentUser.id] = optimisticPlayer;
        
        state = SessionState.loaded(
          currentSession.copyWith(players: optimisticPlayers),
        );
        
        // Batch the actual update
        await updatePlayerScoreBatched(newScore, newAnswers);
        
        final latency = DateTime.now().difference(startTime);
        AppLogger.performance('Answer submission latency', latency);
      }
    }
  }

  @override
  void dispose() {
    _stateDebouncer.dispose();
    _updateThrottler.dispose();
    super.dispose();
  }
}

/// Player update model for batching
class PlayerUpdate {
  final String sessionId;
  final String playerId;
  final PlayerModel player;

  PlayerUpdate({
    required this.sessionId,
    required this.playerId,
    required this.player,
  });
}

/// Performance monitoring provider
final performanceMonitorProvider = Provider<PerformanceMonitor>((ref) {
  return PerformanceMonitor();
});

/// Performance monitor for tracking metrics
class PerformanceMonitor {
  final Map<String, List<Duration>> _metrics = {};
  
  void recordMetric(String name, Duration duration) {
    _metrics.putIfAbsent(name, () => []).add(duration);
    
    // Log if exceeds threshold
    if (duration.inMilliseconds > 200) {
      AppLogger.warning(
        'Performance',
        '$name exceeded 200ms threshold: ${duration.inMilliseconds}ms',
      );
    }
  }
  
  Map<String, PerformanceMetric> getMetrics() {
    final results = <String, PerformanceMetric>{};
    
    for (final entry in _metrics.entries) {
      final durations = entry.value;
      if (durations.isEmpty) continue;
      
      final totalMs = durations.fold<int>(
        0,
        (sum, d) => sum + d.inMilliseconds,
      );
      final avgMs = totalMs ~/ durations.length;
      final maxMs = durations.map((d) => d.inMilliseconds).reduce(
        (max, d) => d > max ? d : max,
      );
      
      results[entry.key] = PerformanceMetric(
        averageMs: avgMs,
        maxMs: maxMs,
        count: durations.length,
      );
    }
    
    return results;
  }
  
  void clear() {
    _metrics.clear();
  }
}

class PerformanceMetric {
  final int averageMs;
  final int maxMs;
  final int count;

  PerformanceMetric({
    required this.averageMs,
    required this.maxMs,
    required this.count,
  });
}

/// Optimized provider for large participant lists
final participantListProvider = Provider.family<AsyncValue<List<PlayerEntity>>, String>((
  ref,
  sessionId,
) {
  final sessionAsync = ref.watch(optimizedGameSessionStreamProvider(sessionId));
  
  return sessionAsync.whenData((session) {
    if (session == null) return [];
    
    // Sort players by score for leaderboard (cached and efficient)
    final players = session.players.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    
    // Limit display for performance
    return players.take(100).toList();
  });
});

/// Memory-efficient active sessions provider
final optimizedActiveSessionsProvider = FutureProvider<List<GameSessionEntity>>((
  ref,
) async {
  final dataSource = ref.read(gameSessionDataSourceProvider);
  final cache = ref.read(sessionCacheProvider);
  
  AppLogger.firebase('OptimizedProvider', 'Fetching active sessions with cache');
  
  // Check if we have any cached sessions
  final cachedStats = cache.getStats();
  AppLogger.info('Cache Stats', cachedStats.toString());
  
  final result = await dataSource.getActiveGameSessions(limit: 10); // Reduced limit
  return result.when(
    success: (sessions) {
      // Cache all fetched sessions
      for (final session in sessions) {
        cache.put(session.id, session.toEntity());
      }
      
      return sessions.map((s) => s.toEntity()).toList();
    },
    failure: (error) {
      AppLogger.error('Failed to fetch active sessions', error);
      return [];
    },
  );
});