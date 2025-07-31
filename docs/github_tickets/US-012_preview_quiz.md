# US-012: Preview Quiz Before Hosting

## User Story
As a quiz creator, I want to preview my quiz before hosting so that I can check for errors.

## User Journey Map
```
Preview Flow:
1. Creator finishes questions → Clicks preview
2. Sees quiz as player would → Full experience
3. Identifies issues → Notes corrections
4. Returns to edit → Makes changes
5. Final preview → Ready to publish
```

## Acceptance Criteria
- [ ] Preview button accessible from all creation steps
- [ ] Full player experience simulation
- [ ] See all questions in sequence
- [ ] Experience timers and scoring
- [ ] Test all answer interactions
- [ ] Preview on different screen sizes
- [ ] Note-taking during preview
- [ ] Quick edit shortcuts from preview
- [ ] Side-by-side edit/preview mode (tablet)
- [ ] Preview report with suggestions
- [ ] Accessibility check in preview
- [ ] No data saved from preview sessions

## Navigation Flow

### Current State
```
Preview page exists but empty
No preview functionality implemented
No player simulation
No preview-to-edit navigation
```

### Required Implementation
```
1. Preview Entry Points:
   Quiz Creation
   ├── Preview Button (header)
   ├── Step 3: Preview & Publish
   └── Keyboard shortcut (Ctrl+P)

2. Preview Mode:
   /quiz-creation/preview
   ├── Player Simulator
   │   ├── Start screen
   │   ├── Question flow
   │   ├── Timer simulation
   │   ├── Answer feedback
   │   └── Results screen
   │
   ├── Preview Controls
   │   ├── Pause/Resume
   │   ├── Skip question
   │   ├── Add note
   │   └── Exit preview
   │
   └── Review Mode
       ├── All questions list
       ├── Quick navigation
       └── Edit shortcuts
```

## Technical Implementation

### 1. Quiz Preview Page
```dart
// lib/features/quiz_creation/presentation/pages/quiz_preview_page.dart

class QuizPreviewPage extends ConsumerStatefulWidget {
  @override
  _QuizPreviewPageState createState() => _QuizPreviewPageState();
}

class _QuizPreviewPageState extends ConsumerState<QuizPreviewPage> {
  PreviewMode _mode = PreviewMode.player;
  final List<PreviewNote> _notes = [];
  int? _currentQuestionIndex;
  
  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizCreationProvider).quiz;
    
    if (quiz == null || quiz.questions.isEmpty) {
      return _buildEmptyState();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Quiz'),
        actions: [
          // Mode switcher
          SegmentedButton<PreviewMode>(
            segments: const [
              ButtonSegment(
                value: PreviewMode.player,
                icon: Icon(Icons.play_arrow),
                label: Text('Play'),
              ),
              ButtonSegment(
                value: PreviewMode.review,
                icon: Icon(Icons.list),
                label: Text('Review'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (set) {
              setState(() => _mode = set.first);
            },
          ),
          const SizedBox(width: 8),
          
          // Notes indicator
          if (_notes.isNotEmpty)
            Chip(
              avatar: const Icon(Icons.note, size: 16),
              label: Text('${_notes.length}'),
              backgroundColor: Colors.orange.shade100,
            ),
          
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _completePreview,
            tooltip: 'Finish Preview',
          ),
        ],
      ),
      body: _mode == PreviewMode.player
          ? _buildPlayerMode(quiz)
          : _buildReviewMode(quiz),
      
      // Floating note button
      floatingActionButton: _mode == PreviewMode.player
          ? FloatingActionButton(
              onPressed: _addNote,
              child: const Icon(Icons.note_add),
              tooltip: 'Add Note',
            )
          : null,
    );
  }
  
  Widget _buildPlayerMode(Quiz quiz) {
    return Column(
      children: [
        // Preview controls
        Container(
          color: Colors.amber.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Preview Mode - No scores will be saved',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: _showKeyboardShortcuts,
                child: const Text('Shortcuts'),
              ),
            ],
          ),
        ),
        
        // Player simulator
        Expanded(
          child: QuizPlayerSimulator(
            quiz: quiz,
            onQuestionChanged: (index) {
              setState(() => _currentQuestionIndex = index);
            },
            onComplete: _showPreviewResults,
            enableShortcuts: true,
            debugMode: true,
          ),
        ),
      ],
    );
  }
  
  Widget _buildReviewMode(Quiz quiz) {
    return Row(
      children: [
        // Question list
        SizedBox(
          width: 300,
          child: Card(
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Questions (${quiz.questions.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: quiz.questions.length,
                    itemBuilder: (context, index) {
                      final question = quiz.questions[index];
                      final hasNote = _notes.any((n) => n.questionIndex == index);
                      
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                          backgroundColor: hasNote 
                              ? Colors.orange 
                              : null,
                        ),
                        title: Text(
                          question.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${question.timeLimit}s • ${question.points} pts',
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: const ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Quick Edit'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'note',
                              child: const ListTile(
                                leading: Icon(Icons.note_add),
                                title: Text('Add Note'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _quickEdit(index);
                            } else {
                              _addNote(index);
                            }
                          },
                        ),
                        selected: _currentQuestionIndex == index,
                        onTap: () => _previewQuestion(index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Question preview
        Expanded(
          child: _currentQuestionIndex != null
              ? QuestionPreviewPanel(
                  question: quiz.questions[_currentQuestionIndex!],
                  questionNumber: _currentQuestionIndex! + 1,
                  onEdit: () => _quickEdit(_currentQuestionIndex!),
                )
              : _buildSelectQuestionPrompt(),
        ),
        
        // Notes panel
        if (_notes.isNotEmpty)
          SizedBox(
            width: 250,
            child: NotesPanel(
              notes: _notes,
              onNoteDeleted: (note) {
                setState(() => _notes.remove(note));
              },
              onNavigateToQuestion: (index) {
                setState(() => _currentQuestionIndex = index);
              },
            ),
          ),
      ],
    );
  }
}
```

