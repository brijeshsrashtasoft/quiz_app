# US-016: See Players Joining in Real-Time

## User Story
**As a** host  
**I want to** see players joining my lobby in real-time  
**So that** I know who's participating and when to start the game

## Acceptance Criteria
- [ ] Host sees player count update instantly when players join
- [ ] Player nicknames appear in lobby list immediately
- [ ] Animated entry for new players (slide in/fade in)
- [ ] Player avatars or icons displayed
- [ ] Shows "Player is joining..." during connection
- [ ] Handles rapid player joins (10+ simultaneous)
- [ ] Updates work even with poor network connectivity

## User Journey Map
```
1. Host in Lobby → Waiting State
   ├─ PIN displayed: "123 456"
   ├─ Player count: "0 Players"
   └─ Empty state: "Waiting for players to join..."

2. First Player Joins → Update Animation
   ├─ Counter animates: "0 → 1 Players"
   ├─ Player card slides in from bottom
   └─ Sound effect (optional)

3. Multiple Players Join → List Updates
   ├─ Player cards stack vertically
   ├─ Auto-scroll to show latest
   ├─ Count updates: "15 Players"
   └─ "Start Game" enables at 1+ players

4. Player Disconnects → Graceful Removal
   ├─ Card fades out
   ├─ Count decrements
   └─ Gap closes smoothly
```

## Current Implementation Analysis

### Existing Components
- `lib/features/game_session/data/services/game_session_realtime_service.dart` - WebSocket monitoring
- `lib/features/game_session/presentation/widgets/lobby_player_list.dart` - Basic list widget
- `lib/features/game_session/domain/entities/game_session_entity.dart` - Player entity model
- Stream providers for real-time updates

### Missing Components
- Animated player list with entry/exit animations
- Player joining state indicators
- Optimized real-time sync for large groups
- Network resilience for player updates
- Player avatar/icon system

## Navigation Flow

### Current State
```dart
// Basic player display without real-time updates
Container(
  child: Text('$joinedPlayers Players'),
)
```

### Required Implementation
```dart
// Real-time player monitoring in host screen
class _HostGameScreenState extends ConsumerState<HostGameScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch player stream for real-time updates
    final playersAsync = ref.watch(
      sessionPlayersStreamProvider(sessionId),
    );
    
    return playersAsync.when(
      data: (players) => AnimatedPlayerLobby(
        players: players.values.toList(),
        maxPlayers: session.settings?.maxPlayers ?? 50,
        onKickPlayer: _handleKickPlayer,
      ),
      loading: () => ShimmerPlayerList(),
      error: (e, s) => ErrorDisplay(
        message: 'Failed to load players',
        onRetry: () => ref.refresh(
          sessionPlayersStreamProvider(sessionId),
        ),
      ),
    );
  }
}
```

## Technical Implementation

### 1. Optimized Player Stream Provider
```dart
// lib/features/game_session/presentation/providers/player_stream_provider.dart
final sessionPlayersStreamProvider = StreamProvider.family<
  List<PlayerLobbyData>,
  String
>((ref, sessionId) {
  final realtimeService = ref.watch(gameSessionRealtimeServiceProvider);
  
  return realtimeService
      .monitorPlayers(sessionId)
      .map((players) {
        // Transform to UI-friendly data with metadata
        return players.entries.map((entry) {
          final playerId = entry.key;
          final player = entry.value;
          
          return PlayerLobbyData(
            id: playerId,
            name: player.name,
            joinedAt: player.joinedAt,
            isReady: player.isReady,
            avatar: _generateAvatar(player.name),
            connectionStatus: _getConnectionStatus(player),
            isNew: _isRecentlyJoined(player.joinedAt),
          );
        }).toList()
          ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
      })
      .distinct(); // Only emit when players actually change
});

// Player lobby data model
@freezed
class PlayerLobbyData with _$PlayerLobbyData {
  const factory PlayerLobbyData({
    required String id,
    required String name,
    required DateTime joinedAt,
    required bool isReady,
    required String avatar,
    required ConnectionStatus connectionStatus,
    required bool isNew,
  }) = _PlayerLobbyData;
}
```

