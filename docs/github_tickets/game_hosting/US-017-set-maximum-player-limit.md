# US-017: Set Maximum Player Limit

## User Story
**As a** host  
**I want to** set a maximum player limit (up to 50)  
**So that** I can manage session size and ensure good performance

## Acceptance Criteria
- [ ] Host can set player limit before creating session (5-50 players)
- [ ] Default limit is 50 players
- [ ] UI shows capacity indicator (e.g., "25/30 players")
- [ ] New players cannot join when limit reached
- [ ] Clear message shown to players when session is full
- [ ] Host can modify limit before game starts
- [ ] System enforces limit at Firebase level

## User Journey Map
```
1. Quiz Selection → Host Options
   └─ "Host This Quiz" button clicked

2. Session Configuration Dialog
   ├─ Player Limit Slider: [5 ----●---- 50]
   ├─ Current Value: "30 players"
   ├─ Other settings (optional)
   └─ "Create Session" button

3. Host Lobby → Capacity Display
   ├─ "15 / 30 Players"
   ├─ Progress bar showing fill level
   └─ Warning at 80% capacity

4. Capacity Reached → Full State
   ├─ "30 / 30 Players (FULL)"
   ├─ Red progress bar
   ├─ No new joins allowed
   └─ Host can still start game

5. Player Attempt to Join Full Session
   ├─ Enter PIN → Error message
   └─ "This session is full (30/30 players)"
```

## Current Implementation Analysis

### Existing Components
- `GameSessionSettings` entity with `maxPlayers` field
- Basic player count tracking in `GameSessionEntity`
- `isFull` computed property in entity extensions

### Missing Components
- Session configuration UI dialog
- Player limit slider/input component
- Capacity visualization in lobby
- Full session handling for players
- Firebase rules enforcement
- Dynamic limit modification

## Navigation Flow

### Current State
```dart
// Direct navigation without configuration
context.push('/host/${quiz.id}');
```

### Required Implementation
```dart
// 1. Show configuration dialog before hosting
class QuizDetailsScreen extends ConsumerWidget {
  Future<void> _handleHostQuiz() async {
    // Show configuration dialog
    final settings = await showDialog<GameSessionSettings>(
      context: context,
      builder: (context) => SessionConfigurationDialog(
        defaultSettings: GameSessionSettings(
          maxPlayers: 50,
          showCorrectAnswers: true,
          allowReplay: true,
        ),
      ),
    );
    
    if (settings != null) {
      // Navigate with configured settings
      context.push(
        '/host/${quiz.id}',
        extra: settings,
      );
    }
  }
}

// 2. Configuration dialog with player limit
class SessionConfigurationDialog extends StatefulWidget {
  final GameSessionSettings defaultSettings;
  
  const SessionConfigurationDialog({
    super.key,
    required this.defaultSettings,
  });
  
  @override
  State<SessionConfigurationDialog> createState() => 
      _SessionConfigurationDialogState();
}
```

## Technical Implementation

