# US-003: Guest Play Without Sign Up

## User Story
As a guest, I want to play without signing up so that I can quickly join a game session.

## Acceptance Criteria
- [ ] Guest can join game directly from home without authentication
- [ ] Guest can enter game PIN without account
- [ ] Guest can choose nickname for game session
- [ ] Guest data persists during game session
- [ ] Guest sees limited home screen options
- [ ] Guest prompted to create account after game
- [ ] Guest game history saved locally (last 5 games)
- [ ] Guest can convert to full account keeping nickname
- [ ] Guest cannot create/host quizzes
- [ ] Guest cannot access full leaderboard history
- [ ] Guest session expires after 24 hours
- [ ] Clear indication of guest vs authenticated status

## Navigation Flow

### Current State
```
/home shows all options without auth check
/game/join exists but no guest user concept
No differentiation between guest and authenticated users
```

### Required Implementation
```
1. Initial Guest Flow:
   /splash → Check Auth State
   ├── Authenticated → /home (full features)
   └── Not Authenticated → /home (guest mode)

2. Guest Home Screen:
   /home (guest mode)
   ├── "Join Game" (primary action)
   ├── "Sign In" 
   ├── "Create Account"
   └── Recent games (local storage)

3. Guest Game Join:
   /game/join
   ├── Enter PIN
   ├── Enter Nickname
   ├── Create anonymous Firebase user
   ├── Join game session
   └── Play game

4. Post-Game Conversion:
   /game/results
   ├── Show final score
   ├── "Save your progress!"
   ├── Convert guest → account
   │   ├── Keep game history
   │   └── Keep nickname
   └── Continue as guest → /home
```

## Technical Implementation

### 1. Guest User Model
```dart
// lib/features/authentication/domain/models/guest_user.dart

@freezed
class GuestUser with _$GuestUser {
  const factory GuestUser({
    required String sessionId,
    required String nickname,
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default([]) List<String> gameHistory,
    String? firebaseUid, // Anonymous auth UID
  }) = _GuestUser;
  
  factory GuestUser.create(String nickname) => GuestUser(
    sessionId: const Uuid().v4(),
    nickname: nickname,
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(hours: 24)),
    gameHistory: [],
  );
}
```

### 2. Update Auth State
```dart
// lib/features/authentication/domain/models/auth_state.dart

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.guest(GuestUser guest) = _Guest; // New state
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
```

### 3. Guest Authentication Service
```dart
// lib/features/authentication/data/services/guest_auth_service.dart

class GuestAuthService {
  final FirebaseAuth _auth;
  final SharedPreferences _prefs;
  
  static const _guestKey = 'guest_user';
  static const _guestGamesKey = 'guest_games';
  
  Future<GuestUser> createGuestSession(String nickname) async {
    // Create anonymous Firebase user
    final credential = await _auth.signInAnonymously();
    
    // Create guest user
    final guest = GuestUser.create(nickname).copyWith(
      firebaseUid: credential.user!.uid,
    );
    
    // Save to local storage
    await _prefs.setString(_guestKey, jsonEncode(guest.toJson()));
    
    return guest;
  }
  
  Future<void> saveGuestGame(String sessionId, GameResult result) async {
    final gamesJson = _prefs.getString(_guestGamesKey) ?? '[]';
    final games = List<Map<String, dynamic>>.from(jsonDecode(gamesJson));
    
    games.insert(0, {
      'sessionId': sessionId,
      'score': result.score,
      'rank': result.rank,
      'playedAt': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 5 games
    if (games.length > 5) {
      games.removeRange(5, games.length);
    }
    
    await _prefs.setString(_guestGamesKey, jsonEncode(games));
  }
  
  Future<void> convertGuestToUser(String email, String password) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || !currentUser.isAnonymous) {
      throw Exception('No guest session to convert');
    }
    
    // Link anonymous account to email/password
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    
    await currentUser.linkWithCredential(credential);
    
    // Migrate guest data to user profile
    await _migrateGuestData(currentUser.uid);
    
    // Clear guest data
    await _prefs.remove(_guestKey);
    await _prefs.remove(_guestGamesKey);
  }
}
```

