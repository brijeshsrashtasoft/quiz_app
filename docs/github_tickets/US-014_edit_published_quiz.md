# US-014: Edit Published Quizzes

## User Story
As a quiz creator, I want to edit published quizzes so that I can fix mistakes or update content.

## User Journey Map
```
Edit Flow:
1. Creator finds error → Opens quiz details
2. Clicks edit → Loads in editor
3. Makes corrections → Saves changes
4. Active games handled → Players notified
5. Version updated → History preserved
```

## Acceptance Criteria
- [ ] Edit button on owned published quizzes
- [ ] Load quiz data into editor
- [ ] Preserve all existing data
- [ ] Version tracking for changes
- [ ] Active game session handling
- [ ] Change summary required
- [ ] Notification to frequent players
- [ ] Rollback to previous version
- [ ] Edit history viewable
- [ ] Permissions check for ownership
- [ ] Prevent breaking changes during games
- [ ] Update cache and CDN

## Navigation Flow

### Current State
```
Edit route exists (/quiz/:id/edit)
No implementation for loading existing quiz
No version control system
No active game handling
```

### Required Implementation
```
1. Edit Entry Points:
   Quiz Detail Page
   ├── Edit Button (owner only)
   ├── Quick Edit Menu
   │   ├── Fix Typo
   │   ├── Update Time/Points
   │   └── Add/Remove Question
   └── Version History Link

2. Edit Flow:
   /quiz/{id}/edit
   ├── Load Quiz Data
   │   ├── Fetch from Firestore
   │   ├── Populate forms
   │   └── Track original state
   │
   ├── Edit Validation
   │   ├── Check active games
   │   ├── Warn about impacts
   │   └── Suggest safe window
   │
   └── Save Process
       ├── Version increment
       ├── Change summary
       ├── Update indexes
       └── Notify affected users
```

## Technical Implementation

### 1. Quiz Edit Page
```dart
// lib/features/quiz_creation/presentation/pages/quiz_edit_page.dart

class QuizEditPage extends ConsumerStatefulWidget {
  final String quizId;
  
  @override
  _QuizEditPageState createState() => _QuizEditPageState();
}

class _QuizEditPageState extends ConsumerState<QuizEditPage> {
  Quiz? _originalQuiz;
  bool _hasUnsavedChanges = false;
  final _changeTracker = ChangeTracker();
  
  @override
  void initState() {
    super.initState();
    _loadQuizForEditing();
  }
  
  Future<void> _loadQuizForEditing() async {
    final result = await ref.read(quizRepositoryProvider)
        .getQuiz(widget.quizId);
    
    result.fold(
      (failure) => _showError(failure),
      (quiz) async {
        // Check ownership
        final currentUser = ref.read(currentUserProvider);
        if (quiz.createdBy != currentUser?.uid) {
          _showPermissionError();
          return;
        }
        
        // Check for active games
        final activeGames = await _checkActiveGames(quiz.id!);
        if (activeGames.isNotEmpty) {
          final proceed = await _showActiveGamesWarning(activeGames);
          if (!proceed) {
            context.pop();
            return;
          }
        }
        
        // Load into editor
        setState(() => _originalQuiz = quiz);
        ref.read(quizCreationProvider.notifier).loadQuiz(quiz);
        
        // Start change tracking
        _changeTracker.startTracking(quiz);
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_originalQuiz == null) {
      return const LoadingScaffold();
    }
    
    final currentQuiz = ref.watch(quizCreationProvider).quiz;
    _hasUnsavedChanges = _changeTracker.hasChanges(currentQuiz);
    
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          return await _showUnsavedChangesDialog();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Quiz'),
          actions: [
            // Version info
            Chip(
              label: Text('v${_originalQuiz!.version}'),
              avatar: const Icon(Icons.history, size: 16),
            ),
            
            const SizedBox(width: 8),
            
            // Save button
            if (_hasUnsavedChanges)
              ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
          ],
        ),
        body: Column(
          children: [
            // Change summary bar
            if (_hasUnsavedChanges)
              Container(
                color: Colors.orange.shade100,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _changeTracker.getSummary(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton(
                      onPressed: _viewChanges,
                      child: const Text('View Changes'),
                    ),
                  ],
                ),
              ),
            
            // Editor content
            Expanded(
              child: QuizCreationForm(
                mode: QuizFormMode.edit,
                onStepChanged: (step) {
                  // Track navigation for analytics
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveChanges() async {
    // Validate changes
    final validation = _validateChanges();
    if (!validation.isValid) {
      _showValidationErrors(validation.errors);
      return;
    }
    
    // Get change summary
    final changeSummary = await _showChangeSummaryDialog();
    if (changeSummary == null) return;
    
    // Show saving progress
    final progressDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SaveProgressDialog(),
    );
    
    try {
      final currentQuiz = ref.read(quizCreationProvider).quiz!;
      
      // Create new version
      final updatedQuiz = currentQuiz.copyWith(
        version: _originalQuiz!.version + 1,
        updatedAt: DateTime.now(),
        lastEditedBy: ref.read(currentUserProvider)!.uid,
      );
      
      // Save to repository
      final result = await ref.read(quizRepositoryProvider)
          .updateQuiz(updatedQuiz);
      
      await result.fold(
        (failure) async {
          Navigator.pop(context); // Close progress
          _showError(failure);
        },
        (_) async {
          // Create version record
          await _createVersionRecord(
            _originalQuiz!,
            updatedQuiz,
            changeSummary,
          );
          
          // Notify affected users
          await _notifyAffectedUsers(updatedQuiz);
          
          // Clear change tracking
          _changeTracker.reset();
          
          Navigator.pop(context); // Close progress
          
          // Show success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to updated quiz
          context.go('/quiz/${updatedQuiz.id}');
        },
      );
    } catch (e) {
      Navigator.pop(context); // Close progress
      _showError(e);
    }
  }
}
```