### 1. Session Configuration Dialog
```dart
// lib/features/game_session/presentation/widgets/session_configuration_dialog.dart
class SessionConfigurationDialog extends StatefulWidget {
  final GameSessionSettings defaultSettings;
  
  const SessionConfigurationDialog({
    super.key,
    required this.defaultSettings,
  });
  
  @override
  State<SessionConfigurationDialog> createState() => 
      _SessionConfigurationDialogState();
}

class _SessionConfigurationDialogState 
    extends State<SessionConfigurationDialog> {
  late int _maxPlayers;
  late bool _showCorrectAnswers;
  late bool _allowReplay;
  late bool _shuffleQuestions;
  
  static const int MIN_PLAYERS = 5;
  static const int MAX_PLAYERS = 50;
  static const List<int> PRESET_VALUES = [10, 20, 30, 40, 50];
  
  @override
  void initState() {
    super.initState();
    _maxPlayers = widget.defaultSettings.maxPlayers;
    _showCorrectAnswers = widget.defaultSettings.showCorrectAnswers;
    _allowReplay = widget.defaultSettings.allowReplay;
    _shuffleQuestions = widget.defaultSettings.shuffleQuestions;
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: AppSpacing.allL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Session Settings',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: AppSpacing.spacingL),
            
            // Player limit section
            _buildPlayerLimitSection(),
            const SizedBox(height: AppSpacing.spacingL),
            
            // Other settings
            _buildToggleSettings(),
            const SizedBox(height: AppSpacing.spacingXL),
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlayerLimitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Maximum Players',
              style: AppTextStyles.bodyTextLarge,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.vibrantPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_maxPlayers',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingM),
        
        // Slider with custom styling
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.vibrantPurple,
            inactiveTrackColor: AppColors.neutralGray200,
            thumbColor: AppColors.vibrantPurple,
            overlayColor: AppColors.vibrantPurple.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
            ),
            trackHeight: 6,
          ),
          child: Slider(
            value: _maxPlayers.toDouble(),
            min: MIN_PLAYERS.toDouble(),
            max: MAX_PLAYERS.toDouble(),
            divisions: MAX_PLAYERS - MIN_PLAYERS,
            label: '$_maxPlayers players',
            onChanged: (value) {
              setState(() {
                _maxPlayers = value.round();
              });
            },
          ),
        ),
        
        // Preset buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: PRESET_VALUES.map((value) {
            final isSelected = _maxPlayers == value;
            return TextButton(
              onPressed: () => setState(() => _maxPlayers = value),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                backgroundColor: isSelected
                    ? AppColors.vibrantPurple.withOpacity(0.1)
                    : null,
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  color: isSelected
                      ? AppColors.vibrantPurple
                      : AppColors.coolGray,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            );
          }).toList(),
        ),
        
        // Capacity recommendations
        Container(
          padding: AppSpacing.allS,
          decoration: BoxDecoration(
            color: AppColors.infoBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.infoBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getCapacityRecommendation(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.infoBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _getCapacityRecommendation() {
    if (_maxPlayers <= 10) {
      return 'Small group: Ideal for detailed discussions';
    } else if (_maxPlayers <= 30) {
      return 'Classroom size: Good for educational settings';
    } else {
      return 'Large audience: Best for events and competitions';
    }
  }
  
  Widget _buildToggleSettings() {
    return Column(
      children: [
        SwitchListTile(
          title: Text('Show Correct Answers'),
          subtitle: Text('Display correct answers after each question'),
          value: _showCorrectAnswers,
          onChanged: (value) => setState(() => _showCorrectAnswers = value),
          activeColor: AppColors.vibrantPurple,
        ),
        SwitchListTile(
          title: Text('Allow Replay'),
          subtitle: Text('Let players replay the quiz after completion'),
          value: _allowReplay,
          onChanged: (value) => setState(() => _allowReplay = value),
          activeColor: AppColors.vibrantPurple,
        ),
        SwitchListTile(
          title: Text('Shuffle Questions'),
          subtitle: Text('Randomize question order for each session'),
          value: _shuffleQuestions,
          onChanged: (value) => setState(() => _shuffleQuestions = value),
          activeColor: AppColors.vibrantPurple,
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        const SizedBox(width: AppSpacing.spacingM),
        PrimaryButton(
          onPressed: () {
            final settings = GameSessionSettings(
              maxPlayers: _maxPlayers,
              showCorrectAnswers: _showCorrectAnswers,
              allowReplay: _allowReplay,
              shuffleQuestions: _shuffleQuestions,
            );
            Navigator.of(context).pop(settings);
          },
          text: 'Create Session',
          size: ButtonSize.small,
        ),
      ],
    );
  }
}
```