### 4. Update Home Page for Guests
```dart
// lib/features/home/presentation/pages/home_page.dart

@override
Widget build(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    authenticated: (user) => _buildAuthenticatedHome(user),
    guest: (guest) => _buildGuestHome(guest),
    unauthenticated: () => _buildGuestHome(null),
    // ... other states
  );
}

Widget _buildGuestHome(GuestUser? guest) {
  return Scaffold(
    body: Column(
      children: [
        // Guest indicator banner
        Container(
          color: Colors.orange.shade100,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Playing as guest'),
              ),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
        
        // Limited quick actions
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Primary action - Join Game
              ElevatedButton.icon(
                onPressed: () => context.go('/game/join'),
                icon: const Icon(Icons.play_arrow, size: 32),
                label: const Text('Join Game', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 80),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Secondary actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/leaderboard'),
                      child: const Text('Leaderboard'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Recent games (from local storage)
        if (guest != null && guest.gameHistory.isNotEmpty)
          _buildRecentGames(guest.gameHistory),
      ],
    ),
  );
}
```

### 5. Update Game Join for Guests
```dart
// lib/features/game/presentation/pages/game_join_page.dart

Future<void> _joinGame() async {
  final authState = ref.read(authStateProvider);
  
  // Create guest session if needed
  if (authState is! Authenticated && authState is! Guest) {
    final guest = await ref
        .read(guestAuthServiceProvider)
        .createGuestSession(nicknameController.text);
    
    ref.read(authStateProvider.notifier).setGuestState(guest);
  }
  
  // Join game with PIN
  final result = await ref
      .read(gameServiceProvider)
      .joinGame(pinController.text, nicknameController.text);
  
  result.fold(
    (failure) => _showError(failure),
    (session) => context.go('/game/${session.id}/lobby'),
  );
}
```

### 6. Post-Game Conversion Screen
```dart
// lib/features/game/presentation/pages/post_game_conversion_page.dart

class PostGameConversionPage extends ConsumerWidget {
  final GameResult result;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 24),
            Text(
              'Great job! You scored ${result.score} points!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.save, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Save Your Progress!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create an account to:\n'
                      '• Track all your scores\n'
                      '• Create your own quizzes\n'
                      '• Compete on global leaderboards',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _showConversionDialog(context, ref),
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ),
            ),
            
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 7. Router Updates
```dart
// lib/core/navigation/app_router.dart

// Update redirect logic
redirect: (context, state) async {
  final authState = ref.read(authStateProvider);
  
  // Allow guests to access specific routes
  final guestAllowedRoutes = [
    '/home',
    '/game/join',
    '/game/*/lobby',
    '/game/*/play',
    '/game/*/results',
    '/leaderboard',
    '/login',
    '/register',
  ];
  
  if (authState is Guest || authState is Unauthenticated) {
    final isAllowed = guestAllowedRoutes.any(
      (route) => state.fullPath?.startsWith(route) ?? false,
    );
    
    if (!isAllowed) {
      return '/login';
    }
  }
  
  return null;
},
```

## Local Storage Schema

### Guest User Storage
```json
{
  "sessionId": "uuid",
  "nickname": "PlayerName",
  "createdAt": "2024-01-20T10:00:00Z",
  "expiresAt": "2024-01-21T10:00:00Z",
  "firebaseUid": "anonymous-uid"
}
```

### Guest Games Storage
```json
[
  {
    "sessionId": "ABC123",
    "score": 1250,
    "rank": 3,
    "playedAt": "2024-01-20T10:30:00Z"
  }
]
```

## Testing Requirements

### Unit Tests
- [ ] Guest session creation
- [ ] Guest data persistence
- [ ] Guest to user conversion
- [ ] Session expiration logic
- [ ] Game history management

### Integration Tests
- [ ] Complete guest play flow
- [ ] Anonymous Firebase auth
- [ ] Local storage operations
- [ ] Account conversion flow

### E2E Tests
- [ ] Guest can join game from home
- [ ] Guest game data persists
- [ ] Post-game conversion prompt works
- [ ] Guest limitations enforced
- [ ] Account upgrade preserves data

## Security Considerations
- [ ] Guest sessions expire after 24 hours
- [ ] Anonymous users isolated in Firestore
- [ ] No sensitive data in local storage
- [ ] Rate limiting on guest creation

## Related Issues
- Depends on: Game join functionality
- Related: US-001 (Email sign up)
- Related: US-002 (Google sign in)
- Enhances: Overall user acquisition

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Guest flow fully implemented
- [ ] Unit tests passing (>85% coverage)
- [ ] Integration tests passing
- [ ] Manual testing completed
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] Works on all platforms