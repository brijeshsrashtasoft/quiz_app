# US-013: Duplicate Existing Quizzes

## User Story
As a quiz creator, I want to duplicate existing quizzes so that I can create variations quickly.

## User Journey Map
```
Duplication Flow:
1. Creator views quiz list → Sees duplicate option
2. Clicks duplicate → Creates instant copy
3. Copy opens in editor → With new title
4. Makes modifications → Saves as new quiz
5. Both versions available → Different IDs
```

## Acceptance Criteria
- [ ] Duplicate option in quiz actions menu
- [ ] Instant copy with "(Copy)" suffix
- [ ] New unique ID generated
- [ ] All questions and settings copied
- [ ] Images duplicated with new references
- [ ] Creation date reset to now
- [ ] Play statistics not copied
- [ ] Edit history starts fresh
- [ ] Option to duplicate from others' quizzes
- [ ] Bulk duplicate for quiz series
- [ ] Attribution to original (if public)
- [ ] Duplicate count tracking

## Navigation Flow

### Current State
```
No duplication functionality
No UI for duplicate action
No copy logic implemented
```

### Required Implementation
```
1. Duplicate Actions:
   Quiz List/Detail
   ├── Action Menu
   │   ├── Duplicate option
   │   ├── Keyboard shortcut (Ctrl+D)
   │   └── Confirmation (if has images)
   │
   └── Duplicate Process
       ├── Create copy in memory
       ├── Generate new IDs
       ├── Copy resources
       └── Open in editor

2. Duplication Options:
   Duplicate Dialog
   ├── Basic Duplicate
   │   └── Exact copy
   ├── Advanced Options
   │   ├── Include/exclude images
   │   ├── Number of copies
   │   ├── Name pattern
   │   └── Category override
   └── Series Creation
       ├── Part 1, 2, 3...
       └── Version A, B, C...
```

## Technical Implementation

### 1. Quiz Duplication Service
```dart
// lib/features/quiz_creation/domain/services/quiz_duplication_service.dart

@injectable
class QuizDuplicationService {
  final QuizRepository _quizRepository;
  final ImageDuplicationService _imageService;
  final AuthenticationRepository _authRepository;
  
  Future<Either<Failure, String>> duplicateQuiz({
    required String sourceQuizId,
    DuplicationOptions? options,
  }) async {
    try {
      // Get source quiz
      final sourceResult = await _quizRepository.getQuiz(sourceQuizId);
      
      return sourceResult.fold(
        (failure) => Left(failure),
        (sourceQuiz) async {
          // Check permissions
          final canDuplicate = await _checkDuplicationPermission(sourceQuiz);
          if (!canDuplicate) {
            return const Left(
              QuizFailure.permissionDenied('Cannot duplicate this quiz'),
            );
          }
          
          // Create duplicate
          final duplicatedQuiz = await _createDuplicate(
            sourceQuiz,
            options ?? const DuplicationOptions(),
          );
          
          // Save to repository
          final saveResult = await _quizRepository.createQuiz(duplicatedQuiz);
          
          return saveResult.fold(
            (failure) => Left(failure),
            (newQuizId) async {
              // Track duplication
              await _trackDuplication(sourceQuizId, newQuizId);
              
              // Copy resources if needed
              if (options?.includeImages ?? true) {
                await _duplicateImages(sourceQuiz, newQuizId);
              }
              
              return Right(newQuizId);
            },
          );
        },
      );
    } catch (e) {
      return Left(QuizFailure.unknown(e.toString()));
    }
  }
  
  Future<Quiz> _createDuplicate(
    Quiz source,
    DuplicationOptions options,
  ) async {
    final currentUser = await _authRepository.getCurrentUser();
    final timestamp = DateTime.now();
    
    // Generate new title
    final newTitle = options.customTitle ?? 
      _generateDuplicateTitle(source.title, options);
    
    // Create new quiz with copied data
    return Quiz(
      id: null, // Will be generated
      title: newTitle,
      description: options.includeDescription 
          ? source.description 
          : '',
      category: options.overrideCategory ?? source.category,
      createdBy: currentUser!.uid,
      createdAt: timestamp,
      updatedAt: timestamp,
      isPublished: false, // Always start as draft
      isDraft: true,
      questions: await _duplicateQuestions(
        source.questions,
        options,
      ),
      metadata: _duplicateMetadata(source.metadata, options),
      settings: options.includeSettings 
          ? source.settings 
          : QuizSettings.defaults(),
      // Reset statistics
      playCount: 0,
      totalRatings: 0,
      averageRating: 0,
      // Attribution
      duplicatedFrom: options.includeAttribution 
          ? source.id 
          : null,
    );
  }
  
  Future<List<Question>> _duplicateQuestions(
    List<Question> sourceQuestions,
    DuplicationOptions options,
  ) async {
    final duplicatedQuestions = <Question>[];
    
    for (var i = 0; i < sourceQuestions.length; i++) {
      final sourceQuestion = sourceQuestions[i];
      
      // Skip if filtering by index
      if (options.questionIndices != null && 
          !options.questionIndices!.contains(i)) {
        continue;
      }
      
      final duplicatedQuestion = sourceQuestion.map(
        multipleChoice: (mc) => MultipleChoiceQuestion(
          id: const Uuid().v4(),
          text: _processText(mc.text, options),
          choices: mc.choices,
          correctAnswerIndex: mc.correctAnswerIndex,
          imageUrl: options.includeImages ? mc.imageUrl : null,
          explanation: options.includeExplanations 
              ? mc.explanation 
              : null,
          timeLimit: mc.timeLimit,
          points: mc.points,
        ),
        trueFalse: (tf) => TrueFalseQuestion(
          id: const Uuid().v4(),
          text: _processText(tf.text, options),
          correctAnswer: tf.correctAnswer,
          explanation: options.includeExplanations 
              ? tf.explanation 
              : null,
          timeLimit: tf.timeLimit,
          points: tf.points,
        ),
      );
      
      duplicatedQuestions.add(duplicatedQuestion);
    }
    
    return duplicatedQuestions;
  }
  
  String _generateDuplicateTitle(
    String originalTitle,
    DuplicationOptions options,
  ) {
    if (options.seriesMode != null) {
      switch (options.seriesMode!) {
        case SeriesMode.numeric:
          final match = RegExp(r'(.+?)\s*(\d+)$').firstMatch(originalTitle);
          if (match != null) {
            final base = match.group(1)!;
            final number = int.parse(match.group(2)!);
            return '$base ${number + 1}';
          }
          return '$originalTitle 2';
          
        case SeriesMode.alphabetic:
          final match = RegExp(r'(.+?)\s*([A-Z])$').firstMatch(originalTitle);
          if (match != null) {
            final base = match.group(1)!;
            final letter = match.group(2)!;
            final nextLetter = String.fromCharCode(
              letter.codeUnitAt(0) + 1,
            );
            return '$base $nextLetter';
          }
          return '$originalTitle B';
          
        case SeriesMode.version:
          return '$originalTitle v2';
      }
    }
    
    // Default: add (Copy) suffix
    return '$originalTitle (Copy)';
  }
}
```