### 2. Enhanced Host Lobby with Capacity Display
```dart
// lib/features/game_session/presentation/widgets/player_capacity_display.dart
class PlayerCapacityDisplay extends StatelessWidget {
  final int currentPlayers;
  final int maxPlayers;
  final VoidCallback? onEditLimit;
  final bool canEdit;
  
  const PlayerCapacityDisplay({
    super.key,
    required this.currentPlayers,
    required this.maxPlayers,
    this.onEditLimit,
    this.canEdit = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final percentage = currentPlayers / maxPlayers;
    final isFull = currentPlayers >= maxPlayers;
    final isNearFull = percentage >= 0.8;
    
    return Container(
      padding: AppSpacing.allM,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Player count with animation
              TweenAnimationBuilder<int>(
                tween: IntTween(
                  begin: currentPlayers,
                  end: currentPlayers,
                ),
                duration: AppAnimations.shortAnimation,
                builder: (context, value, child) {
                  return RichText(
                    text: TextSpan(
                      style: AppTextStyles.headingSmall,
                      children: [
                        TextSpan(
                          text: '$value',
                          style: TextStyle(
                            color: isFull
                                ? AppColors.errorRed
                                : isNearFull
                                    ? AppColors.warningOrange
                                    : AppColors.darkCharcoal,
                          ),
                        ),
                        TextSpan(
                          text: ' / $maxPlayers',
                          style: TextStyle(
                            color: AppColors.coolGray,
                          ),
                        ),
                        TextSpan(
                          text: ' Players',
                        ),
                        if (isFull)
                          TextSpan(
                            text: ' (FULL)',
                            style: TextStyle(
                              color: AppColors.errorRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              
              // Edit button (before game starts)
              if (canEdit && onEditLimit != null)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEditLimit,
                  color: AppColors.coolGray,
                  tooltip: 'Change player limit',
                ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.spacingS),
          
          // Animated capacity bar
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Background track
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.neutralGray200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  
                  // Filled portion with animation
                  AnimatedContainer(
                    duration: AppAnimations.mediumAnimation,
                    curve: AppAnimations.easeOut,
                    height: 8,
                    width: constraints.maxWidth * percentage.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: _getCapacityColor(percentage),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  
                  // Milestone markers
                  ..._buildMilestoneMarkers(constraints.maxWidth),
                ],
              );
            },
          ),
          
          // Capacity warnings
          if (isNearFull && !isFull)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.warningOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Session almost full',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warningOrange,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Color _getCapacityColor(double percentage) {
    if (percentage >= 1.0) {
      return AppColors.errorRed;
    } else if (percentage >= 0.8) {
      return AppColors.warningOrange;
    } else if (percentage >= 0.5) {
      return AppColors.vibrantPurple;
    } else {
      return AppColors.successGreen;
    }
  }
  
  List<Widget> _buildMilestoneMarkers(double width) {
    return [0.25, 0.5, 0.75].map((milestone) {
      return Positioned(
        left: width * milestone - 1,
        child: Container(
          width: 2,
          height: 8,
          color: AppColors.neutralGray400,
        ),
      );
    }).toList();
  }
}
```

### 3. Player Join Validation with Full Session Handling
```dart
// lib/features/game_session/domain/usecases/validate_session_join.dart
class ValidateSessionJoin {
  final GameSessionRepository repository;
  
  ValidateSessionJoin(this.repository);
  
  Future<Result<SessionJoinValidation>> call({
    required String pin,
    required String userId,
  }) async {
    try {
      // Get session by PIN
      final sessionResult = await repository.getGameSessionByPin(pin);
      
      return sessionResult.when(
        success: (session) {
          if (session == null) {
            return Result.failure(
              ValidationFailure(
                message: 'Invalid PIN',
                code: 'invalid_pin',
              ),
            );
          }
          
          // Check various conditions
          final validation = _validateJoinConditions(session, userId);
          return Result.success(validation);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Failed to validate session'),
      );
    }
  }
  
  SessionJoinValidation _validateJoinConditions(
    GameSessionEntity session,
    String userId,
  ) {
    // Already in session
    if (session.isPlayer(userId)) {
      return SessionJoinValidation.alreadyJoined(session);
    }
    
    // Is the host
    if (session.isHost(userId)) {
      return SessionJoinValidation.isHost(session);
    }
    
    // Session full
    if (session.isFull) {
      return SessionJoinValidation.sessionFull(
        session,
        session.playerCount,
        session.settings?.maxPlayers ?? 50,
      );
    }
    
    // Session expired
    if (session.hasExpired) {
      return SessionJoinValidation.sessionExpired(session);
    }
    
    // Session already started
    if (session.status != GameSessionStatus.waiting) {
      return SessionJoinValidation.sessionStarted(session);
    }
    
    // Can join
    return SessionJoinValidation.canJoin(session);
  }
}

@freezed
class SessionJoinValidation with _$SessionJoinValidation {
  const factory SessionJoinValidation.canJoin(
    GameSessionEntity session,
  ) = _CanJoin;
  
  const factory SessionJoinValidation.sessionFull(
    GameSessionEntity session,
    int currentPlayers,
    int maxPlayers,
  ) = _SessionFull;
  
  const factory SessionJoinValidation.alreadyJoined(
    GameSessionEntity session,
  ) = _AlreadyJoined;
  
  const factory SessionJoinValidation.isHost(
    GameSessionEntity session,
  ) = _IsHost;
  
  const factory SessionJoinValidation.sessionExpired(
    GameSessionEntity session,
  ) = _SessionExpired;
  
  const factory SessionJoinValidation.sessionStarted(
    GameSessionEntity session,
  ) = _SessionStarted;
}
```