### 2. Change Tracking System
```dart
// lib/features/quiz_creation/domain/services/change_tracker.dart

class ChangeTracker {
  Quiz? _originalQuiz;
  final List<Change> _changes = [];
  
  void startTracking(Quiz quiz) {
    _originalQuiz = quiz.copyWith();
    _changes.clear();
  }
  
  bool hasChanges(Quiz? currentQuiz) {
    if (_originalQuiz == null || currentQuiz == null) return false;
    
    _detectChanges(_originalQuiz!, currentQuiz);
    return _changes.isNotEmpty;
  }
  
  void _detectChanges(Quiz original, Quiz current) {
    _changes.clear();
    
    // Metadata changes
    if (original.title != current.title) {
      _changes.add(Change(
        type: ChangeType.metadata,
        field: 'title',
        oldValue: original.title,
        newValue: current.title,
      ));
    }
    
    if (original.description != current.description) {
      _changes.add(Change(
        type: ChangeType.metadata,
        field: 'description',
        oldValue: original.description,
        newValue: current.description,
      ));
    }
    
    if (original.category != current.category) {
      _changes.add(Change(
        type: ChangeType.metadata,
        field: 'category',
        oldValue: original.category?.name,
        newValue: current.category?.name,
      ));
    }
    
    // Question changes
    _detectQuestionChanges(original.questions, current.questions);
    
    // Settings changes
    _detectSettingsChanges(original.settings, current.settings);
  }
  
  void _detectQuestionChanges(
    List<Question> original,
    List<Question> current,
  ) {
    // Added questions
    final addedQuestions = current.where((q) => 
      !original.any((oq) => oq.id == q.id),
    ).toList();
    
    for (final question in addedQuestions) {
      _changes.add(Change(
        type: ChangeType.questionAdded,
        field: 'question',
        newValue: question.text,
      ));
    }
    
    // Removed questions
    final removedQuestions = original.where((q) => 
      !current.any((cq) => cq.id == q.id),
    ).toList();
    
    for (final question in removedQuestions) {
      _changes.add(Change(
        type: ChangeType.questionRemoved,
        field: 'question',
        oldValue: question.text,
      ));
    }
    
    // Modified questions
    for (final currentQuestion in current) {
      final originalQuestion = original.firstWhereOrNull(
        (q) => q.id == currentQuestion.id,
      );
      
      if (originalQuestion != null) {
        _detectQuestionModifications(
          originalQuestion,
          currentQuestion,
        );
      }
    }
  }
  
  String getSummary() {
    if (_changes.isEmpty) return 'No changes';
    
    final summary = <String>[];
    
    final metadataChanges = _changes
        .where((c) => c.type == ChangeType.metadata)
        .length;
    if (metadataChanges > 0) {
      summary.add('$metadataChanges metadata changes');
    }
    
    final addedQuestions = _changes
        .where((c) => c.type == ChangeType.questionAdded)
        .length;
    if (addedQuestions > 0) {
      summary.add('$addedQuestions questions added');
    }
    
    final removedQuestions = _changes
        .where((c) => c.type == ChangeType.questionRemoved)
        .length;
    if (removedQuestions > 0) {
      summary.add('$removedQuestions questions removed');
    }
    
    final modifiedQuestions = _changes
        .where((c) => c.type == ChangeType.questionModified)
        .length;
    if (modifiedQuestions > 0) {
      summary.add('$modifiedQuestions questions modified');
    }
    
    return summary.join(', ');
  }
}
```