### 2. Duplication UI Components
```dart
// lib/features/quiz_creation/presentation/widgets/duplicate_quiz_dialog.dart

class DuplicateQuizDialog extends ConsumerStatefulWidget {
  final Quiz quiz;
  
  @override
  _DuplicateQuizDialogState createState() => _DuplicateQuizDialogState();
}

class _DuplicateQuizDialogState extends ConsumerState<DuplicateQuizDialog> {
  final _titleController = TextEditingController();
  bool _includeImages = true;
  bool _includeSettings = true;
  bool _includeDescription = true;
  bool _includeExplanations = true;
  SeriesMode? _seriesMode;
  int _numberOfCopies = 1;
  
  @override
  void initState() {
    super.initState();
    _titleController.text = '${widget.quiz.title} (Copy)';
  }
  
  @override
  Widget build(BuildContext context) {
    final hasImages = widget.quiz.questions.any((q) => q.imageUrl != null);
    
    return AlertDialog(
      title: const Text('Duplicate Quiz'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview card
            Card(
              child: ListTile(
                leading: const Icon(Icons.quiz),
                title: Text(widget.quiz.title),
                subtitle: Text(
                  '${widget.quiz.questions.length} questions',
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // New title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'New Quiz Title',
                hintText: 'Enter title for the duplicate',
              ),
              maxLength: 100,
            ),
            
            const SizedBox(height: 16),
            
            // Series creation
            Text(
              'Series Creation',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<SeriesMode?>(
                    value: _seriesMode,
                    decoration: const InputDecoration(
                      labelText: 'Series Mode',
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('Single Copy'),
                      ),
                      DropdownMenuItem(
                        value: SeriesMode.numeric,
                        child: Text('Numbered (1, 2, 3...)'),
                      ),
                      DropdownMenuItem(
                        value: SeriesMode.alphabetic,
                        child: Text('Lettered (A, B, C...)'),
                      ),
                      DropdownMenuItem(
                        value: SeriesMode.version,
                        child: Text('Versions (v1, v2...)'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _seriesMode = value);
                    },
                  ),
                ),
                if (_seriesMode != null) ...[
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: SpinBox(
                      min: 1,
                      max: 10,
                      value: _numberOfCopies.toDouble(),
                      decoration: const InputDecoration(
                        labelText: 'Copies',
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setState(() => _numberOfCopies = value.toInt());
                      },
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Options
            Text(
              'Duplication Options',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            
            SwitchListTile(
              title: const Text('Include Description'),
              value: _includeDescription,
              onChanged: (value) {
                setState(() => _includeDescription = value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            if (hasImages)
              SwitchListTile(
                title: const Text('Include Images'),
                subtitle: const Text('This will duplicate image files'),
                value: _includeImages,
                onChanged: (value) {
                  setState(() => _includeImages = value);
                },
                contentPadding: EdgeInsets.zero,
              ),
            
            SwitchListTile(
              title: const Text('Include Answer Explanations'),
              value: _includeExplanations,
              onChanged: (value) {
                setState(() => _includeExplanations = value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            SwitchListTile(
              title: const Text('Include Quiz Settings'),
              subtitle: const Text('Time limits, points, etc.'),
              value: _includeSettings,
              onChanged: (value) {
                setState(() => _includeSettings = value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            // Storage estimate
            if (hasImages && _includeImages)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Estimated storage: ${_calculateStorageEstimate()}',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
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
          onPressed: _titleController.text.trim().isEmpty 
              ? null 
              : _performDuplication,
          child: Text(
            _seriesMode != null 
                ? 'Create $_numberOfCopies Copies'
                : 'Duplicate',
          ),
        ),
      ],
    );
  }
  
  Future<void> _performDuplication() async {
    final options = DuplicationOptions(
      customTitle: _seriesMode == null 
          ? _titleController.text.trim() 
          : null,
      includeImages: _includeImages,
      includeSettings: _includeSettings,
      includeDescription: _includeDescription,
      includeExplanations: _includeExplanations,
      seriesMode: _seriesMode,
      includeAttribution: widget.quiz.isPublished,
    );
    
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DuplicationProgressDialog(
        quiz: widget.quiz,
        options: options,
        numberOfCopies: _numberOfCopies,
      ),
    );
  }
}
```

