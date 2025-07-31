# US-008: Set Time Limits per Question

## User Story
As a quiz creator, I want to set time limits (5-300 seconds) per question so that I can control the pace of the game.

## User Journey Map
```
Time Configuration Flow:
1. Creator editing question → Sees time limit option
2. Selects from preset options → Or enters custom value
3. Sees visual indicator → Updates in real-time
4. Players experience → Countdown timer pressure
5. Analytics show → Average response times
```

## Acceptance Criteria
- [ ] Time limit selector on each question
- [ ] Preset options: 5, 10, 20, 30, 60, 90, 120, 180, 240, 300 seconds
- [ ] Custom input with validation (5-300)
- [ ] Visual preview of timer appearance
- [ ] Default time limit setting per quiz
- [ ] Bulk update time for all questions
- [ ] Warning for very short times (<10s)
- [ ] Time pressure indicator in player view
- [ ] Auto-submit when time expires
- [ ] Grace period for network latency (2s)
- [ ] Different timer styles (bar, circle, digits)
- [ ] Audio countdown for last 5 seconds

## Navigation Flow

### Current State
```
Time limit dropdown exists in question builder
Domain models support 5-300 second range
No bulk operations or default settings
No timer preview or styles
```

### Required Implementation
```
1. Question Time Configuration:
   Question Editor
   ├── Time Limit Section
   │   ├── Quick Select (preset buttons)
   │   ├── Custom Input (with validation)
   │   ├── Preview Timer Animation
   │   └── Apply to All Option
   │
   └── Quiz Default Settings
       ├── Default time per question
       ├── Timer style selection
       └── Audio settings

2. Player Timer Experience:
   Active Question
   ├── Countdown Display
   │   ├── Visual timer (selected style)
   │   ├── Progress indication
   │   └── Color changes (green→yellow→red)
   ├── Audio Alerts
   │   ├── Tick sound (last 10s)
   │   ├── Warning sound (last 5s)
   │   └── Time up sound
   └── Auto-submission
       ├── Grace period check
       └── Mark as timeout
```

## Technical Implementation

### 1. Enhanced Time Configuration UI
```dart
// lib/features/quiz_creation/presentation/widgets/time_limit_selector.dart

class TimeLimitSelector extends ConsumerStatefulWidget {
  final int currentValue;
  final Function(int) onChanged;
  final bool showPreview;
  
  @override
  _TimeLimitSelectorState createState() => _TimeLimitSelectorState();
}

class _TimeLimitSelectorState extends ConsumerState<TimeLimitSelector> 
    with SingleTickerProviderStateMixin {
  late AnimationController _previewController;
  late TextEditingController _customController;
  bool _useCustom = false;
  
  static const presetTimes = [5, 10, 20, 30, 60, 90, 120, 180, 240, 300];
  
  @override
  void initState() {
    super.initState();
    _previewController = AnimationController(
      duration: Duration(seconds: widget.currentValue),
      vsync: this,
    );
    _customController = TextEditingController(
      text: presetTimes.contains(widget.currentValue) 
          ? '' 
          : widget.currentValue.toString(),
    );
    _useCustom = !presetTimes.contains(widget.currentValue);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with bulk action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Time Limit',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: _applyToAll,
              icon: const Icon(Icons.sync, size: 16),
              label: const Text('Apply to All'),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Preset buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetTimes.map((time) {
            final isSelected = widget.currentValue == time && !_useCustom;
            return ChoiceChip(
              label: Text(_formatTime(time)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _useCustom = false);
                  widget.onChanged(time);
                  _restartPreview(time);
                }
              },
            );
          }).toList(),
        ),
        
        const SizedBox(height: 12),
        
        // Custom input
        Row(
          children: [
            Checkbox(
              value: _useCustom,
              onChanged: (value) {
                setState(() => _useCustom = value!);
                if (value! && _customController.text.isNotEmpty) {
                  final customTime = int.tryParse(_customController.text);
                  if (customTime != null) {
                    widget.onChanged(customTime);
                    _restartPreview(customTime);
                  }
                }
              },
            ),
            const Text('Custom: '),
            SizedBox(
              width: 80,
              child: TextFormField(
                controller: _customController,
                enabled: _useCustom,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixText: 's',
                  isDense: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _TimeRangeFormatter(min: 5, max: 300),
                ],
                onChanged: (value) {
                  final time = int.tryParse(value);
                  if (time != null && time >= 5 && time <= 300) {
                    widget.onChanged(time);
                    _restartPreview(time);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            if (_useCustom && widget.currentValue < 10)
              Tooltip(
                message: 'Very short time limit may be difficult for players',
                child: Icon(
                  Icons.warning_amber,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
          ],
        ),
        
        // Timer preview
        if (widget.showPreview) ...[
          const SizedBox(height: 16),
          _buildTimerPreview(),
        ],
      ],
    );
  }
  
  Widget _buildTimerPreview() {
    final timerStyle = ref.watch(quizSettingsProvider).timerStyle;
    
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('Preview: '),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTimerWidget(timerStyle),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              _previewController.forward(from: 0);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimerWidget(TimerStyle style) {
    return AnimatedBuilder(
      animation: _previewController,
      builder: (context, child) {
        final progress = 1.0 - _previewController.value;
        final remaining = (widget.currentValue * progress).ceil();
        final color = _getTimerColor(progress);
        
        switch (style) {
          case TimerStyle.bar:
            return Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: -20,
                  child: Text(
                    '$remaining s',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
            
          case TimerStyle.circle:
            return SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeWidth: 6,
                  ),
                  Center(
                    child: Text(
                      '$remaining',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            );
            
          case TimerStyle.digits:
            return Text(
              _formatDigitalTime(remaining),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'monospace',
              ),
            );
        }
      },
    );
  }
  
  Color _getTimerColor(double progress) {
    if (progress > 0.5) return Colors.green;
    if (progress > 0.25) return Colors.orange;
    return Colors.red;
  }
  
  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) return '${minutes}m';
    return '${minutes}m ${remainingSeconds}s';
  }
  
  void _applyToAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply to All Questions'),
        content: Text(
          'Set all questions to ${_formatTime(widget.currentValue)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(quizCreationProvider.notifier)
                  .updateAllQuestionTimes(widget.currentValue);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Time limit applied to all questions'),
                ),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
```