### 2. Animated Player Lobby Widget
```dart
// lib/features/game_session/presentation/widgets/animated_player_lobby.dart
class AnimatedPlayerLobby extends StatefulWidget {
  final List<PlayerLobbyData> players;
  final int maxPlayers;
  final Function(String) onKickPlayer;
  
  const AnimatedPlayerLobby({
    super.key,
    required this.players,
    required this.maxPlayers,
    required this.onKickPlayer,
  });
  
  @override
  State<AnimatedPlayerLobby> createState() => _AnimatedPlayerLobbyState();
}

class _AnimatedPlayerLobbyState extends State<AnimatedPlayerLobby> {
  final _listKey = GlobalKey<AnimatedListState>();
  final _scrollController = ScrollController();
  List<PlayerLobbyData> _players = [];
  
  @override
  void initState() {
    super.initState();
    _players = widget.players;
  }
  
  @override
  void didUpdateWidget(AnimatedPlayerLobby oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePlayerList(oldWidget.players, widget.players);
  }
  
  void _updatePlayerList(
    List<PlayerLobbyData> oldPlayers,
    List<PlayerLobbyData> newPlayers,
  ) {
    // Find added players
    for (final player in newPlayers) {
      if (!oldPlayers.any((p) => p.id == player.id)) {
        final index = newPlayers.indexOf(player);
        _players.insert(index, player);
        _listKey.currentState?.insertItem(
          index,
          duration: AppAnimations.mediumAnimation,
        );
        
        // Auto-scroll to show new player
        _scrollToBottom();
        
        // Play sound effect if enabled
        if (player.isNew) {
          _playJoinSound();
        }
      }
    }
    
    // Find removed players
    for (int i = oldPlayers.length - 1; i >= 0; i--) {
      final player = oldPlayers[i];
      if (!newPlayers.any((p) => p.id == player.id)) {
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildRemovedPlayer(player, animation),
          duration: AppAnimations.mediumAnimation,
        );
        _players.removeAt(i);
      }
    }
  }
  
  Widget _buildRemovedPlayer(
    PlayerLobbyData player,
    Animation<double> animation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: PlayerLobbyCard(
          player: player,
          onKick: null,
          isLeaving: true,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_players.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      children: [
        // Player count header
        _buildPlayerCountHeader(),
        
        // Animated player list
        Expanded(
          child: AnimatedList(
            key: _listKey,
            controller: _scrollController,
            initialItemCount: _players.length,
            itemBuilder: (context, index, animation) {
              if (index >= _players.length) return const SizedBox.shrink();
              
              final player = _players[index];
              return _buildPlayerItem(player, animation, index);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildPlayerItem(
    PlayerLobbyData player,
    Animation<double> animation,
    int index,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: AppAnimations.easeOut)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: PlayerLobbyCard(
          player: player,
          index: index + 1,
          onKick: () => widget.onKickPlayer(player.id),
          showKickButton: true,
        ),
      ),
    );
  }
  
  Widget _buildPlayerCountHeader() {
    return Container(
      padding: AppSpacing.allM,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Animated counter
          TweenAnimationBuilder<int>(
            tween: IntTween(
              begin: _previousCount,
              end: _players.length,
            ),
            duration: AppAnimations.shortAnimation,
            builder: (context, value, child) {
              return Text(
                '$value / ${widget.maxPlayers} Players',
                style: AppTextStyles.sectionHeader,
              );
            },
          ),
          
          // Capacity indicator
          LinearProgressIndicator(
            value: _players.length / widget.maxPlayers,
            backgroundColor: AppColors.neutralGray200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _players.length >= widget.maxPlayers
                  ? AppColors.errorRed
                  : AppColors.successGreen,
            ),
          ),
        ],
      ),
    );
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppAnimations.mediumAnimation,
          curve: AppAnimations.easeOut,
        );
      }
    });
  }
}
```