### 3. Quiz Actions Menu
```dart
// lib/features/quiz/presentation/widgets/quiz_actions_menu.dart

class QuizActionsMenu extends ConsumerWidget {
  final Quiz quiz;
  final bool showDuplicate;
  final bool showDelete;
  final bool showShare;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = currentUser?.uid == quiz.createdBy;
    
    return PopupMenuButton<QuizAction>(
      itemBuilder: (context) => [
        if (showDuplicate || isOwner)
          PopupMenuItem(
            value: QuizAction.duplicate,
            child: const ListTile(
              leading: Icon(Icons.copy),
              title: Text('Duplicate'),
              subtitle: Text('Create a copy'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        
        if (isOwner)
          PopupMenuItem(
            value: QuizAction.edit,
            child: const ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        
        if (showShare)
          PopupMenuItem(
            value: QuizAction.share,
            child: const ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        
        if (quiz.isPublished)
          PopupMenuItem(
            value: QuizAction.report,
            child: const ListTile(
              leading: Icon(Icons.flag),
              title: Text('Report'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        
        if (showDelete && isOwner)
          const PopupMenuDivider(),
        
        if (showDelete && isOwner)
          PopupMenuItem(
            value: QuizAction.delete,
            child: ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              textColor: Colors.red,
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
      onSelected: (action) => _handleAction(context, ref, action),
    );
  }
  
  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    QuizAction action,
  ) {
    switch (action) {
      case QuizAction.duplicate:
        showDialog(
          context: context,
          builder: (_) => DuplicateQuizDialog(quiz: quiz),
        );
        break;
        
      case QuizAction.edit:
        context.go('/quiz/${quiz.id}/edit');
        break;
        
      case QuizAction.share:
        _shareQuiz(context, quiz);
        break;
        
      case QuizAction.report:
        _reportQuiz(context, quiz);
        break;
        
      case QuizAction.delete:
        _confirmDelete(context, ref, quiz);
        break;
    }
  }
}
```

