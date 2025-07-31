# US-006: Create Quiz with Multiple Choice Questions

## User Story
As a quiz host, I want to create a new quiz with multiple-choice questions so that I can test participants on specific topics.

## User Journey Map
```
Quiz Creator Journey:
1. Signs in → Dashboard
2. Clicks "Create Quiz" → Quiz builder
3. Adds title, description, category
4. Creates questions with choices
5. Sets time limits and points
6. Previews quiz → Saves
7. Hosts game → Monitors players
8. Reviews results → Updates quiz if needed
```

## Acceptance Criteria
- [ ] Authenticated users can access quiz creation from dashboard
- [ ] 3-step wizard flow (Metadata → Questions → Settings)
- [ ] Quiz title required (3-100 characters)
- [ ] Quiz description optional (up to 300 characters)
- [ ] Minimum 1 question, maximum 50 questions
- [ ] Each question supports 2-6 answer choices
- [ ] One correct answer must be selected
- [ ] Auto-save drafts every 30 seconds
- [ ] Preview mode shows quiz as players will see it
- [ ] Validation prevents empty questions/answers
- [ ] Success confirmation with sharing options
- [ ] Works on mobile, tablet, and desktop layouts

## Navigation Flow

### Current State
```
/quiz-creation exists with 3-step wizard
Quiz models and domain layer 90% complete
Firebase integration 20% complete
Auto-save and preview not implemented
```

### Required Implementation
```
1. Quiz Creation Entry:
   /home → "Create Quiz" → /quiz-creation
   /dashboard → "New Quiz" → /quiz-creation
   /my-quizzes → "+" button → /quiz-creation

2. Creation Wizard Flow:
   /quiz-creation (Step 1: Metadata)
   ├── Title, description, category
   ├── Validation in real-time
   ├── Auto-save to draft
   └── Next → Questions
   
   /quiz-creation/questions (Step 2: Questions)
   ├── Add question button
   ├── Question list with reorder
   ├── Edit/delete questions
   ├── Auto-save changes
   └── Next → Settings
   
   /quiz-creation/settings (Step 3: Settings)
   ├── Game settings (max players, shuffle)
   ├── Privacy (public/private)
   ├── Review all content
   └── Create Quiz → Success

3. Success Flow:
   /quiz-creation/success
   ├── Quiz created confirmation
   ├── Share quiz ID/link
   ├── "Host Now" → /game/host/{quizId}
   └── "View Quiz" → /quiz/{quizId}
```

## Technical Implementation

### 1. Complete Firebase Integration
```dart
// lib/features/quiz_creation/data/datasources/quiz_firestore_datasource.dart

@override
Future<Either<Failure, String>> createQuiz(QuizModel quiz) async {
  try {
    // Validate user is authenticated
    final user = _auth.currentUser;
    if (user == null) {
      return const Left(AuthFailure.unauthenticated());
    }
    
    // Create quiz document
    final docRef = _quizzesCollection.doc();
    final quizWithId = quiz.copyWith(
      id: docRef.id,
      createdBy: user.uid,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    );
    
    await docRef.set(quizWithId.toJson());
    
    // Update user's quiz list
    await _usersCollection.doc(user.uid).update({
      'createdQuizzes': FieldValue.arrayUnion([docRef.id]),
      'stats.quizzesCreated': FieldValue.increment(1),
    });
    
    return Right(docRef.id);
  } catch (e) {
    return Left(DatabaseFailure.fromException(e));
  }
}

@override
Future<Either<Failure, void>> saveDraft(QuizModel quiz) async {
  try {
    final user = _auth.currentUser;
    if (user == null) {
      return const Left(AuthFailure.unauthenticated());
    }
    
    // Save to drafts subcollection
    final draftRef = _usersCollection
        .doc(user.uid)
        .collection('drafts')
        .doc(quiz.id ?? 'new_quiz');
    
    await draftRef.set({
      ...quiz.toJson(),
      'lastSaved': FieldValue.serverTimestamp(),
    });
    
    return const Right(null);
  } catch (e) {
    return Left(DatabaseFailure.fromException(e));
  }
}
```