### 3. Player Lobby Card with Rich Features
```dart
// lib/features/game_session/presentation/widgets/player_lobby_card.dart
class PlayerLobbyCard extends StatelessWidget {
  final PlayerLobbyData player;
  final int? index;
  final VoidCallback? onKick;
  final bool showKickButton;
  final bool isLeaving;
  
  const PlayerLobbyCard({
    super.key,
    required this.player,
    this.index,
    this.onKick,
    this.showKickButton = false,
    this.isLeaving = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.horizontalM + AppSpacing.verticalS,
      decoration: BoxDecoration(
        color: isLeaving ? AppColors.neutralGray100 : AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: player.isNew ? AppColors.vibrantPurple : AppColors.neutralGray200,
          width: player.isNew ? 2 : 1,
        ),
        boxShadow: [
          if (!isLeaving)
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Stack(
        children: [
          // New player highlight animation
          if (player.isNew && !isLeaving)
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(seconds: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.vibrantPurple.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          
          // Card content
          Padding(
            padding: AppSpacing.allM,
            child: Row(
              children: [
                // Player number (optional)
                if (index != null)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.neutralGray100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(width: AppSpacing.spacingM),
                
                // Avatar
                PlayerAvatar(
                  avatarUrl: player.avatar,
                  size: 40,
                  showOnlineIndicator: true,
                  isOnline: player.connectionStatus == ConnectionStatus.connected,
                ),
                
                const SizedBox(width: AppSpacing.spacingM),
                
                // Player info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            player.name,
                            style: AppTextStyles.bodyText.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (player.isNew)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'NEW',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.pureWhite,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        _getJoinedTimeText(player.joinedAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                
                // Connection status
                _buildConnectionIndicator(),
                
                // Kick button (host only)
                if (showKickButton && onKick != null && !isLeaving)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onKick,
                    color: AppColors.errorRed,
                    tooltip: 'Remove player',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectionIndicator() {
    final color = switch (player.connectionStatus) {
      ConnectionStatus.connected => AppColors.successGreen,
      ConnectionStatus.connecting => AppColors.warningOrange,
      ConnectionStatus.disconnected => AppColors.errorRed,
      _ => AppColors.neutralGray400,
    };
    
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
  
  String _getJoinedTimeText(DateTime joinedAt) {
    final now = DateTime.now();
    final difference = now.difference(joinedAt);
    
    if (difference.inSeconds < 60) {
      return 'Just joined';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}
```

### 4. Enhanced Real-time Service with Player Monitoring
```dart
// lib/features/game_session/data/services/game_session_realtime_service.dart (enhanced)
extension PlayerMonitoring on GameSessionRealtimeService {
  /// Monitor players with connection status
  Stream<Map<String, PlayerEntity>> monitorPlayersWithStatus(
    String sessionId,
  ) {
    final controller = StreamController<Map<String, PlayerEntity>>.broadcast();
    final playerStatus = <String, DateTime>{};
    Timer? heartbeatTimer;
    
    // Monitor main player data
    final mainStream = monitorPlayers(sessionId).listen(
      (players) {
        // Update last seen timestamps
        for (final playerId in players.keys) {
          playerStatus[playerId] = DateTime.now();
        }
        
        // Check for disconnected players
        final updatedPlayers = Map<String, PlayerEntity>.from(players);
        for (final entry in playerStatus.entries) {
          final playerId = entry.key;
          final lastSeen = entry.value;
          
          if (!players.containsKey(playerId)) {
            continue; // Player left
          }
          
          final timeSinceLastSeen = DateTime.now().difference(lastSeen);
          if (timeSinceLastSeen > const Duration(seconds: 30)) {
            // Mark as disconnected
            final player = updatedPlayers[playerId]!;
            updatedPlayers[playerId] = player.copyWith(
              connectionStatus: ConnectionStatus.disconnected,
            );
          }
        }
        
        controller.add(updatedPlayers);
      },
      onError: (error) => controller.addError(error),
    );
    
    // Start heartbeat monitoring
    heartbeatTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkPlayerHeartbeats(sessionId, playerStatus),
    );
    
    // Cleanup
    controller.onCancel = () {
      mainStream.cancel();
      heartbeatTimer?.cancel();
    };
    
    return controller.stream;
  }
  
  /// Batch update multiple players efficiently
  Future<void> batchUpdatePlayers(
    String sessionId,
    Map<String, Map<String, dynamic>> playerUpdates,
  ) async {
    if (playerUpdates.isEmpty) return;
    
    final batch = FirestoreConfig.getBatch();
    final docRef = FirestoreConfig.getDocument('game_sessions', sessionId);
    
    // Build update map
    final updates = <String, dynamic>{};
    for (final entry in playerUpdates.entries) {
      final playerId = entry.key;
      final playerData = entry.value;
      
      for (final field in playerData.entries) {
        updates['players.$playerId.${field.key}'] = field.value;
      }
    }
    
    batch.update(docRef, updates);
    
    try {
      await batch.commit();
      AppLogger.performance(
        'Batch player update',
        Duration(milliseconds: playerUpdates.length * 10),
      );
    } catch (e) {
      AppLogger.error('Failed to batch update players', e);
      throw FirestoreException(
        message: 'Failed to update players',
        code: 'batch_update_failed',
      );
    }
  }
}
```

