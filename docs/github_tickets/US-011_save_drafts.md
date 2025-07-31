# US-011: Save Quiz Drafts

## User Story
As a quiz creator, I want to save drafts so that I can work on quizzes over time.

## User Journey Map
```
Draft Management Flow:
1. Creator starts quiz → Auto-save begins
2. Leaves unexpectedly → Draft preserved
3. Returns later → Continue from draft
4. Multiple sessions → Progress tracked
5. Ready to publish → Convert draft to quiz
```

## Acceptance Criteria
- [ ] Auto-save every 30 seconds during editing
- [ ] Manual save button always visible
- [ ] Draft indicator shows save status
- [ ] List of drafts in dashboard
- [ ] Resume draft from where left off
- [ ] Draft expiry after 30 days
- [ ] Conflict resolution for concurrent edits
- [ ] Offline draft support
- [ ] Draft versioning (last 5 saves)
- [ ] Convert draft to published quiz
- [ ] Delete draft with confirmation
- [ ] Draft completion percentage shown

## Navigation Flow

### Current State
```
Draft state exists in domain model
No auto-save implementation
No draft recovery UI
No draft listing page
```

### Required Implementation
```
1. Draft Auto-Save Flow:
   Quiz Creation Active
   ├── Auto-Save Timer (30s)
   │   ├── Check for changes
   │   ├── Save to Firestore
   │   ├── Update UI indicator
   │   └── Handle failures
   │
   ├── Manual Save
   │   ├── Instant trigger
   │   ├── Show progress
   │   └── Confirmation toast
   │
   └── Exit Handling
       ├── Warn if unsaved
       ├── Quick save option
       └── Discard changes

2. Draft Management:
   /dashboard → Drafts Tab
   ├── Draft List
   │   ├── Title, progress, last edited
   │   ├── Resume button
   │   ├── Delete option
   │   └── Expire warning
   │
   └── Draft Detail (/draft/{id})
       ├── Continue editing
       ├── Preview draft
       ├── Version history
       └── Publish option
```

## Technical Implementation

### 1. Enhanced Draft Service
```dart
// lib/features/quiz_creation/data/services/draft_service.dart

@riverpod
class DraftService extends _$DraftService {
  Timer? _autoSaveTimer;
  final _saveDebouncer = Debouncer(milliseconds: 500);
  StreamSubscription? _connectivitySubscription;
  
  @override
  DraftState build() {
    ref.onDispose(() {
      _autoSaveTimer?.cancel();
      _saveDebouncer.dispose();
      _connectivitySubscription?.cancel();
    });
    
    return const DraftState.initial();
  }
  
  void startAutoSave(String quizId) {
    _autoSaveTimer?.cancel();
    
    state = state.copyWith(
      autoSaveEnabled: true,
      lastSaveTime: DateTime.now(),
    );
    
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _performAutoSave(quizId),
    );
    
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_handleConnectivityChange);
  }
  
  Future<void> _performAutoSave(String quizId) async {
    if (!state.hasUnsavedChanges) return;
    
    state = state.copyWith(saveStatus: SaveStatus.saving);
    
    try {
      final quiz = ref.read(quizCreationProvider).quiz;
      if (quiz == null) return;
      
      final draft = DraftModel(
        id: quizId,
        quiz: quiz,
        lastModified: DateTime.now(),
        version: state.currentVersion + 1,
        completionPercentage: _calculateCompletion(quiz),
        metadata: DraftMetadata(
          deviceId: await _getDeviceId(),
          appVersion: packageInfo.version,
          totalEditTime: state.totalEditTime,
        ),
      );
      
      // Save to Firestore
      await _saveDraftToFirestore(draft);
      
      // Save to local storage for offline
      await _saveDraftLocally(draft);
      
      state = state.copyWith(
        saveStatus: SaveStatus.saved,
        lastSaveTime: DateTime.now(),
        currentVersion: draft.version,
        hasUnsavedChanges: false,
      );
      
      // Keep version history
      await _updateVersionHistory(draft);
      
    } catch (e) {
      state = state.copyWith(
        saveStatus: SaveStatus.error,
        lastError: e.toString(),
      );
      
      // Retry with exponential backoff
      _scheduleRetry();
    }
  }
  
  Future<void> manualSave() async {
    _saveDebouncer.run(() => _performAutoSave(state.draftId!));
  }
  
  double _calculateCompletion(Quiz quiz) {
    double score = 0;
    
    // Metadata completion (30%)
    if (quiz.title.isNotEmpty) score += 10;
    if (quiz.description.isNotEmpty) score += 10;
    if (quiz.category != null) score += 10;
    
    // Questions completion (70%)
    if (quiz.questions.isNotEmpty) {
      final questionScore = 70.0 / max(5, quiz.questions.length);
      score += quiz.questions.length * questionScore;
      
      // Bonus for well-formed questions
      final completeQuestions = quiz.questions.where((q) {
        return q.text.length > 10 && 
               q.choices.length >= 2 &&
               q.correctAnswerIndex >= 0;
      }).length;
      
      score += (completeQuestions / quiz.questions.length) * 10;
    }
    
    return min(100, score);
  }
  
  Future<void> _saveDraftToFirestore(DraftModel draft) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    final draftRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('drafts')
        .doc(draft.id);
    
    await draftRef.set({
      ...draft.toJson(),
      'userId': user.uid,
      'serverTimestamp': FieldValue.serverTimestamp(),
    });
  }
  
  Future<void> _saveDraftLocally(DraftModel draft) async {
    final box = await Hive.openBox<String>('quiz_drafts');
    await box.put(draft.id, jsonEncode(draft.toJson()));
  }
  
  void _handleConnectivityChange(ConnectivityResult result) {
    if (result != ConnectivityResult.none && state.hasOfflineDrafts) {
      _syncOfflineDrafts();
    }
  }
}
```