### 4. Player Join Screen with Full Session Handling
```dart
// lib/features/game_session/presentation/pages/player_join_screen.dart (enhanced)
class PlayerJoinScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PlayerJoinScreen> createState() => _PlayerJoinScreenState();
}

class _PlayerJoinScreenState extends ConsumerState<PlayerJoinScreen> {
  final _pinController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isValidating = false;
  SessionJoinValidation? _validation;
  
  Future<void> _validatePin() async {
    final pin = _pinController.text;
    if (pin.length != 6) return;
    
    setState(() => _isValidating = true);
    
    final validateUseCase = ref.read(validateSessionJoinProvider);
    final currentUser = ref.read(currentUserProvider)!;
    
    final result = await validateUseCase(
      pin: pin,
      userId: currentUser.id,
    );
    
    setState(() {
      _isValidating = false;
      _validation = result.when(
        success: (validation) => validation,
        failure: (error) => null,
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Join Game',
      child: Column(
        children: [
          // PIN entry
          PinEntryWidget(
            controller: _pinController,
            onCompleted: _validatePin,
            enabled: !_isValidating,
          ),
          
          // Validation feedback
          if (_validation != null)
            _buildValidationFeedback(),
          
          // Nickname entry (only if can join)
          if (_validation is _CanJoin)
            NicknameInput(
              controller: _nicknameController,
              onSubmitted: _joinSession,
            ),
        ],
      ),
    );
  }
  
  Widget _buildValidationFeedback() {
    return Container(
      margin: AppSpacing.verticalM,
      padding: AppSpacing.allM,
      decoration: BoxDecoration(
        color: _getValidationColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getValidationColor(),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getValidationIcon(),
            color: _getValidationColor(),
          ),
          const SizedBox(width: AppSpacing.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getValidationTitle(),
                  style: AppTextStyles.bodyTextLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_getValidationMessage() != null)
                  Text(
                    _getValidationMessage()!,
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getValidationTitle() {
    return _validation!.when(
      canJoin: (_) => 'Session found!',
      sessionFull: (_, current, max) => 'Session is full ($current/$max)',
      alreadyJoined: (_) => 'You\'re already in this session',
      isHost: (_) => 'You\'re the host of this session',
      sessionExpired: (_) => 'This session has expired',
      sessionStarted: (_) => 'Game already started',
    );
  }
  
  String? _getValidationMessage() {
    return _validation!.when(
      canJoin: (_) => 'Enter your nickname to join',
      sessionFull: (_, __, ___) => 'Try joining another session',
      alreadyJoined: (_) => 'Return to game',
      isHost: (_) => 'Go to host controls',
      sessionExpired: (_) => 'Ask the host to create a new session',
      sessionStarted: (_) => 'Wait for the next game',
    );
  }
  
  Color _getValidationColor() {
    return _validation!.when(
      canJoin: (_) => AppColors.successGreen,
      sessionFull: (_, __, ___) => AppColors.errorRed,
      alreadyJoined: (_) => AppColors.infoBlue,
      isHost: (_) => AppColors.vibrantPurple,
      sessionExpired: (_) => AppColors.coolGray,
      sessionStarted: (_) => AppColors.warningOrange,
    );
  }
  
  IconData _getValidationIcon() {
    return _validation!.when(
      canJoin: (_) => Icons.check_circle,
      sessionFull: (_, __, ___) => Icons.block,
      alreadyJoined: (_) => Icons.info,
      isHost: (_) => Icons.admin_panel_settings,
      sessionExpired: (_) => Icons.schedule,
      sessionStarted: (_) => Icons.play_arrow,
    );
  }
}
```

