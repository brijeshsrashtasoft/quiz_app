# US-009: Assign Point Values to Questions

## User Story
As a quiz creator, I want to assign different point values to questions so that I can weight difficult questions appropriately.

## User Journey Map
```
Point Configuration Flow:
1. Creator editing question → Sees points field
2. Sets custom point value → Based on difficulty
3. Reviews point distribution → Ensures balance
4. Players see points → Motivates strategic play
5. Leaderboard reflects → Weighted scoring
```

## Acceptance Criteria
- [ ] Point value selector per question (10-1000)
- [ ] Preset point options: 10, 20, 50, 100, 200, 500, 1000
- [ ] Custom point input with validation
- [ ] Total quiz points displayed
- [ ] Point distribution visualization
- [ ] Bulk point assignment by difficulty
- [ ] Speed bonus calculation preview
- [ ] Point multipliers for streaks (future)
- [ ] Warning for unbalanced distribution
- [ ] Points visible to players before answering
- [ ] Animated point gain on correct answer
- [ ] Clear scoring explanation

## Navigation Flow

### Current State
```
Point dropdown exists in question builder
Domain supports 10-1000 point range
No distribution visualization
No bulk operations or analytics
```

### Required Implementation
```
1. Point Configuration UI:
   Question Editor
   ├── Point Value Section
   │   ├── Quick Select Chips
   │   ├── Custom Input Field
   │   ├── Difficulty-based Suggestion
   │   └── Speed Bonus Preview
   │
   ├── Quiz Overview Panel
   │   ├── Total Points Display
   │   ├── Average Points/Question
   │   ├── Distribution Chart
   │   └── Balance Analysis
   │
   └── Bulk Operations
       ├── Auto-assign by Difficulty
       ├── Distribute Evenly
       └── Apply Multiplier

2. Player Point Experience:
   Question Display
   ├── Point Value Badge
   ├── Potential Score Preview
   └── Speed Bonus Indicator
   
   Answer Feedback
   ├── Base Points Earned
   ├── Speed Bonus Applied
   ├── Total Score Animation
   └── Leaderboard Update
```

## Technical Implementation

### 1. Enhanced Point Value Selector
```dart
// lib/features/quiz_creation/presentation/widgets/point_value_selector.dart

class PointValueSelector extends ConsumerStatefulWidget {
  final int currentValue;
  final Function(int) onChanged;
  final int? suggestedValue;
  final int questionTimeLimit;
  
  @override
  _PointValueSelectorState createState() => _PointValueSelectorState();
}

class _PointValueSelectorState extends ConsumerState<PointValueSelector> {
  static const presetPoints = [10, 20, 50, 100, 200, 500, 1000];
  late TextEditingController _customController;
  bool _useCustom = false;
  
  @override
  void initState() {
    super.initState();
    _customController = TextEditingController(
      text: presetPoints.contains(widget.currentValue)
          ? ''
          : widget.currentValue.toString(),
    );
    _useCustom = !presetPoints.contains(widget.currentValue);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with suggestion
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Point Value',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (widget.suggestedValue != null)
              TextButton.icon(
                onPressed: () {
                  widget.onChanged(widget.suggestedValue!);
                  setState(() => _useCustom = false);
                },
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: Text('Suggested: ${widget.suggestedValue}'),
              ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Preset chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetPoints.map((points) {
            final isSelected = widget.currentValue == points && !_useCustom;
            return ChoiceChip(
              label: Text('$points pts'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _useCustom = false);
                  widget.onChanged(points);
                }
              },
              avatar: _getPointIcon(points),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 12),
        
        // Custom input
        Row(
          children: [
            Checkbox(
              value: _useCustom,
              onChanged: (value) => setState(() => _useCustom = value!),
            ),
            const Text('Custom: '),
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: _customController,
                enabled: _useCustom,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixText: 'pts',
                  isDense: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _PointRangeFormatter(min: 10, max: 1000),
                ],
                onChanged: (value) {
                  final points = int.tryParse(value);
                  if (points != null && points >= 10 && points <= 1000) {
                    widget.onChanged(points);
                  }
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Scoring preview
        _buildScoringPreview(),
      ],
    );
  }
  
  Widget _buildScoringPreview() {
    final basePoints = widget.currentValue;
    final maxSpeedBonus = basePoints ~/ 2;
    final timeLimit = widget.questionTimeLimit;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Scoring Preview',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Base points: $basePoints',
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            'Max speed bonus: +$maxSpeedBonus (instant answer)',
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            'Min points: ${basePoints ~/ 2} (last second)',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          _buildSpeedBonusChart(basePoints, timeLimit),
        ],
      ),
    );
  }
  
  Widget _buildSpeedBonusChart(int basePoints, int timeLimit) {
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: SpeedBonusChartPainter(
          basePoints: basePoints,
          timeLimit: timeLimit,
        ),
        child: Container(),
      ),
    );
  }
  
  Widget? _getPointIcon(int points) {
    if (points <= 20) return const Icon(Icons.star_border, size: 16);
    if (points <= 100) return const Icon(Icons.star_half, size: 16);
    return const Icon(Icons.star, size: 16, color: Colors.amber);
  }
}
```