### 2. Draft List UI
```dart
// lib/features/quiz_creation/presentation/pages/drafts_list_page.dart

class DraftsListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftsAsync = ref.watch(userDraftsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Drafts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDraftInfo(context),
          ),
        ],
      ),
      body: draftsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, stack) => ErrorWidget(error),
        data: (drafts) {
          if (drafts.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              final draft = drafts[index];
              return _DraftCard(
                draft: draft,
                onResume: () => _resumeDraft(context, ref, draft),
                onDelete: () => _deleteDraft(context, ref, draft),
                onPublish: () => _publishDraft(context, ref, draft),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.drafts,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No drafts yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start creating a quiz and it will auto-save here',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/quiz-creation'),
            icon: const Icon(Icons.add),
            label: const Text('Create Quiz'),
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final DraftModel draft;
  final VoidCallback onResume;
  final VoidCallback onDelete;
  final VoidCallback onPublish;
  
  @override
  Widget build(BuildContext context) {
    final timeAgo = timeago.format(draft.lastModified);
    final daysUntilExpiry = 30 - 
        DateTime.now().difference(draft.createdAt).inDays;
    final isExpiringSoon = daysUntilExpiry <= 7;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onResume,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      draft.quiz.title.isEmpty 
                          ? 'Untitled Quiz' 
                          : draft.quiz.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isExpiringSoon)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Expires in $daysUntilExpiry days',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Progress indicator
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: draft.completionPercentage / 100,
                        backgroundColor: Colors.grey[200],
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${draft.completionPercentage.round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Stats
              Row(
                children: [
                  _StatChip(
                    icon: Icons.quiz,
                    label: '${draft.quiz.questions.length} questions',
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.access_time,
                    label: 'Edited $timeAgo',
                  ),
                  if (draft.version > 1) ...[
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.history,
                      label: 'v${draft.version}',
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (draft.completionPercentage >= 60)
                    TextButton.icon(
                      onPressed: onPublish,
                      icon: const Icon(Icons.publish, size: 18),
                      label: const Text('Publish'),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Resume'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 3. Save Status Indicator
```dart
// lib/features/quiz_creation/presentation/widgets/save_status_indicator.dart

class SaveStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftState = ref.watch(draftServiceProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(draftState.saveStatus),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(draftState.saveStatus),
          const SizedBox(width: 8),
          Text(
            _getStatusText(draftState),
            style: TextStyle(
              fontSize: 12,
              color: _getTextColor(draftState.saveStatus),
            ),
          ),
          if (draftState.saveStatus == SaveStatus.error)
            TextButton(
              onPressed: () => ref.read(draftServiceProvider.notifier)
                  .manualSave(),
              child: const Text('Retry'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildIcon(SaveStatus status) {
    switch (status) {
      case SaveStatus.saving:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.blue),
          ),
        );
      case SaveStatus.saved:
        return const Icon(
          Icons.check_circle,
          size: 16,
          color: Colors.green,
        );
      case SaveStatus.error:
        return const Icon(
          Icons.error_outline,
          size: 16,
          color: Colors.red,
        );
      default:
        return const Icon(
          Icons.cloud_outlined,
          size: 16,
          color: Colors.grey,
        );
    }
  }
  
  String _getStatusText(DraftState state) {
    switch (state.saveStatus) {
      case SaveStatus.saving:
        return 'Saving...';
      case SaveStatus.saved:
        final timeAgo = timeago.format(state.lastSaveTime!);
        return 'Saved $timeAgo';
      case SaveStatus.error:
        return 'Save failed';
      default:
        return state.hasUnsavedChanges ? 'Unsaved changes' : 'All changes saved';
    }
  }
}
```

### 4. Conflict Resolution
```dart
// lib/features/quiz_creation/domain/services/draft_conflict_resolver.dart