### 2. Implement Auto-Save Functionality
```dart
// lib/features/quiz_creation/presentation/providers/quiz_creation_provider.dart

class QuizCreationNotifier extends StateNotifier<QuizCreationState> {
  Timer? _autoSaveTimer;
  
  void startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (state.hasUnsavedChanges && state.quiz != null) {
        _saveDraft();
      }
    });
  }
  
  Future<void> _saveDraft() async {
    if (state.quiz == null) return;
    
    state = state.copyWith(isSaving: true);
    
    final result = await _repository.saveDraft(state.quiz!);
    
    result.fold(
      (failure) => state = state.copyWith(
        isSaving: false,
        saveError: failure.message,
      ),
      (_) => state = state.copyWith(
        isSaving: false,
        hasUnsavedChanges: false,
        lastSaved: DateTime.now(),
      ),
    );
  }
  
  void addQuestion(Question question) {
    final updatedQuestions = [...state.quiz!.questions, question];
    state = state.copyWith(
      quiz: state.quiz!.copyWith(questions: updatedQuestions),
      hasUnsavedChanges: true,
    );
  }
  
  void updateQuestion(int index, Question question) {
    final updatedQuestions = [...state.quiz!.questions];
    updatedQuestions[index] = question;
    
    state = state.copyWith(
      quiz: state.quiz!.copyWith(questions: updatedQuestions),
      hasUnsavedChanges: true,
    );
  }
  
  void reorderQuestions(int oldIndex, int newIndex) {
    final questions = [...state.quiz!.questions];
    final question = questions.removeAt(oldIndex);
    questions.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, question);
    
    state = state.copyWith(
      quiz: state.quiz!.copyWith(questions: questions),
      hasUnsavedChanges: true,
    );
  }
}
```

### 3. Update Question Builder UI
```dart
// lib/features/quiz_creation/presentation/widgets/question_builder.dart

class QuestionBuilder extends ConsumerWidget {
  final int questionIndex;
  final MultipleChoiceQuestion question;
  final VoidCallback onDelete;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Question header
            Row(
              children: [
                CircleAvatar(
                  child: Text('${questionIndex + 1}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: question.text,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      hintText: 'Enter your question',
                    ),
                    maxLength: 200,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Question is required';
                      }
                      return null;
                    },
                    onChanged: (value) => _updateQuestion(
                      ref,
                      question.copyWith(text: value),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Answer choices
            ...List.generate(question.choices.length, (index) {
              final choice = question.choices[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: question.correctAnswerIndex,
                      onChanged: (value) => _updateQuestion(
                        ref,
                        question.copyWith(correctAnswerIndex: value!),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: choice,
                        decoration: InputDecoration(
                          labelText: 'Choice ${index + 1}',
                          hintText: 'Enter answer choice',
                          suffixIcon: question.choices.length > 2
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () => _removeChoice(ref, index),
                                )
                              : null,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Choice cannot be empty';
                          }
                          return null;
                        },
                        onChanged: (value) => _updateChoice(ref, index, value),
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            if (question.choices.length < 6)
              TextButton.icon(
                onPressed: () => _addChoice(ref),
                icon: const Icon(Icons.add),
                label: const Text('Add Choice'),
              ),
            
            const Divider(),
            
            // Time and points settings
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: question.timeLimit,
                    decoration: const InputDecoration(
                      labelText: 'Time Limit',
                      suffixText: 'seconds',
                    ),
                    items: [5, 10, 20, 30, 60, 90, 120, 180, 240, 300]
                        .map((time) => DropdownMenuItem(
                              value: time,
                              child: Text('$time'),
                            ))
                        .toList(),
                    onChanged: (value) => _updateQuestion(
                      ref,
                      question.copyWith(timeLimit: value!),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: question.points,
                    decoration: const InputDecoration(
                      labelText: 'Points',
                    ),
                    items: [10, 20, 50, 100, 200, 500, 1000]
                        .map((points) => DropdownMenuItem(
                              value: points,
                              child: Text('$points'),
                            ))
                        .toList(),
                    onChanged: (value) => _updateQuestion(
                      ref,
                      question.copyWith(points: value!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. Implement Preview Mode
```dart
// lib/features/quiz_creation/presentation/pages/quiz_preview_page.dart

class QuizPreviewPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizCreationProvider);
    final quiz = quizState.quiz;
    
    if (quiz == null) {
      return const ErrorPage(message: 'No quiz to preview');
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Quiz'),
        actions: [
          TextButton(
            onPressed: () => context.go('/quiz-creation/settings'),
            child: const Text('Back to Edit'),
          ),
        ],
      ),
      body: QuizPlayerSimulator(
        quiz: quiz,
        onComplete: (results) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Preview Complete'),
              content: Text(
                'Score: ${results.score}/${results.totalPoints}\n'
                'Time: ${results.duration.inSeconds}s',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

### 5. Success Page Implementation
```dart
// lib/features/quiz_creation/presentation/pages/quiz_success_page.dart

class QuizSuccessPage extends ConsumerWidget {
  final String quizId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiz = ref.watch(quizProvider(quizId));
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                'Quiz Created Successfully!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                quiz.value?.title ?? 'Your Quiz',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              
              // Action buttons
              ElevatedButton.icon(
                onPressed: () => context.go('/game/host/$quizId'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Host Now'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _shareQuiz(context, quizId),
                icon: const Icon(Icons.share),
                label: const Text('Share Quiz'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/quiz/$quizId'),
                child: const Text('View Quiz Details'),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Validation Rules

### Quiz Metadata
- **Title**: 3-100 characters, no profanity
- **Description**: 0-300 characters
- **Category**: Must select from predefined list
- **Language**: Default to user's language

### Questions
- **Question text**: 5-200 characters
- **Answer choices**: 2-6 options, 1-100 characters each
- **Correct answer**: Must select exactly one
- **Time limit**: 5-300 seconds
- **Points**: 10-1000 points

### Quiz Rules
- Minimum 1 question
- Maximum 50 questions
- Total quiz time cannot exceed 60 minutes
- At least one question must be worth > 10 points

## Error Handling

```dart
enum QuizCreationError {
  insufficientQuestions('Add at least 1 question to continue'),
  invalidQuestion('All questions must have text and correct answer'),
  duplicateQuestion('Duplicate questions are not allowed'),
  saveFailed('Failed to save quiz. Please try again'),
  networkError('Check your internet connection'),
  quotaExceeded('You have reached your quiz limit');
  
  final String message;
  const QuizCreationError(this.message);
}
```

## Testing Requirements

### Unit Tests
- [ ] Quiz validation logic
- [ ] Question builder functionality
- [ ] Auto-save timer logic
- [ ] State management transitions

### Integration Tests
- [ ] Complete quiz creation flow
- [ ] Firebase save operations
- [ ] Draft recovery
- [ ] Preview mode functionality

### E2E Tests
- [ ] Create quiz from dashboard
- [ ] Add/edit/delete questions
- [ ] Reorder questions
- [ ] Preview and publish
- [ ] Share functionality

## Performance Considerations
- Debounce auto-save to prevent excessive writes
- Lazy load question components for large quizzes
- Optimize image uploads with compression
- Cache draft locally for offline editing

## Related Issues
- Depends on: US-001 (Authentication)
- Blocks: US-015 (Game hosting)
- Related: US-007 (Image upload)
- Related: US-011 (Draft functionality)

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Auto-save implemented (30s interval)
- [ ] Preview mode functional
- [ ] Firebase integration complete
- [ ] Responsive design verified
- [ ] Unit tests passing (>85% coverage)
- [ ] Integration tests passing
- [ ] Manual testing on all platforms
- [ ] Code reviewed and approved
- [ ] Documentation updated