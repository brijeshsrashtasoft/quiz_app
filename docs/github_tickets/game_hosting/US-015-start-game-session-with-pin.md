# US-015: Start Game Session with PIN

## User Story
**As a** quiz host  
**I want to** start a game session that generates a unique 6-digit PIN  
**So that** players can easily join my quiz session

## Acceptance Criteria
- [ ] Host can create a new game session from quiz selection screen
- [ ] System generates unique 6-digit PIN automatically
- [ ] PIN is displayed prominently on host screen
- [ ] PIN remains valid for 24 hours or until session ends
- [ ] System prevents PIN collisions (duplicate PINs)
- [ ] Host sees session status as "Waiting for Players"
- [ ] Session creation works offline with sync when online

## User Journey Map
```
1. Host Login → Dashboard
   └─ Selects "My Quizzes" or "Browse Quizzes"
   
2. Quiz Selection → Host Options
   └─ Clicks "Host This Quiz"
   
3. Session Configuration (Optional)
   ├─ Max players limit (default: 50)
   ├─ Show correct answers (default: true)
   └─ Allow replay (default: true)
   
4. Create Session → Loading State
   └─ "Creating game session..."
   
5. Session Created → Host Lobby
   ├─ Large PIN display (e.g., "123 456")
   ├─ Join URL: "quizapp.com/join"
   ├─ Player count: "0 Players"
   └─ "Start Game" button (disabled)
```

## Current Implementation Analysis

### Existing Components
- `lib/features/game_session/presentation/pages/host_game_screen.dart` - Basic UI structure
- `lib/features/game_session/domain/entities/game_session_entity.dart` - Entity model with PIN
- `lib/features/game_session/presentation/providers/session_providers.dart` - Session creation provider
- `lib/features/game_session/data/services/game_session_realtime_service.dart` - Real-time monitoring

### Missing Components
- PIN generation service
- Session configuration dialog
- Host navigation flow
- PIN collision prevention
- Session expiration handling

## Navigation Flow

### Current State
```dart
// Limited navigation in host_game_screen.dart
TextButton(
  onPressed: () => context.pop(),
  child: Text('Cancel Game'),
)
```

### Required Implementation
```dart
// 1. Quiz selection to host screen navigation
class QuizDetailsScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return PrimaryButton(
      onPressed: () async {
        // Show configuration dialog (optional)
        final config = await showDialog<GameSessionSettings>(
          context: context,
          builder: (_) => SessionConfigDialog(),
        );
        
        // Navigate to host screen with quiz ID
        context.push('/host/${quiz.id}', extra: config);
      },
      text: 'Host This Quiz',
    );
  }
}

// 2. Updated router configuration
GoRoute(
  path: '/host/:quizId',
  builder: (context, state) {
    final quizId = state.pathParameters['quizId']!;
    final config = state.extra as GameSessionSettings?;
    return HostGameScreen(
      quizId: quizId,
      settings: config,
    );
  },
),
```

## Technical Implementation

### 1. PIN Generation Service
```dart
// lib/features/game_session/domain/services/pin_generator_service.dart
class PinGeneratorService {
  static const int PIN_LENGTH = 6;
  static const int MAX_ATTEMPTS = 100;
  
  final Random _random = Random.secure();
  
  /// Generate unique 6-digit PIN
  Future<String> generateUniquePin(
    PinLookupService lookupService,
  ) async {
    for (int attempt = 0; attempt < MAX_ATTEMPTS; attempt++) {
      final pin = _generatePin();
      
      // Check availability
      final isAvailable = await lookupService.isPinAvailable(pin);
      if (isAvailable) {
        return pin;
      }
      
      // Exponential backoff for retries
      if (attempt > 10) {
        await Future.delayed(Duration(milliseconds: 100 * (attempt ~/ 10)));
      }
    }
    
    throw PinGenerationException('Failed to generate unique PIN');
  }
  
  String _generatePin() {
    // Generate 6 random digits (100000-999999)
    final pin = 100000 + _random.nextInt(900000);
    return pin.toString();
  }
  
  /// Format PIN for display (add space in middle)
  String formatPin(String pin) {
    if (pin.length != PIN_LENGTH) return pin;
    return '${pin.substring(0, 3)} ${pin.substring(3)}';
  }
}
```