### 3. Version Control System
```dart
// lib/features/quiz_creation/domain/services/quiz_version_service.dart

@injectable
class QuizVersionService {
  final FirebaseFirestore _firestore;
  
  Future<void> createVersion({
    required Quiz previousVersion,
    required Quiz newVersion,
    required String changeSummary,
    required String editedBy,
  }) async {
    final versionDoc = QuizVersion(
      quizId: newVersion.id!,
      version: newVersion.version,
      previousVersion: previousVersion.version,
      createdAt: DateTime.now(),
      createdBy: editedBy,
      changeSummary: changeSummary,
      changes: _generateChangeLog(previousVersion, newVersion),
      snapshot: previousVersion.toJson(), // Store full snapshot
    );
    
    await _firestore
        .collection('quizzes')
        .doc(newVersion.id)
        .collection('versions')
        .doc('v${previousVersion.version}')
        .set(versionDoc.toJson());
  }
  
  Future<List<QuizVersion>> getVersionHistory(String quizId) async {
    final snapshot = await _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('versions')
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => QuizVersion.fromJson(doc.data()))
        .toList();
  }
  
  Future<Quiz> rollbackToVersion({
    required String quizId,
    required int targetVersion,
  }) async {
    // Get version snapshot
    final versionDoc = await _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('versions')
        .doc('v$targetVersion')
        .get();
    
    if (!versionDoc.exists) {
      throw Exception('Version not found');
    }
    
    final versionData = QuizVersion.fromJson(versionDoc.data()!);
    final rolledBackQuiz = Quiz.fromJson(versionData.snapshot);
    
    // Create new version for rollback
    final currentQuiz = await _getCurrentQuiz(quizId);
    await createVersion(
      previousVersion: currentQuiz,
      newVersion: rolledBackQuiz.copyWith(
        version: currentQuiz.version + 1,
      ),
      changeSummary: 'Rolled back to version $targetVersion',
      editedBy: FirebaseAuth.instance.currentUser!.uid,
    );
    
    return rolledBackQuiz;
  }
}
```

### 4. Active Game Handling
```dart
// lib/features/quiz_creation/domain/services/active_game_monitor.dart

@injectable
class ActiveGameMonitor {
  final GameSessionRepository _gameRepository;
  
  Future<List<ActiveGameInfo>> checkActiveGames(String quizId) async {
    final activeSessions = await _gameRepository
        .getActiveSessionsForQuiz(quizId);
    
    return activeSessions.map((session) => ActiveGameInfo(
      sessionId: session.id,
      hostName: session.hostName,
      playerCount: session.players.length,
      startedAt: session.startedAt,
      currentQuestion: session.currentQuestionIndex,
      estimatedEndTime: _estimateEndTime(session),
    )).toList();
  }
  
  Future<void> notifyActiveSessions({
    required String quizId,
    required QuizUpdateNotification notification,
  }) async {
    final sessions = await _gameRepository
        .getActiveSessionsForQuiz(quizId);
    
    for (final session in sessions) {
      // Send notification to host
      await _sendNotificationToHost(
        session.hostId,
        notification,
      );
      
      // Send notification to players if significant
      if (notification.severity == UpdateSeverity.breaking) {
        for (final player in session.players) {
          await _sendNotificationToPlayer(
            player.id,
            notification,
          );
        }
      }
    }
  }
  
  DateTime _estimateEndTime(GameSession session) {
    final quiz = session.quiz;
    final remainingQuestions = quiz.questions.length - 
        session.currentQuestionIndex;
    
    final avgTimePerQuestion = quiz.questions
        .skip(session.currentQuestionIndex)
        .fold(0, (sum, q) => sum + q.timeLimit) / 
        remainingQuestions;
    
    final remainingTime = remainingQuestions * 
        (avgTimePerQuestion + 5); // 5s buffer between questions
    
    return DateTime.now().add(Duration(seconds: remainingTime.toInt()));
  }
}
```

