import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/question_entities.dart';
import '../../domain/usecases/create_quiz_usecase.dart';
import '../../../../shared/providers/firebase_providers.dart';
import 'quiz_providers.dart';

part 'quiz_creation_provider.freezed.dart';

/// State for quiz creation workflow
@freezed
class QuizCreationState with _$QuizCreationState {
  const factory QuizCreationState({
    @Default('') String title,
    @Default('') String description,
    @Default('General Knowledge') String category,
    @Default([]) List<Question> questions,
    @Default(true) bool isPublic,
    @Default(true) bool enableLeaderboard,
    @Default(false) bool randomizeQuestions,
    @Default(false) bool isLoading,
    String? error,
    String? imageUrl,
    @Default(0) int currentStep,
  }) = _QuizCreationState;
}

/// Provider for managing quiz creation state
final quizCreationProvider =
    StateNotifierProvider<QuizCreationNotifier, QuizCreationState>((ref) {
      final createUseCase = ref.watch(createQuizUseCaseProvider);
      final currentUserId = ref.watch(currentUserIdProvider);
      return QuizCreationNotifier(
        createUseCase: createUseCase,
        currentUserId: currentUserId,
      );
    });

/// Notifier for quiz creation state management
class QuizCreationNotifier extends StateNotifier<QuizCreationState> {
  final CreateQuizUseCase _createUseCase;
  final String? _currentUserId;

  QuizCreationNotifier({
    required CreateQuizUseCase createUseCase,
    required String? currentUserId,
  }) : _createUseCase = createUseCase,
       _currentUserId = currentUserId,
       super(const QuizCreationState());

  /// Update quiz metadata
  void updateMetadata({
    String? title,
    String? description,
    String? category,
    String? imageUrl,
  }) {
    state = state.copyWith(
      title: title ?? state.title,
      description: description ?? state.description,
      category: category ?? state.category,
      imageUrl: imageUrl ?? state.imageUrl,
    );
  }

  /// Add a new question
  void addQuestion(Question question) {
    state = state.copyWith(questions: [...state.questions, question]);
  }

  /// Update an existing question
  void updateQuestion(int index, Question question) {
    final updatedQuestions = List<Question>.from(state.questions);
    if (index >= 0 && index < updatedQuestions.length) {
      updatedQuestions[index] = question;
      state = state.copyWith(questions: updatedQuestions);
    }
  }

  /// Remove a question
  void removeQuestion(int index) {
    final updatedQuestions = List<Question>.from(state.questions);
    if (index >= 0 && index < updatedQuestions.length) {
      updatedQuestions.removeAt(index);
      state = state.copyWith(questions: updatedQuestions);
    }
  }

  /// Reorder questions
  void reorderQuestions(int oldIndex, int newIndex) {
    final updatedQuestions = List<Question>.from(state.questions);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = updatedQuestions.removeAt(oldIndex);
    updatedQuestions.insert(newIndex, item);
    state = state.copyWith(questions: updatedQuestions);
  }

  /// Update quiz settings
  void updateSettings({
    bool? isPublic,
    bool? enableLeaderboard,
    bool? randomizeQuestions,
  }) {
    state = state.copyWith(
      isPublic: isPublic ?? state.isPublic,
      enableLeaderboard: enableLeaderboard ?? state.enableLeaderboard,
      randomizeQuestions: randomizeQuestions ?? state.randomizeQuestions,
    );
  }

  /// Update current step
  void setCurrentStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  /// Reset quiz creation state
  void reset() {
    state = const QuizCreationState();
  }

  /// Validate quiz before saving
  bool validateQuiz() {
    if (state.title.isEmpty || state.title.length < 3) {
      state = state.copyWith(error: 'Quiz title must be at least 3 characters');
      return false;
    }
    if (state.description.isEmpty || state.description.length < 10) {
      state = state.copyWith(
        error: 'Quiz description must be at least 10 characters',
      );
      return false;
    }
    if (state.questions.isEmpty) {
      state = state.copyWith(error: 'Quiz must have at least one question');
      return false;
    }
    state = state.copyWith(error: null);
    return true;
  }

  /// Save quiz with Firebase integration
  Future<String?> saveQuiz() async {
    if (!validateQuiz()) return null;
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User must be authenticated to save quiz');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Create Quiz entity from current state
      final quiz = Quiz(
        id: '', // Will be set by Firestore
        title: state.title,
        description: state.description,
        createdBy: _currentUserId ?? '',
        questions: state.questions,
        isPublic: state.isPublic,
        createdAt: DateTime.now(),
        metadata: QuizMetadata(
          category: state.category,
          tags: [state.category], // Default to category as tag
          difficulty: 'medium', // Default difficulty
          language: 'en', // Default language
          coverImageUrl: state.imageUrl,
          estimatedDuration: _calculateEstimatedDuration(),
        ),
        isDraft: true, // Always save as draft initially
      );

      final result = await _createUseCase(CreateQuizParams(quiz: quiz));

      return result.when(
        success: (createdQuiz) {
          state = state.copyWith(
            isLoading: false,
            error: null,
          );
          return createdQuiz.id;
        },
        failure: (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return null;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save quiz: $e',
      );
      return null;
    }
  }

  /// Calculate estimated duration based on questions
  int _calculateEstimatedDuration() {
    if (state.questions.isEmpty) return 5; // Default 5 minutes
    
    final totalSeconds = state.questions.fold<int>(
      0,
      (sum, question) => sum + question.questionTimeLimit,
    );
    
    // Add buffer time (30% extra) and convert to minutes
    final totalMinutes = ((totalSeconds * 1.3) / 60).ceil();
    return totalMinutes.clamp(1, 180); // Between 1 and 180 minutes
  }
}

/// Provider for draft quiz (auto-save functionality)
final draftQuizProvider = StateProvider<QuizCreationState?>((ref) => null);

/// Provider to check if quiz has unsaved changes
final hasUnsavedChangesProvider = Provider<bool>((ref) {
  final currentState = ref.watch(quizCreationProvider);
  final draftState = ref.watch(draftQuizProvider);

  if (draftState == null) return false;

  return currentState != draftState;
});