### 2. Quiz Point Distribution Visualization
```dart
// lib/features/quiz_creation/presentation/widgets/point_distribution_chart.dart

class PointDistributionChart extends ConsumerWidget {
  final List<Question> questions;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distribution = _calculateDistribution();
    final totalPoints = questions.fold(0, (sum, q) => sum + q.points);
    final averagePoints = totalPoints ~/ max(questions.length, 1);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Point Distribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Summary stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Total Points',
                  value: totalPoints.toString(),
                  icon: Icons.summarize,
                ),
                _StatItem(
                  label: 'Average',
                  value: averagePoints.toString(),
                  icon: Icons.analytics,
                ),
                _StatItem(
                  label: 'Questions',
                  value: questions.length.toString(),
                  icon: Icons.quiz,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Distribution bars
            ...distribution.entries.map((entry) {
              final percentage = entry.value / questions.length;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        minHeight: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 16),
            
            // Balance analysis
            _buildBalanceAnalysis(distribution),
            
            const SizedBox(height: 16),
            
            // Bulk actions
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _autoAssignPoints(context, ref),
                  icon: const Icon(Icons.auto_fix_high, size: 16),
                  label: const Text('Auto-assign'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _distributeEvenly(context, ref),
                  icon: const Icon(Icons.equalizer, size: 16),
                  label: const Text('Distribute Evenly'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Map<String, int> _calculateDistribution() {
    final ranges = {
      '10-50': 0,
      '51-100': 0,
      '101-200': 0,
      '201-500': 0,
      '501-1000': 0,
    };
    
    for (final question in questions) {
      if (question.points <= 50) ranges['10-50'] = ranges['10-50']! + 1;
      else if (question.points <= 100) ranges['51-100'] = ranges['51-100']! + 1;
      else if (question.points <= 200) ranges['101-200'] = ranges['101-200']! + 1;
      else if (question.points <= 500) ranges['201-500'] = ranges['201-500']! + 1;
      else ranges['501-1000'] = ranges['501-1000']! + 1;
    }
    
    return ranges;
  }
  
  Widget _buildBalanceAnalysis(Map<String, int> distribution) {
    final analysis = _analyzeBalance(distribution);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: analysis.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: analysis.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(analysis.icon, color: analysis.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analysis.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: analysis.color,
                  ),
                ),
                Text(
                  analysis.message,
                  style: TextStyle(fontSize: 12, color: analysis.color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. Scoring Engine with Speed Bonus
```dart
// lib/features/game/domain/services/scoring_service.dart

class ScoringService {
  static const double speedBonusRatio = 0.5; // 50% of base points
  
  int calculateScore({
    required int basePoints,
    required int timeLimitSeconds,
    required int responseTimeSeconds,
    required bool isCorrect,
  }) {
    if (!isCorrect) return 0;
    
    // Base points (50% of total possible)
    final baseScore = basePoints ~/ 2;
    
    // Speed bonus (up to 50% of total possible)
    final speedRatio = 1.0 - (responseTimeSeconds / timeLimitSeconds);
    final speedBonus = (basePoints * speedBonusRatio * speedRatio).round();
    
    return baseScore + speedBonus;
  }
  