### 2. Timer Settings Configuration
```dart
// lib/features/quiz_creation/presentation/pages/quiz_settings_page.dart

class QuizSettingsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(quizSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Default time limit
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Default Time Limit',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Applied to new questions',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TimeLimitSelector(
                    currentValue: settings.defaultTimeLimit,
                    onChanged: (value) {
                      ref.read(quizSettingsProvider.notifier)
                          .updateDefaultTime(value);
                    },
                    showPreview: false,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Timer style
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timer Style',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ...TimerStyle.values.map((style) {
                    return RadioListTile<TimerStyle>(
                      title: Text(style.displayName),
                      subtitle: Text(style.description),
                      value: style,
                      groupValue: settings.timerStyle,
                      onChanged: (value) {
                        ref.read(quizSettingsProvider.notifier)
                            .updateTimerStyle(value!);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Audio settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timer Audio',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Countdown Sounds'),
                    subtitle: const Text('Play tick sounds in last 10 seconds'),
                    value: settings.enableCountdownSounds,
                    onChanged: (value) {
                      ref.read(quizSettingsProvider.notifier)
                          .updateCountdownSounds(value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Warning Sound'),
                    subtitle: const Text('Alert when 5 seconds remain'),
                    value: settings.enableWarningSound,
                    onChanged: (value) {
                      ref.read(quizSettingsProvider.notifier)
                          .updateWarningSound(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. Player Timer Implementation
```dart
// lib/features/game/presentation/widgets/game_timer.dart

class GameTimer extends ConsumerStatefulWidget {
  final int totalSeconds;
  final VoidCallback onTimeUp;
  final TimerStyle style;
  
  @override
  _GameTimerState createState() => _GameTimerState();
}

class _GameTimerState extends ConsumerState<GameTimer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _audioPlayer;
  bool _hasPlayedWarning = false;
  Timer? _tickTimer;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: widget.totalSeconds),
      vsync: this,
    )..addListener(_onTimerTick);
    
    _audioPlayer = AudioPlayer();
    _controller.forward();
    
    // Start tick timer for audio
    if (ref.read(gameSettingsProvider).enableCountdownSounds) {
      _startTickTimer();
    }
  }
  
  void _onTimerTick() {
    final remaining = _getRemainingSeconds();
    
    // Warning at 5 seconds
    if (remaining <= 5 && !_hasPlayedWarning) {
      _hasPlayedWarning = true;
      if (ref.read(gameSettingsProvider).enableWarningSound) {
        _audioPlayer.play(AssetSource('sounds/warning.mp3'));
      }
    }
    
    // Time up
    if (_controller.isCompleted) {
      _audioPlayer.play(AssetSource('sounds/time_up.mp3'));
      widget.onTimeUp();
    }
  }
  
  void _startTickTimer() {
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = _getRemainingSeconds();
      if (remaining <= 10 && remaining > 0) {
        _audioPlayer.play(
          AssetSource('sounds/tick.mp3'),
          volume: 0.5,
        );
      }
    });
  }
  
  int _getRemainingSeconds() {
    return (widget.totalSeconds * (1 - _controller.value)).ceil();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = 1.0 - _controller.value;
        final remaining = _getRemainingSeconds();
        final color = _getTimerColor(progress);
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: _buildTimerWidget(
            style: widget.style,
            progress: progress,
            remaining: remaining,
            color: color,
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _tickTimer?.cancel();
    super.dispose();
  }
}
```

### 4. Network Latency Compensation
```dart
// lib/features/game/domain/services/answer_submission_service.dart