### 5. Firebase Security Rules with Player Limit Enforcement
```javascript
// firestore.rules
match /game_sessions/{sessionId} {
  // Allow read for anyone (to check if full)
  allow read: if true;
  
  // Join validation
  allow update: if request.auth != null
    && isJoiningAsPlayer()
    && !isSessionFull()
    && isSessionWaiting();
  
  // Host can update settings before game starts
  allow update: if request.auth != null
    && request.auth.uid == resource.data.hostId
    && resource.data.status == 'waiting'
    && isValidSettingsUpdate();
  
  function isJoiningAsPlayer() {
    return request.resource.data.players[request.auth.uid] != null
      && !resource.data.players[request.auth.uid];
  }
  
  function isSessionFull() {
    let maxPlayers = resource.data.settings.maxPlayers;
    let currentPlayers = resource.data.players.size();
    return currentPlayers >= maxPlayers;
  }
  
  function isSessionWaiting() {
    return resource.data.status == 'waiting';
  }
  
  function isValidSettingsUpdate() {
    let newMax = request.resource.data.settings.maxPlayers;
    let currentPlayers = resource.data.players.size();
    return newMax >= 5 
      && newMax <= 50 
      && newMax >= currentPlayers;
  }
}
```

### 6. Dynamic Player Limit Modification
```dart
// lib/features/game_session/presentation/widgets/edit_player_limit_dialog.dart
class EditPlayerLimitDialog extends StatefulWidget {
  final int currentLimit;
  final int currentPlayers;
  
  const EditPlayerLimitDialog({
    super.key,
    required this.currentLimit,
    required this.currentPlayers,
  });
  
  @override
  State<EditPlayerLimitDialog> createState() => _EditPlayerLimitDialogState();
}

class _EditPlayerLimitDialogState extends State<EditPlayerLimitDialog> {
  late int _newLimit;
  
  @override
  void initState() {
    super.initState();
    _newLimit = widget.currentLimit;
  }
  
  @override
  Widget build(BuildContext context) {
    final minAllowed = math.max(widget.currentPlayers, 5);
    
    return AlertDialog(
      title: Text('Change Player Limit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current: ${widget.currentPlayers} / ${widget.currentLimit} players',
            style: AppTextStyles.bodyText,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          
          // New limit slider
          Row(
            children: [
              Text('New limit:'),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _newLimit.toDouble(),
                  min: minAllowed.toDouble(),
                  max: 50,
                  divisions: 50 - minAllowed,
                  label: '$_newLimit',
                  onChanged: (value) {
                    setState(() => _newLimit = value.round());
                  },
                ),
              ),
              Text(
                '$_newLimit',
                style: AppTextStyles.bodyTextLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // Warning if reducing below current
          if (_newLimit < widget.currentLimit)
            Container(
              padding: AppSpacing.allS,
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.warningOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'New players won\'t be able to join',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        PrimaryButton(
          onPressed: () => Navigator.of(context).pop(_newLimit),
          text: 'Update',
          size: ButtonSize.small,
        ),
      ],
    );
  }
}
```

## Network & Error Handling

### Capacity Check Optimization
```dart
// Cache capacity status to reduce reads
class SessionCapacityCache {
  final _cache = <String, CapacityStatus>{};
  final _expiry = <String, DateTime>{};
  static const _cacheDuration = Duration(seconds: 10);
  
  CapacityStatus? getCachedStatus(String sessionId) {
    final expiry = _expiry[sessionId];
    if (expiry == null || DateTime.now().isAfter(expiry)) {
      _cache.remove(sessionId);
      _expiry.remove(sessionId);
      return null;
    }
    return _cache[sessionId];
  }
  
  void cacheStatus(String sessionId, CapacityStatus status) {
    _cache[sessionId] = status;
    _expiry[sessionId] = DateTime.now().add(_cacheDuration);
  }
}
```

## Testing Requirements