### 2. Quiz Player Simulator
```dart
// lib/features/quiz_creation/presentation/widgets/quiz_player_simulator.dart

class QuizPlayerSimulator extends ConsumerStatefulWidget {
  final Quiz quiz;
  final Function(int)? onQuestionChanged;
  final Function(SimulatorResults)? onComplete;
  final bool enableShortcuts;
  final bool debugMode;
  
  @override
  _QuizPlayerSimulatorState createState() => _QuizPlayerSimulatorState();
}

class _QuizPlayerSimulatorState extends ConsumerState<QuizPlayerSimulator> {
  late PageController _pageController;
  int _currentQuestion = 0;
  final Map<int, SimulatedAnswer> _answers = {};
  GameState _state = GameState.lobby;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    if (widget.enableShortcuts) {
      _setupKeyboardShortcuts();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case GameState.lobby:
        return _buildLobby();
      case GameState.playing:
        return _buildQuestionView();
      case GameState.results:
        return _buildResults();
    }
  }
  
  Widget _buildLobby() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Quiz info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      widget.quiz.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (widget.quiz.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.quiz.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _InfoChip(
                          icon: Icons.quiz,
                          label: '${widget.quiz.questions.length} Questions',
                        ),
                        _InfoChip(
                          icon: Icons.timer,
                          label: _calculateTotalTime(),
                        ),
                        _InfoChip(
                          icon: Icons.star,
                          label: '${_calculateTotalPoints()} Points',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Start button
            ElevatedButton(
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Start Preview',
                style: TextStyle(fontSize: 18),
              ),
            ),
            
            if (widget.debugMode) ...[
              const SizedBox(height: 16),
              Text(
                'Debug Mode: Use arrow keys to navigate',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuestionView() {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: (_currentQuestion + 1) / widget.quiz.questions.length,
          backgroundColor: Colors.grey[200],
          minHeight: 6,
        ),
        
        // Question display
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.quiz.questions.length,
            onPageChanged: (index) {
              setState(() => _currentQuestion = index);
              widget.onQuestionChanged?.call(index);
            },
            itemBuilder: (context, index) {
              final question = widget.quiz.questions[index];
              return SimulatedQuestionView(
                question: question,
                questionNumber: index + 1,
                totalQuestions: widget.quiz.questions.length,
                onAnswerSelected: (answerIndex, responseTime) {
                  _recordAnswer(index, answerIndex, responseTime);
                },
                onTimeUp: () => _recordTimeout(index),
                debugMode: widget.debugMode,
              );
            },
          ),
        ),
        
        // Debug controls
        if (widget.debugMode)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _currentQuestion > 0 
                      ? _previousQuestion 
                      : null,
                  icon: const Icon(Icons.arrow_back),
                ),
                Text('${_currentQuestion + 1} / ${widget.quiz.questions.length}'),
                IconButton(
                  onPressed: _nextQuestion,
                  icon: const Icon(Icons.arrow_forward),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _skipToEnd,
                  child: const Text('Skip to End'),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  void _recordAnswer(int questionIndex, int answerIndex, int responseTime) {
    final question = widget.quiz.questions[questionIndex];
    final isCorrect = answerIndex == question.correctAnswerIndex;
    
    _answers[questionIndex] = SimulatedAnswer(
      questionIndex: questionIndex,
      selectedAnswer: answerIndex,
      isCorrect: isCorrect,
      responseTime: responseTime,
      points: isCorrect 
          ? _calculatePoints(question, responseTime)
          : 0,
    );
    
    // Auto-advance after feedback
    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }
}
```