class DraftConflictResolver {
  Future<DraftModel> resolveConflict({
    required DraftModel localDraft,
    required DraftModel remoteDraft,
  }) async {
    // If same version, no conflict
    if (localDraft.version == remoteDraft.version) {
      return localDraft;
    }
    
    // If remote is newer, show conflict dialog
    if (remoteDraft.lastModified.isAfter(localDraft.lastModified)) {
      final resolution = await _showConflictDialog(
        localDraft,
        remoteDraft,
      );
      
      switch (resolution) {
        case ConflictResolution.keepLocal:
          return localDraft.copyWith(
            version: remoteDraft.version + 1,
          );
        case ConflictResolution.keepRemote:
          return remoteDraft;
        case ConflictResolution.merge:
          return _mergeDrafts(localDraft, remoteDraft);
      }
    }
    
    // Local is newer, keep it
    return localDraft;
  }
  
  DraftModel _mergeDrafts(DraftModel local, DraftModel remote) {
    // Merge strategy: keep newer content for each field
    final mergedQuiz = local.quiz.copyWith(
      title: local.quiz.title.isNotEmpty 
          ? local.quiz.title 
          : remote.quiz.title,
      description: local.quiz.description.isNotEmpty
          ? local.quiz.description
          : remote.quiz.description,
      category: local.quiz.category ?? remote.quiz.category,
      questions: _mergeQuestions(
        local.quiz.questions,
        remote.quiz.questions,
      ),
    );
    
    return DraftModel(
      id: local.id,
      quiz: mergedQuiz,
      lastModified: DateTime.now(),
      version: max(local.version, remote.version) + 1,
      completionPercentage: max(
        local.completionPercentage,
        remote.completionPercentage,
      ),
    );
  }
}
```

### 5. Offline Draft Support
```dart
// lib/features/quiz_creation/data/repositories/offline_draft_repository.dart

class OfflineDraftRepository {
  static const String offlineQueueKey = 'offline_draft_queue';
  
  Future<void> queueOfflineDraft(DraftModel draft) async {
    final box = await Hive.openBox<String>(offlineQueueKey);
    final queue = await _getOfflineQueue();
    
    queue.add(OfflineDraft(
      draft: draft,
      queuedAt: DateTime.now(),
      syncAttempts: 0,
    ));
    
    await box.put('queue', jsonEncode(queue.map((e) => e.toJson()).toList()));
  }
  
  Future<void> syncOfflineDrafts() async {
    final queue = await _getOfflineQueue();
    if (queue.isEmpty) return;
    
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;
    
    for (final offlineDraft in queue) {
      try {
        await _syncDraft(offlineDraft);
        queue.remove(offlineDraft);
      } catch (e) {
        offlineDraft.syncAttempts++;
        if (offlineDraft.syncAttempts > 5) {
          // Move to failed queue
          await _moveToFailedQueue(offlineDraft);
          queue.remove(offlineDraft);
        }
      }
    }
    
    await _saveOfflineQueue(queue);
  }
}
```

## Draft Expiry Rules

### Expiry Timeline
- Active drafts: No expiry while being edited
- Inactive drafts: 30 days since last edit
- Warning: Email sent 7 days before expiry
- Grace period: 7 days after expiry (recoverable)
- Permanent deletion: After grace period

### Storage Quotas
- Free tier: 10 active drafts
- Draft size limit: 10MB including images
- Version history: Last 5 versions

## Testing Requirements

### Unit Tests
- [ ] Auto-save timer logic
- [ ] Completion calculation
- [ ] Conflict resolution
- [ ] Version management
- [ ] Offline queue handling

### Integration Tests
- [ ] Draft save to Firestore
- [ ] Draft recovery
- [ ] Concurrent edit handling
- [ ] Offline/online sync
- [ ] Expiry notifications

### E2E Tests
- [ ] Create and auto-save draft
- [ ] Leave and resume draft
- [ ] Publish from draft
- [ ] Delete draft
- [ ] Handle connectivity changes

## Performance Optimization
- Debounce saves to prevent overwrites
- Compress draft data before storage
- Lazy load draft list
- Background sync for offline drafts
- Efficient diff algorithm for changes

## Related Issues
- Depends on: US-006 (Create quiz)
- Related: Offline support
- Related: Version control
- Enhances: User experience

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Auto-save timer implemented
- [ ] Draft list UI complete
- [ ] Offline support working
- [ ] Conflict resolution tested
- [ ] Unit tests passing (>90% coverage)
- [ ] Integration tests passing
- [ ] Manual testing on all platforms
- [ ] Performance benchmarks met
- [ ] Documentation updated