### 5. Network Resilience and Optimization
```dart
// lib/features/game_session/presentation/providers/network_aware_player_provider.dart
final networkAwarePlayerProvider = Provider<NetworkAwarePlayerService>((ref) {
  return NetworkAwarePlayerService(ref);
});

class NetworkAwarePlayerService {
  final Ref ref;
  final _playerQueue = Queue<PlayerUpdate>();
  Timer? _processTimer;
  
  NetworkAwarePlayerService(this.ref);
  
  /// Queue player updates for batch processing
  void queuePlayerUpdate(PlayerUpdate update) {
    _playerQueue.add(update);
    _scheduleProcessing();
  }
  
  void _scheduleProcessing() {
    _processTimer?.cancel();
    _processTimer = Timer(
      const Duration(milliseconds: 100),
      _processQueue,
    );
  }
  
  Future<void> _processQueue() async {
    if (_playerQueue.isEmpty) return;
    
    // Group updates by session
    final groupedUpdates = <String, List<PlayerUpdate>>{};
    while (_playerQueue.isNotEmpty) {
      final update = _playerQueue.removeFirst();
      groupedUpdates[update.sessionId] ??= [];
      groupedUpdates[update.sessionId]!.add(update);
    }
    
    // Process each session's updates
    for (final entry in groupedUpdates.entries) {
      final sessionId = entry.key;
      final updates = entry.value;
      
      try {
        await _processBatchUpdates(sessionId, updates);
      } catch (e) {
        // Re-queue failed updates
        _playerQueue.addAll(updates);
        AppLogger.error('Failed to process player updates', e);
      }
    }
  }
  
  Future<void> _processBatchUpdates(
    String sessionId,
    List<PlayerUpdate> updates,
  ) async {
    final service = ref.read(gameSessionRealtimeServiceProvider);
    
    // Convert to batch update format
    final playerUpdates = <String, Map<String, dynamic>>{};
    for (final update in updates) {
      playerUpdates[update.playerId] = update.data;
    }
    
    await service.batchUpdatePlayers(sessionId, playerUpdates);
  }
}

@freezed
class PlayerUpdate with _$PlayerUpdate {
  const factory PlayerUpdate({
    required String sessionId,
    required String playerId,
    required Map<String, dynamic> data,
    required DateTime timestamp,
  }) = _PlayerUpdate;
}
```

## Network & Error Handling

### Connection States
```dart
enum PlayerConnectionStatus {
  connected,      // Active WebSocket connection
  connecting,     // Establishing connection
  reconnecting,   // Lost connection, attempting reconnect
  disconnected,   // No connection for >30 seconds
  removed         // Player kicked or left
}
```

### Error Recovery
1. **Rapid Joins**: Queue and batch process within 100ms windows
2. **Connection Loss**: Show stale data with "disconnected" indicator
3. **Sync Conflicts**: Last-write-wins with server timestamp
4. **Rate Limiting**: Exponential backoff for failed updates

## Testing Requirements

### Unit Tests
```dart
group('Player monitoring', () {
  test('detects new players within 100ms', () async {
    final service = MockRealtimeService();
    final stream = service.monitorPlayers('session-1');
    
    final stopwatch = Stopwatch()..start();
    
    // Simulate player join
    service.addPlayer('session-1', PlayerEntity(name: 'Alice'));
    
    final players = await stream.first;
    stopwatch.stop();
    
    expect(players.length, equals(1));
    expect(stopwatch.elapsedMilliseconds, lessThan(100));
  });
  
  test('handles 50 simultaneous joins', () async {
    final service = GameSessionRealtimeService();
    
    // Simulate rapid joins
    final futures = List.generate(50, (i) async {
      await service.batchUpdatePlayerScore(
        'session-1',
        'player-$i',
        {'name': 'Player $i', 'joinedAt': DateTime.now()},
      );
    });
    
    await Future.wait(futures);
    
    // Verify all players added
    final players = await service.monitorPlayers('session-1').first;
    expect(players.length, equals(50));
  });
});
```