### 3. Preview Notes System
```dart
// lib/features/quiz_creation/presentation/widgets/preview_notes.dart

class PreviewNote {
  final String id;
  final int? questionIndex;
  final String note;
  final DateTime createdAt;
  final PreviewNoteType type;
  
  PreviewNote({
    String? id,
    this.questionIndex,
    required this.note,
    DateTime? createdAt,
    this.type = PreviewNoteType.general,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
}

class AddNoteDialog extends StatefulWidget {
  final int? questionIndex;
  final String? questionText;
  
  @override
  _AddNoteDialogState createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _noteController = TextEditingController();
  PreviewNoteType _selectedType = PreviewNoteType.general;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.questionIndex != null
            ? 'Add Note for Question ${widget.questionIndex! + 1}'
            : 'Add General Note',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.questionText != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.questionText!,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Note type selector
          Wrap(
            spacing: 8,
            children: PreviewNoteType.values.map((type) {
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      size: 16,
                      color: _selectedType == type
                          ? Colors.white
                          : type.color,
                    ),
                    const SizedBox(width: 4),
                    Text(type.label),
                  ],
                ),
                selected: _selectedType == type,
                selectedColor: type.color,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedType = type);
                  }
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Note input
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: 'Enter your note...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _noteController.text.trim().isEmpty
              ? null
              : () {
                  final note = PreviewNote(
                    questionIndex: widget.questionIndex,
                    note: _noteController.text.trim(),
                    type: _selectedType,
                  );
                  Navigator.pop(context, note);
                },
          child: const Text('Add Note'),
        ),
      ],
    );
  }
}
```