class AnswerSubmissionService {
  static const gracePeriodSeconds = 2;
  
  Future<AnswerResult> submitAnswer({
    required String sessionId,
    required String playerId,
    required int questionIndex,
    required int answerIndex,
    required DateTime questionStartTime,
    required int timeLimitSeconds,
  }) async {
    final now = DateTime.now();
    final elapsedSeconds = now.difference(questionStartTime).inSeconds;
    
    // Check if within time limit + grace period
    if (elapsedSeconds > timeLimitSeconds + gracePeriodSeconds) {
      return AnswerResult.timeout();
    }
    
    // Calculate actual response time (capped at time limit)
    final responseTime = min(elapsedSeconds, timeLimitSeconds);
    
    // Submit to server with timestamp
    final result = await _gameRepository.submitAnswer(
      sessionId: sessionId,
      playerId: playerId,
      questionIndex: questionIndex,
      answerIndex: answerIndex,
      responseTime: responseTime,
      clientTimestamp: now,
    );
    
    return result;
  }
}
```

### 5. Timer Analytics
```dart
// lib/features/analytics/domain/models/timer_analytics.dart

@freezed
class TimerAnalytics with _$TimerAnalytics {
  const factory TimerAnalytics({
    required String quizId,
    required Map<int, QuestionTimerStats> questionStats,
    required double averageResponseTime,
    required int timeoutCount,
    required double completionRate,
  }) = _TimerAnalytics;
  
  factory TimerAnalytics.fromGameSessions(
    List<GameSession> sessions,
  ) {
    // Calculate statistics
    final questionStats = <int, QuestionTimerStats>{};
    
    for (final session in sessions) {
      for (final answer in session.answers) {
        final stats = questionStats.putIfAbsent(
          answer.questionIndex,
          () => QuestionTimerStats.empty(),
        );
        
        questionStats[answer.questionIndex] = stats.addAnswer(
          answer.responseTime,
          answer.isTimeout,
        );
      }
    }
    
    return TimerAnalytics(
      quizId: sessions.first.quizId,
      questionStats: questionStats,
      averageResponseTime: _calculateAverage(questionStats),
      timeoutCount: _countTimeouts(questionStats),
      completionRate: _calculateCompletionRate(questionStats),
    );
  }
}
```

## Timer Styles

### Bar Style
- Horizontal progress bar
- Color transitions (green → yellow → red)
- Numeric countdown overlay

### Circle Style
- Circular progress indicator
- Center number display
- Smooth animation

### Digital Style
- Large digital clock format (MM:SS)
- Monospace font
- Color-coded urgency

## Audio Specifications

### Countdown Sounds
- **Tick**: Subtle click (last 10 seconds)
- **Warning**: Alert tone (5 seconds)
- **Time Up**: Distinctive finish sound

### Volume Control
- Respects device volume settings
- Mutable via game settings
- No audio in silent mode

## Testing Requirements

### Unit Tests
- [ ] Time validation logic
- [ ] Timer calculation accuracy
- [ ] Grace period handling
- [ ] Analytics calculations

### Integration Tests
- [ ] Timer synchronization
- [ ] Audio playback
- [ ] Network latency handling
- [ ] Settings persistence

### E2E Tests
- [ ] Set custom time limits
- [ ] Bulk update times
- [ ] Player timer experience
- [ ] Auto-submission
- [ ] Audio feedback

## Performance Considerations
- Efficient timer animations (60 FPS)
- Preload audio files
- Minimize timer update frequency
- Battery-efficient on mobile

## Related Issues
- Depends on: US-006 (Create quiz)
- Related: US-009 (Point values)
- Related: Game experience
- Enhances: Competitive gameplay

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Timer styles implemented
- [ ] Audio system working
- [ ] Grace period logic complete
- [ ] Analytics tracking ready
- [ ] Unit tests passing (>85% coverage)
- [ ] Integration tests passing
- [ ] Manual testing on all platforms
- [ ] Performance benchmarks met
- [ ] Accessibility verified