### Widget Tests
```dart
testWidgets('Animated player list updates smoothly', (tester) async {
  final players = <PlayerLobbyData>[];
  
  await tester.pumpWidget(
    MaterialApp(
      home: AnimatedPlayerLobby(
        players: players,
        maxPlayers: 50,
        onKickPlayer: (_) {},
      ),
    ),
  );
  
  // Verify empty state
  expect(find.text('Waiting for players to join...'), findsOneWidget);
  
  // Add player
  players.add(PlayerLobbyData(
    id: '1',
    name: 'Alice',
    joinedAt: DateTime.now(),
    isNew: true,
  ));
  
  await tester.pumpWidget(
    MaterialApp(
      home: AnimatedPlayerLobby(
        players: players,
        maxPlayers: 50,
        onKickPlayer: (_) {},
      ),
    ),
  );
  
  await tester.pumpAndSettle();
  
  // Verify player appears with animation
  expect(find.text('Alice'), findsOneWidget);
  expect(find.text('NEW'), findsOneWidget);
});
```

### Integration Tests
```dart
testWidgets('Real-time player sync', (tester) async {
  // Setup two app instances (host and player)
  final hostApp = ProviderScope(child: MyApp());
  final playerApp = ProviderScope(child: MyApp());
  
  // Host creates session
  await tester.pumpWidget(hostApp);
  // ... navigate to host screen
  
  final pinFinder = find.textContaining(RegExp(r'\d{3} \d{3}'));
  expect(pinFinder, findsOneWidget);
  final pin = pinFinder.evaluate().first.widget.text;
  
  // Player joins with PIN
  await tester.pumpWidget(playerApp);
  // ... enter PIN and join
  
  // Switch back to host view
  await tester.pumpWidget(hostApp);
  await tester.pumpAndSettle();
  
  // Verify player appears in host's lobby
  expect(find.text('TestPlayer'), findsOneWidget);
  expect(find.text('1 / 50 Players'), findsOneWidget);
});
```

## Performance Considerations

### Optimizations
1. **Batching**: Group player updates in 100ms windows
2. **Debouncing**: Prevent excessive re-renders
3. **Lazy Loading**: Load player details on-demand
4. **Stream Distinct**: Only emit when players change
5. **Virtual Scrolling**: For 50+ player lists

### Metrics
- Player join latency: <200ms
- UI update frequency: Max 10 FPS
- Memory per player: <1KB
- Firestore reads: 1 per player join
- Bandwidth: <5KB/s for 50 players

## Security Considerations

1. **Player Validation**:
   - Sanitize nicknames (no profanity/HTML)
   - Limit nickname length (20 chars)
   - Rate limit joins (5 per IP per minute)

2. **Privacy**:
   - No personal data exposed
   - Anonymous player IDs
   - Session-scoped data only

3. **Anti-Spam**:
   - Captcha for rapid joins
   - IP-based rate limiting
   - Temporary ban for abuse

## Dependencies
- `cloud_firestore: ^5.0.0`
- `flutter_animate: ^4.5.0`
- `connectivity_plus: ^6.0.0`
- `audioplayers: ^6.0.0` (for join sounds)
- `shimmer: ^3.0.0` (for loading states)

## Affected Files
- `lib/features/game_session/presentation/widgets/animated_player_lobby.dart` - New
- `lib/features/game_session/presentation/widgets/player_lobby_card.dart` - New
- `lib/features/game_session/presentation/providers/player_stream_provider.dart` - New
- `lib/features/game_session/data/services/game_session_realtime_service.dart` - Enhanced
- `lib/features/game_session/presentation/pages/host_game_screen.dart` - Updated
- `lib/shared/widgets/avatars/player_avatar.dart` - New component

## Definition of Done
- [ ] Real-time player list updates within 200ms
- [ ] Smooth animations for join/leave
- [ ] Connection status indicators working
- [ ] Handles 50 simultaneous players
- [ ] Network resilience implemented
- [ ] Player count updates instantly
- [ ] Auto-scroll to new players
- [ ] Sound effects for joins (optional)
- [ ] Empty state when no players
- [ ] Unit tests >90% coverage
- [ ] Integration tests pass
- [ ] Performance metrics met
- [ ] Security measures implemented