### 4. Preview Report Generator
```dart
// lib/features/quiz_creation/domain/services/preview_report_service.dart

class PreviewReportService {
  PreviewReport generateReport({
    required Quiz quiz,
    required List<PreviewNote> notes,
    required SimulatorResults results,
  }) {
    final issues = <PreviewIssue>[];
    final suggestions = <PreviewSuggestion>[];
    
    // Check for common issues
    _checkQuestionQuality(quiz, issues);
    _checkTimeBalance(quiz, results, issues);
    _checkDifficulty(quiz, results, issues);
    _checkAccessibility(quiz, issues);
    
    // Generate suggestions
    _generateSuggestions(quiz, results, suggestions);
    
    // Calculate scores
    final scores = PreviewScores(
      content: _calculateContentScore(quiz),
      balance: _calculateBalanceScore(quiz, results),
      accessibility: _calculateAccessibilityScore(quiz),
      overall: _calculateOverallScore(quiz, results),
    );
    
    return PreviewReport(
      issues: issues,
      suggestions: suggestions,
      notes: notes,
      scores: scores,
      summary: _generateSummary(issues, suggestions, scores),
    );
  }
  
  void _checkQuestionQuality(Quiz quiz, List<PreviewIssue> issues) {
    for (var i = 0; i < quiz.questions.length; i++) {
      final question = quiz.questions[i];
      
      // Check question length
      if (question.text.length < 10) {
        issues.add(PreviewIssue(
          type: IssueType.content,
          severity: IssueSeverity.warning,
          questionIndex: i,
          message: 'Question text is very short',
          suggestion: 'Consider adding more context',
        ));
      }
      
      // Check answer choices
      if (question.choices.any((c) => c.trim().isEmpty)) {
        issues.add(PreviewIssue(
          type: IssueType.content,
          severity: IssueSeverity.error,
          questionIndex: i,
          message: 'Empty answer choice found',
        ));
      }
      
      // Check for duplicate answers
      final uniqueChoices = question.choices.toSet();
      if (uniqueChoices.length < question.choices.length) {
        issues.add(PreviewIssue(
          type: IssueType.content,
          severity: IssueSeverity.warning,
          questionIndex: i,
          message: 'Duplicate answer choices',
        ));
      }
    }
  }
}
```

### 5. Responsive Preview Modes
```dart
// lib/features/quiz_creation/presentation/widgets/responsive_preview.dart

class ResponsivePreviewContainer extends StatelessWidget {
  final Quiz quiz;
  final Widget Function(Size) builder;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop: side-by-side
        if (constraints.maxWidth > 1200) {
          return Row(
            children: [
              // Editor panel
              SizedBox(
                width: constraints.maxWidth * 0.4,
                child: QuizEditorPanel(quiz: quiz),
              ),
              
              // Divider
              const VerticalDivider(width: 1),
              
              // Preview panel
              Expanded(
                child: PreviewPanel(
                  quiz: quiz,
                  deviceFrame: DeviceFrame.desktop,
                ),
              ),
            ],
          );
        }
        
        // Tablet: overlay preview
        if (constraints.maxWidth > 768) {
          return Stack(
            children: [
              // Editor (full screen)
              QuizEditorPanel(quiz: quiz),
              
              // Preview overlay (draggable)
              DraggablePreviewOverlay(
                quiz: quiz,
                constraints: constraints,
              ),
            ],
          );
        }
        
        // Mobile: full screen preview
        return builder(Size(
          constraints.maxWidth,
          constraints.maxHeight,
        ));
      },
    );
  }
}
```

## Preview Features

### Simulation Options
- Normal speed playthrough
- Fast mode (instant answers)
- Slow mode (detailed inspection)
- Random answer mode
- Perfect score mode

### Accessibility Checks
- Color contrast validation
- Font size readability
- Screen reader compatibility
- Keyboard navigation test
- Touch target sizes

### Device Frames
- Mobile (iPhone, Android)
- Tablet (iPad, Android tablet)
- Desktop (browser window)
- Presentation mode (projector)

## Testing Requirements

### Unit Tests
- [ ] Preview state management
- [ ] Note system functionality
- [ ] Report generation logic
- [ ] Score calculations

### Integration Tests
- [ ] Full preview flow
- [ ] Note persistence
- [ ] Quick edit functionality
- [ ] Keyboard shortcuts
- [ ] Device switching

### E2E Tests
- [ ] Complete preview session
- [ ] Add and manage notes
- [ ] Generate report
- [ ] Quick edits from preview
- [ ] Responsive layouts

## Performance Considerations
- Lazy load questions in preview
- Optimize animations for smooth playback
- Cache preview state during session
- Efficient report generation

## Related Issues
- Depends on: US-006 (Create quiz)
- Related: US-013 (Duplicate quiz)
- Related: Accessibility
- Enhances: Quality assurance

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Player simulator complete
- [ ] Note system implemented
- [ ] Preview report working
- [ ] Responsive layouts verified
- [ ] Unit tests passing (>85% coverage)
- [ ] Integration tests passing
- [ ] Manual testing on all devices
- [ ] Performance verified
- [ ] Documentation updated