### 5. Change Summary Dialog
```dart
// lib/features/quiz_creation/presentation/dialogs/change_summary_dialog.dart

class ChangeSummaryDialog extends StatefulWidget {
  final List<Change> changes;
  final Quiz originalQuiz;
  final Quiz updatedQuiz;
  
  @override
  _ChangeSummaryDialogState createState() => _ChangeSummaryDialogState();
}

class _ChangeSummaryDialogState extends State<ChangeSummaryDialog> {
  final _summaryController = TextEditingController();
  bool _notifyPlayers = true;
  UpdateSeverity _severity = UpdateSeverity.minor;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Summary of Changes'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Changes list
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.changes.length,
                itemBuilder: (context, index) {
                  final change = widget.changes[index];
                  return ListTile(
                    leading: Icon(
                      change.type.icon,
                      color: change.type.color,
                      size: 20,
                    ),
                    title: Text(change.description),
                    dense: true,
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Summary input
            TextField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Change Summary *',
                hintText: 'Brief description of changes',
                helperText: 'This will be shown in version history',
              ),
              maxLines: 2,
              maxLength: 200,
            ),
            
            const SizedBox(height: 16),
            
            // Severity selection
            Text(
              'Update Severity',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...UpdateSeverity.values.map((severity) {
              return RadioListTile<UpdateSeverity>(
                title: Text(severity.label),
                subtitle: Text(severity.description),
                value: severity,
                groupValue: _severity,
                onChanged: (value) {
                  setState(() => _severity = value!);
                },
                dense: true,
              );
            }),
            
            const SizedBox(height: 16),
            
            // Notification option
            SwitchListTile(
              title: const Text('Notify frequent players'),
              subtitle: const Text(
                'Send update notification to users who played recently',
              ),
              value: _notifyPlayers,
              onChanged: (value) {
                setState(() => _notifyPlayers = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _summaryController.text.trim().isEmpty
              ? null
              : () {
                  Navigator.pop(
                    context,
                    ChangeSummaryResult(
                      summary: _summaryController.text.trim(),
                      severity: _severity,
                      notifyPlayers: _notifyPlayers,
                    ),
                  );
                },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
```

## Edit Validation Rules

### Breaking Changes
- Removing questions
- Changing correct answers
- Significant time limit reduction
- Major point value changes

### Safe Changes
- Fixing typos
- Adding questions
- Increasing time limits
- Adding images
- Updating descriptions

### Active Game Rules
- Warn if games active
- Suggest waiting period
- Force flag for urgent fixes
- Queue changes for after games

## Version Management

### Version Storage
- Full snapshot per version
- Change log details
- Editor information
- Timestamp tracking

### Version Limits
- Keep last 20 versions
- Archive older versions
- Compress snapshots
- Cleanup policy

## Testing Requirements

### Unit Tests
- [ ] Change detection logic
- [ ] Version creation
- [ ] Permission checks
- [ ] Validation rules

### Integration Tests
- [ ] Load quiz for editing
- [ ] Save edited quiz
- [ ] Version history
- [ ] Active game checks
- [ ] Rollback functionality

### E2E Tests
- [ ] Complete edit flow
- [ ] Change tracking UI
- [ ] Version history viewing
- [ ] Notification delivery
- [ ] Cache updates

## Performance Considerations
- Efficient diff algorithm
- Lazy load version history
- Background notification sending
- CDN cache invalidation
- Optimistic UI updates

## Related Issues
- Depends on: US-006 (Create quiz)
- Related: US-013 (Duplicate quiz)
- Related: Version control
- Enhances: Content quality

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Edit flow implemented
- [ ] Change tracking working
- [ ] Version system complete
- [ ] Active game handling ready
- [ ] Unit tests passing (>90% coverage)
- [ ] Integration tests passing
- [ ] Manual testing completed
- [ ] Performance verified
- [ ] Documentation updated