### 4. Image Duplication Service
```dart
// lib/features/quiz_creation/data/services/image_duplication_service.dart

@injectable
class ImageDuplicationService {
  final FirebaseStorage _storage;
  
  Future<Map<String, String>> duplicateQuizImages({
    required Quiz sourceQuiz,
    required String newQuizId,
  }) async {
    final imageMap = <String, String>{};
    
    for (final question in sourceQuiz.questions) {
      if (question.imageUrl != null) {
        try {
          final newUrl = await _duplicateImage(
            sourceUrl: question.imageUrl!,
            sourceQuizId: sourceQuiz.id!,
            targetQuizId: newQuizId,
            questionId: question.id,
          );
          
          imageMap[question.imageUrl!] = newUrl;
        } catch (e) {
          // Log error but continue with other images
          print('Failed to duplicate image: $e');
        }
      }
    }
    
    return imageMap;
  }
  
  Future<String> _duplicateImage({
    required String sourceUrl,
    required String sourceQuizId,
    required String targetQuizId,
    required String questionId,
  }) async {
    // Download source image
    final sourceRef = _storage.refFromURL(sourceUrl);
    final bytes = await sourceRef.getData();
    
    if (bytes == null) {
      throw Exception('Failed to download source image');
    }
    
    // Upload to new location
    final targetPath = 'quizzes/$targetQuizId/questions/$questionId/image.jpg';
    final targetRef = _storage.ref(targetPath);
    
    final uploadTask = targetRef.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'duplicatedFrom': sourceQuizId,
          'duplicatedAt': DateTime.now().toIso8601String(),
        },
      ),
    );
    
    await uploadTask;
    return await targetRef.getDownloadURL();
  }
}
```

### 5. Duplication Tracking
```dart
// lib/features/analytics/domain/models/duplication_analytics.dart

@freezed
class DuplicationAnalytics with _$DuplicationAnalytics {
  const factory DuplicationAnalytics({
    required String quizId,
    required int totalDuplications,
    required List<DuplicationRecord> records,
    required Map<String, int> duplicatesByUser,
    required DateTime? lastDuplicatedAt,
  }) = _DuplicationAnalytics;
}

@freezed
class DuplicationRecord with _$DuplicationRecord {
  const factory DuplicationRecord({
    required String duplicateId,
    required String duplicatedBy,
    required DateTime duplicatedAt,
    required DuplicationOptions options,
  }) = _DuplicationRecord;
}

// Track in Firestore
class DuplicationTracker {
  Future<void> trackDuplication({
    required String sourceQuizId,
    required String duplicateId,
    required String userId,
    required DuplicationOptions options,
  }) async {
    final batch = FirebaseFirestore.instance.batch();
    
    // Update source quiz stats
    final sourceRef = FirebaseFirestore.instance
        .collection('quizzes')
        .doc(sourceQuizId);
    
    batch.update(sourceRef, {
      'stats.duplications': FieldValue.increment(1),
      'stats.lastDuplicatedAt': FieldValue.serverTimestamp(),
    });
    
    // Add duplication record
    final recordRef = sourceRef
        .collection('duplications')
        .doc();
    
    batch.set(recordRef, {
      'duplicateId': duplicateId,
      'duplicatedBy': userId,
      'duplicatedAt': FieldValue.serverTimestamp(),
      'options': options.toJson(),
    });
    
    await batch.commit();
  }
}
```

## Duplication Rules

### Permission Rules
- Own quizzes: Always allowed
- Public quizzes: Allowed with attribution
- Private quizzes: Not allowed
- Shared quizzes: Based on permissions

### Resource Handling
- Images: Copied to new storage location
- Statistics: Reset to zero
- Ratings: Not copied
- Comments: Not copied
- Play history: Not copied

### Attribution
- Original quiz ID stored
- "Duplicated from" link shown
- Original creator credited
- Duplication count tracked

## Testing Requirements

### Unit Tests
- [ ] Duplication logic
- [ ] Title generation
- [ ] Permission checks
- [ ] Options handling

### Integration Tests
- [ ] Full duplication flow
- [ ] Image copying
- [ ] Series creation
- [ ] Attribution tracking

### E2E Tests
- [ ] Duplicate from list
- [ ] Duplicate with options
- [ ] Create series
- [ ] Verify independence
- [ ] Check attribution

## Performance Considerations
- Async image copying
- Batch operations for series
- Progress indication for large quizzes
- Background processing option

## Related Issues
- Depends on: US-006 (Create quiz)
- Related: US-014 (Edit quiz)
- Related: Content management
- Enhances: Productivity

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Duplication service complete
- [ ] UI components working
- [ ] Image copying functional
- [ ] Attribution system ready
- [ ] Unit tests passing (>85% coverage)
- [ ] Integration tests passing
- [ ] Manual testing completed
- [ ] Performance verified
- [ ] Documentation updated