### 2. Enhanced Host Game Screen
```dart
// lib/features/game_session/presentation/pages/host_game_screen.dart
class HostGameScreen extends ConsumerStatefulWidget {
  final String quizId;
  final GameSessionSettings? settings;
  
  const HostGameScreen({
    super.key,
    required this.quizId,
    this.settings,
  });
  
  @override
  ConsumerState<HostGameScreen> createState() => _HostGameScreenState();
}

class _HostGameScreenState extends ConsumerState<HostGameScreen> {
  @override
  void initState() {
    super.initState();
    // Create session on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createSession();
    });
  }
  
  Future<void> _createSession() async {
    final notifier = ref.read(hostSessionNotifierProvider.notifier);
    await notifier.createSession(
      quizId: widget.quizId,
      settings: widget.settings ?? const GameSessionSettings(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(hostSessionNotifierProvider);
    
    return PageLayout(
      title: 'Host Game',
      child: sessionState.when(
        creating: () => LoadingIndicator(
          message: 'Creating game session...',
        ),
        created: (session) => _buildHostLobby(session),
        error: (message) => ErrorDisplay(
          message: message,
          onRetry: _createSession,
        ),
      ),
    );
  }
  
  Widget _buildHostLobby(GameSessionEntity session) {
    return Column(
      children: [
        // Large PIN display
        PinDisplay(
          pin: session.pin,
          formatted: PinGeneratorService.formatPin(session.pin),
        ),
        
        // Join instructions
        JoinInstructions(
          url: 'quizapp.com/join',
          playerCount: session.playerCount,
        ),
        
        // Live player list
        Expanded(
          child: PlayerLobbyList(
            players: session.players.values.toList(),
            onKickPlayer: (playerId) {
              ref.read(hostSessionNotifierProvider.notifier)
                .kickPlayer(playerId);
            },
          ),
        ),
        
        // Host controls
        HostControlPanel(
          canStart: session.playerCount > 0,
          onStartGame: () {
            ref.read(hostSessionNotifierProvider.notifier)
              .startGame();
          },
          onCancelGame: () {
            _showCancelConfirmation();
          },
        ),
      ],
    );
  }
}
```

### 3. Host Session State Management
```dart
// lib/features/game_session/presentation/providers/host_session_provider.dart
final hostSessionNotifierProvider = 
    StateNotifierProvider<HostSessionNotifier, HostSessionState>((ref) {
  return HostSessionNotifier(ref);
});

class HostSessionNotifier extends StateNotifier<HostSessionState> {
  final Ref ref;
  StreamSubscription? _sessionSubscription;
  
  HostSessionNotifier(this.ref) : super(const HostSessionState.creating());
  
  Future<void> createSession({
    required String quizId,
    required GameSessionSettings settings,
  }) async {
    state = const HostSessionState.creating();
    
    try {
      // Generate unique PIN
      final pinGenerator = ref.read(pinGeneratorServiceProvider);
      final pinLookup = ref.read(pinLookupServiceProvider);
      final pin = await pinGenerator.generateUniquePin(pinLookup);
      
      // Create session
      final repository = ref.read(gameSessionRepositoryProvider);
      final currentUser = ref.read(currentUserProvider)!;
      
      final result = await repository.createGameSession(
        quizId: quizId,
        hostId: currentUser.id,
        pin: pin,
        settings: settings,
      );
      
      result.when(
        success: (session) {
          state = HostSessionState.created(session);
          _subscribeToSession(session.id);
        },
        failure: (error) {
          state = HostSessionState.error(error.userMessage);
        },
      );
    } catch (e) {
      state = HostSessionState.error('Failed to create session: $e');
    }
  }
  
  void _subscribeToSession(String sessionId) {
    _sessionSubscription?.cancel();
    
    _sessionSubscription = ref
        .read(optimizedSessionStreamProvider(sessionId).stream)
        .listen(
          (session) {
            if (session != null && state is HostSessionCreated) {
              state = HostSessionState.created(session);
            }
          },
          onError: (error) {
            state = HostSessionState.error('Connection lost: $error');
          },
        );
  }
  
  Future<void> kickPlayer(String playerId) async {
    // Implementation for US-018
  }
  
  Future<void> startGame() async {
    // Implementation for US-019
  }
  
  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }
}

@freezed
class HostSessionState with _$HostSessionState {
  const factory HostSessionState.creating() = _Creating;
  const factory HostSessionState.created(GameSessionEntity session) = HostSessionCreated;
  const factory HostSessionState.error(String message) = _Error;
}
```