### Unit Tests
```dart
group('Player limit enforcement', () {
  test('prevents joins when session full', () async {
    final session = GameSessionEntity(
      settings: GameSessionSettings(maxPlayers: 2),
      players: {
        'player1': PlayerEntity(name: 'Alice'),
        'player2': PlayerEntity(name: 'Bob'),
      },
    );
    
    expect(session.isFull, isTrue);
    expect(session.canUserJoin('player3'), isFalse);
  });
  
  test('allows limit changes above current players', () {
    final validator = SessionSettingsValidator();
    
    expect(
      validator.canChangeLimit(
        currentPlayers: 10,
        currentLimit: 20,
        newLimit: 15,
      ),
      isTrue,
    );
    
    expect(
      validator.canChangeLimit(
        currentPlayers: 10,
        currentLimit: 20,
        newLimit: 5,
      ),
      isFalse,
    );
  });
});
```

### Widget Tests
```dart
testWidgets('Capacity display updates correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: PlayerCapacityDisplay(
        currentPlayers: 25,
        maxPlayers: 30,
      ),
    ),
  );
  
  // Verify display
  expect(find.text('25 / 30 Players'), findsOneWidget);
  
  // Verify warning state (>80% full)
  expect(find.text('Session almost full'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is Container &&
          widget.color == AppColors.warningOrange.withOpacity(0.1),
    ),
    findsOneWidget,
  );
});
```

### Integration Tests
```dart
testWidgets('Full session prevents new joins', (tester) async {
  // Create session with limit of 1
  final hostApp = ProviderScope(child: MyApp());
  await tester.pumpWidget(hostApp);
  
  // Host creates session with 1 player limit
  // ... navigation and setup
  
  // First player joins successfully
  final player1App = ProviderScope(child: MyApp());
  await tester.pumpWidget(player1App);
  // ... join with PIN
  
  // Second player attempts to join
  final player2App = ProviderScope(child: MyApp());
  await tester.pumpWidget(player2App);
  // ... enter same PIN
  
  await tester.pumpAndSettle();
  
  // Verify full message
  expect(find.text('Session is full (1/1)'), findsOneWidget);
  expect(find.text('Try joining another session'), findsOneWidget);
});
```

## Performance Considerations

### Optimizations
1. **Capacity Caching**: 10-second cache for join validation
2. **Batch Updates**: Update multiple settings together
3. **Debounced Slider**: Prevent excessive Firestore writes
4. **Lazy Validation**: Only check capacity when needed
5. **Indexed Queries**: Index on `status` and `playerCount`

### Metrics
- Capacity check: <50ms (cached), <200ms (fresh)
- Settings update: <300ms
- Join validation: <500ms total
- UI update latency: <16ms (60fps)

## Security Considerations

1. **Limit Enforcement**:
   - Server-side validation in Firebase rules
   - Cannot reduce below current players
   - Max 50 players hard limit

2. **Anti-Spam**:
   - Rate limit join attempts
   - IP-based throttling
   - Temporary ban for repeated failures

3. **Data Integrity**:
   - Atomic updates for settings
   - Consistent player count
   - Transaction-based joins

## Dependencies
- `cloud_firestore: ^5.0.0`
- `flutter_riverpod: ^2.5.0`
- `freezed: ^2.5.0`
- `go_router: ^14.0.0`

## Affected Files
- `lib/features/game_session/presentation/widgets/session_configuration_dialog.dart` - New
- `lib/features/game_session/presentation/widgets/player_capacity_display.dart` - New
- `lib/features/game_session/presentation/widgets/edit_player_limit_dialog.dart` - New
- `lib/features/game_session/domain/usecases/validate_session_join.dart` - New
- `lib/features/game_session/presentation/pages/player_join_screen.dart` - Enhanced
- `lib/features/game_session/presentation/pages/host_game_screen.dart` - Updated
- `firestore.rules` - Add capacity enforcement

## Definition of Done
- [ ] Configuration dialog allows setting 5-50 player limit
- [ ] Capacity display shows current/max with visual indicator
- [ ] Progress bar changes color based on capacity
- [ ] Full sessions prevent new joins with clear message
- [ ] Host can modify limit before game starts
- [ ] Firebase rules enforce capacity limits
- [ ] Preset buttons for common limits work
- [ ] Capacity recommendations displayed
- [ ] Settings persist to Firestore
- [ ] Unit tests cover all limit scenarios
- [ ] Integration tests verify enforcement
- [ ] Performance targets met
- [ ] Security measures implemented