  StreakBonus calculateStreakBonus(int consecutiveCorrect) {
    // Future implementation for streak multipliers
    if (consecutiveCorrect < 3) return StreakBonus.none;
    if (consecutiveCorrect < 5) return StreakBonus.bronze;
    if (consecutiveCorrect < 10) return StreakBonus.silver;
    return StreakBonus.gold;
  }
  
  Map<String, dynamic> getDetailedScore({
    required int basePoints,
    required int timeLimitSeconds,
    required int responseTimeSeconds,
    required bool isCorrect,
    required int streak,
  }) {
    if (!isCorrect) {
      return {
        'total': 0,
        'base': 0,
        'speedBonus': 0,
        'streakMultiplier': 1.0,
        'breakdown': 'Incorrect answer',
      };
    }
    
    final baseScore = basePoints ~/ 2;
    final speedRatio = 1.0 - (responseTimeSeconds / timeLimitSeconds);
    final speedBonus = (basePoints * speedBonusRatio * speedRatio).round();
    final streakBonus = calculateStreakBonus(streak);
    final multiplier = streakBonus.multiplier;
    
    final total = ((baseScore + speedBonus) * multiplier).round();
    
    return {
      'total': total,
      'base': baseScore,
      'speedBonus': speedBonus,
      'streakMultiplier': multiplier,
      'breakdown': 'Base: $baseScore + Speed: $speedBonus'
          '${multiplier > 1 ? ' × ${multiplier}x streak' : ''}',
    };
  }
}
```

### 4. Player Point Display
```dart
// lib/features/game/presentation/widgets/question_display.dart

class QuestionPointBadge extends StatelessWidget {
  final int points;
  final bool showSpeedBonus;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade600,
            Colors.amber.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$points pts',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (showSpeedBonus) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: 'Answer quickly for bonus points!',
              child: Icon(
                Icons.speed,
                color: Colors.white.withOpacity(0.8),
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

### 5. Point Animation on Correct Answer
```dart
// lib/features/game/presentation/widgets/point_gain_animation.dart

class PointGainAnimation extends StatefulWidget {
  final int basePoints;
  final int speedBonus;
  final int totalPoints;
  final VoidCallback onComplete;
  
  @override
  _PointGainAnimationState createState() => _PointGainAnimationState();
}

class _PointGainAnimationState extends State<PointGainAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
    ));
    
    _controller.forward().then((_) {
      widget.onComplete();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Base points
                  Text(
                    '+${widget.basePoints}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
                  ),
                  
                  // Speed bonus
                  if (widget.speedBonus > 0)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: widget.speedBonus.toDouble()),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        return Text(
                          '+${value.round()} speed bonus!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange.shade600,
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Total
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Total: ${widget.totalPoints}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## Point Distribution Guidelines

### Recommended Distribution
- **Easy questions**: 10-50 points (quick, basic knowledge)
- **Medium questions**: 100-200 points (moderate difficulty)
- **Hard questions**: 500-1000 points (complex, time-consuming)

### Balance Indicators
- **Well-balanced**: Mix of all difficulty levels
- **Top-heavy**: Too many high-point questions
- **Bottom-heavy**: Too many low-point questions
- **Uniform**: All questions same points (boring)

## Testing Requirements

### Unit Tests
- [ ] Point calculation logic
- [ ] Speed bonus formula
- [ ] Distribution analysis
- [ ] Validation rules

### Integration Tests
- [ ] Bulk point operations
- [ ] Score persistence
- [ ] Animation timing
- [ ] Leaderboard updates

### E2E Tests
- [ ] Set custom points
- [ ] Auto-assign points
- [ ] Player sees points
- [ ] Score calculation
- [ ] Animation display

## Performance Considerations
- Efficient score calculations
- Smooth point animations
- Precompute distributions
- Cache scoring results

## Related Issues
- Depends on: US-006 (Create quiz)
- Related: US-008 (Time limits)
- Related: US-031 (Leaderboard)
- Enhances: Competitive strategy

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Point selector enhanced
- [ ] Distribution chart working
- [ ] Scoring engine complete
- [ ] Animations implemented
- [ ] Unit tests passing (>85% coverage)
- [ ] Integration tests passing
- [ ] Manual testing on all platforms
- [ ] Performance verified
- [ ] Documentation updated