### 4. Real-time PIN Lookup with Caching
```dart
// lib/features/game_session/data/services/pin_lookup_service.dart (enhanced)
class PinLookupService {
  final _pinCache = <String, String>{}; // PIN -> SessionId
  final _cacheExpiry = <String, DateTime>{};
  static const _cacheLifetime = Duration(minutes: 5);
  
  Future<bool> isPinAvailable(String pin) async {
    // Check cache first
    if (_isInCache(pin)) {
      return false; // PIN is taken
    }
    
    // Query Firestore
    final query = FirestoreConfig.getCollection('game_sessions')
        .where('pin', isEqualTo: pin)
        .where('status', whereIn: ['waiting', 'active'])
        .limit(1);
    
    final snapshot = await query.get();
    final isAvailable = snapshot.docs.isEmpty;
    
    // Cache unavailable PINs
    if (!isAvailable && snapshot.docs.isNotEmpty) {
      _cachePin(pin, snapshot.docs.first.id);
    }
    
    return isAvailable;
  }
  
  bool _isInCache(String pin) {
    final expiry = _cacheExpiry[pin];
    if (expiry == null) return false;
    
    if (DateTime.now().isAfter(expiry)) {
      _pinCache.remove(pin);
      _cacheExpiry.remove(pin);
      return false;
    }
    
    return _pinCache.containsKey(pin);
  }
  
  void _cachePin(String pin, String sessionId) {
    _pinCache[pin] = sessionId;
    _cacheExpiry[pin] = DateTime.now().add(_cacheLifetime);
  }
}
```

### 5. Firebase Security Rules
```javascript
// firestore.rules
match /game_sessions/{sessionId} {
  // Allow read for anyone with the PIN
  allow read: if true;
  
  // Only host can create/update
  allow create: if request.auth != null 
    && request.auth.uid == request.resource.data.hostId
    && request.resource.data.pin.matches('^[0-9]{6}$')
    && request.resource.data.status == 'waiting';
  
  allow update: if request.auth != null
    && request.auth.uid == resource.data.hostId;
  
  // Host can delete their own sessions
  allow delete: if request.auth != null
    && request.auth.uid == resource.data.hostId;
}
```

## Network & Error Handling

### Connection Recovery
```dart
class HostGameScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    
    return Stack(
      children: [
        // Main content
        _buildContent(),
        
        // Connection indicator
        if (connectionState.value != ConnectionState.connected)
          ConnectionBanner(
            state: connectionState.value ?? ConnectionState.offline,
            onRetry: _retryConnection,
          ),
      ],
    );
  }
}
```

### Error Recovery States
1. **PIN Generation Failure**: Retry with exponential backoff
2. **Network Timeout**: Show offline mode, auto-retry when online
3. **Session Creation Failure**: Clear error message with retry option
4. **Firestore Quota**: Graceful degradation message

## Testing Requirements

### Unit Tests
```dart
group('PinGeneratorService', () {
  test('generates 6-digit PINs', () {
    final service = PinGeneratorService();
    final pin = service._generatePin();
    
    expect(pin.length, equals(6));
    expect(int.tryParse(pin), isNotNull);
    expect(int.parse(pin), greaterThanOrEqualTo(100000));
    expect(int.parse(pin), lessThanOrEqualTo(999999));
  });
  
  test('handles PIN collisions gracefully', () async {
    final mockLookup = MockPinLookupService();
    when(mockLookup.isPinAvailable(any))
        .thenAnswer((_) async => false);
    
    final service = PinGeneratorService();
    
    expect(
      () => service.generateUniquePin(mockLookup),
      throwsA(isA<PinGenerationException>()),
    );
  });
});
```

### Widget Tests
```dart
testWidgets('Host screen creates session on mount', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        hostSessionNotifierProvider.overrideWith(
          () => MockHostSessionNotifier(),
        ),
      ],
      child: MaterialApp(
        home: HostGameScreen(quizId: 'test-quiz'),
      ),
    ),
  );
  
  await tester.pumpAndSettle();
  
  // Verify session creation initiated
  verify(mockNotifier.createSession(any)).called(1);
  
  // Verify PIN display
  expect(find.byType(PinDisplay), findsOneWidget);
});
```

### Integration Tests
```dart
testWidgets('Complete host session creation flow', (tester) async {
  // Setup Firebase emulator
  await Firebase.initializeApp();
  
  // Navigate to quiz and host
  await tester.pumpWidget(MyApp());
  await tester.tap(find.text('My Quizzes'));
  await tester.pumpAndSettle();
  
  await tester.tap(find.text('Host This Quiz').first);
  await tester.pumpAndSettle();
  
  // Verify PIN generated and displayed
  expect(find.byType(PinDisplay), findsOneWidget);
  expect(find.textContaining(RegExp(r'\d{3} \d{3}')), findsOneWidget);
  
  // Verify Firestore document created
  final sessions = await FirebaseFirestore.instance
      .collection('game_sessions')
      .where('hostId', isEqualTo: testUserId)
      .get();
  
  expect(sessions.docs.length, equals(1));
  expect(sessions.docs.first.data()['pin'].length, equals(6));
});
```

## Performance Considerations

### Optimizations
1. **PIN Generation**: Use secure random with collision detection
2. **Caching**: Cache recent PINs to reduce Firestore queries
3. **Batch Operations**: Group player joins in batch updates
4. **Connection Pooling**: Reuse Firestore connections
5. **Lazy Loading**: Load quiz data only when needed

### Metrics to Monitor
- PIN generation time (target: <100ms)
- Session creation time (target: <500ms)
- Firestore read operations per session
- Cache hit rate for PIN lookups
- Failed PIN generation attempts

## Security Considerations

1. **PIN Security**:
   - Use cryptographically secure random
   - Rate limit PIN generation attempts
   - Expire PINs after 24 hours
   
2. **Host Verification**:
   - Validate host ownership of quiz
   - Prevent session hijacking
   - Secure session state updates
   
3. **Data Privacy**:
   - No personal data in session documents
   - Anonymous player nicknames
   - Secure session cleanup

## Dependencies
- `firebase_core: ^3.0.0`
- `cloud_firestore: ^5.0.0`
- `connectivity_plus: ^6.0.0`
- `flutter_riverpod: ^2.5.0`
- `go_router: ^14.0.0`
- `freezed: ^2.5.0`

## Affected Files
- `lib/features/game_session/presentation/pages/host_game_screen.dart` - Major updates
- `lib/features/game_session/domain/services/pin_generator_service.dart` - New file
- `lib/features/game_session/presentation/providers/host_session_provider.dart` - New file
- `lib/features/game_session/data/services/pin_lookup_service.dart` - Enhanced
- `lib/features/quiz/presentation/pages/quiz_details_screen.dart` - Add host button
- `lib/core/router/app_router.dart` - Add host route
- `firestore.rules` - Security rules for sessions

## Definition of Done
- [ ] PIN generation service implemented with collision prevention
- [ ] Host game screen creates session and displays PIN
- [ ] Real-time connection monitoring implemented
- [ ] Session configuration dialog (optional) implemented
- [ ] Navigation flow from quiz to host screen working
- [ ] PIN expires after 24 hours automatically
- [ ] Comprehensive error handling for all failure scenarios
- [ ] Unit tests pass with >90% coverage
- [ ] Integration tests verify end-to-end flow
- [ ] Performance metrics meet targets
- [ ] Security rules prevent unauthorized access
- [ ] Works offline with sync when online