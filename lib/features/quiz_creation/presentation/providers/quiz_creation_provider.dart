import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/question_entities.dart';
import '../../domain/usecases/create_quiz_usecase.dart';
import '../../../../shared/providers/firebase_providers.dart';
import 'quiz_providers.dart';

part 'quiz_creation_provider.freezed.dart';

/// Validation state for quiz creation
@freezed
class ValidationState with _$ValidationState {
  const ValidationState._();

  const factory ValidationState({
    @Default(false) bool isTitleValid,
    @Default(false) bool isDescriptionValid,
    @Default(false) bool hasQuestions,
    @Default('') String titleError,
    @Default('') String descriptionError,
    @Default('') String questionsError,
  }) = _ValidationState;

  /// Check if basic metadata is valid (for navigation)
  bool get isMetadataValid => isTitleValid && isDescriptionValid;

  /// Check if entire quiz is valid for saving
  bool get isQuizComplete => isMetadataValid && hasQuestions;

  /// Get the next required step message
  String get nextRequirement {
    if (!isTitleValid) return 'Add a quiz title (3+ characters)';
    if (!isDescriptionValid) return 'Add a description (10+ characters)';
    if (!hasQuestions) return 'Add at least 1 question';
    return 'Quiz is ready to save!';
  }
}

/// State for quiz creation workflow
@freezed
class QuizCreationState with _$QuizCreationState {
  const QuizCreationState._();

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
    String? editingQuizId, // Track the quiz ID when in edit mode
    @Default(0) int currentStep,
    @Default(ValidationState()) ValidationState validation,
  }) = _QuizCreationState;
}

/// Provider for managing quiz creation state
final quizCreationProvider =
    StateNotifierProvider<QuizCreationNotifier, QuizCreationState>((ref) {
      try {
        final createUseCase = ref.watch(createQuizUseCaseProvider);
        final currentUserId = ref.watch(currentUserIdProvider);
        return QuizCreationNotifier(
          createUseCase: createUseCase,
          currentUserId: currentUserId,
        );
      } catch (e) {
        // Fallback for any provider dependency issues
        return QuizCreationNotifier(
          createUseCase: ref.watch(createQuizUseCaseProvider),
          currentUserId: null, // Allow null user ID for development
        );
      }
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

  /// Update quiz metadata with validation
  void updateMetadata({
    String? title,
    String? description,
    String? category,
    String? imageUrl,
  }) {
    final newTitle = title ?? state.title;
    final newDescription = description ?? state.description;

    // Validate title
    final isTitleValid = newTitle.isNotEmpty && newTitle.length >= 3;
    final titleError = newTitle.isEmpty
        ? 'Title is required'
        : newTitle.length < 3
        ? 'Title must be at least 3 characters'
        : '';

    // Validate description
    final isDescriptionValid =
        newDescription.isNotEmpty && newDescription.length >= 10;
    final descriptionError = newDescription.isEmpty
        ? 'Description is required'
        : newDescription.length < 10
        ? 'Description must be at least 10 characters'
        : '';

    // Update validation state
    final newValidation = state.validation.copyWith(
      isTitleValid: isTitleValid,
      isDescriptionValid: isDescriptionValid,
      titleError: titleError,
      descriptionError: descriptionError,
    );

    state = state.copyWith(
      title: newTitle,
      description: newDescription,
      category: category ?? state.category,
      imageUrl: imageUrl ?? state.imageUrl,
      validation: newValidation,
      error: null, // Clear any previous errors
    );
  }

  /// Add a new question
  void addQuestion(Question question) {
    final newQuestions = [...state.questions, question];
    final hasQuestions = newQuestions.isNotEmpty;

    state = state.copyWith(
      questions: newQuestions,
      validation: state.validation.copyWith(
        hasQuestions: hasQuestions,
        questionsError: hasQuestions ? '' : 'At least one question is required',
      ),
    );
  }

  /// Update an existing question
  void updateQuestion(int index, Question question) {
    final updatedQuestions = List<Question>.from(state.questions);
    if (index >= 0 && index < updatedQuestions.length) {
      updatedQuestions[index] = question;
      final hasQuestions = updatedQuestions.isNotEmpty;

      state = state.copyWith(
        questions: updatedQuestions,
        validation: state.validation.copyWith(
          hasQuestions: hasQuestions,
          questionsError: hasQuestions
              ? ''
              : 'At least one question is required',
        ),
      );
    }
  }

  /// Remove a question
  void removeQuestion(int index) {
    final updatedQuestions = List<Question>.from(state.questions);
    if (index >= 0 && index < updatedQuestions.length) {
      updatedQuestions.removeAt(index);
      final hasQuestions = updatedQuestions.isNotEmpty;

      state = state.copyWith(
        questions: updatedQuestions,
        validation: state.validation.copyWith(
          hasQuestions: hasQuestions,
          questionsError: hasQuestions
              ? ''
              : 'At least one question is required',
        ),
      );
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

  /// Load existing quiz data for editing mode
  void loadExistingQuiz(Quiz quiz) {
    // Pre-populate all fields with existing quiz data
    final isTitleValid = quiz.title.isNotEmpty && quiz.title.length >= 3;
    final isDescriptionValid =
        quiz.description.isNotEmpty && quiz.description.length >= 10;
    final hasQuestions = quiz.questions.isNotEmpty;

    // Create validation state
    final validation = ValidationState(
      isTitleValid: isTitleValid,
      isDescriptionValid: isDescriptionValid,
      hasQuestions: hasQuestions,
      titleError: isTitleValid ? '' : 'Title must be at least 3 characters',
      descriptionError: isDescriptionValid
          ? ''
          : 'Description must be at least 10 characters',
      questionsError: hasQuestions ? '' : 'At least one question is required',
    );

    // Update state with existing quiz data
    state = state.copyWith(
      title: quiz.title,
      description: quiz.description,
      category: quiz.metadata.category,
      questions: quiz.questions,
      isPublic: quiz.isPublic,
      imageUrl: quiz.metadata.coverImageUrl,
      editingQuizId: quiz.id, // Store the quiz ID for editing
      validation: validation,
      error: null,
    );
  }

  /// Get current validation summary for UI display
  String getValidationSummary() {
    if (state.validation.isQuizComplete) {
      return 'Quiz is ready to save!';
    }
    return state.validation.nextRequirement;
  }

  /// Check if user can proceed to next step
  bool canProceedToStep(int targetStep) {
    switch (targetStep) {
      case 1: // Can go to questions if metadata is valid
        return state.validation.isMetadataValid;
      case 2: // Can go to settings if metadata is valid (questions optional)
        return state.validation.isMetadataValid;
      default:
        return true;
    }
  }

  /// Check if user can save quiz
  bool canSaveQuiz() {
    return state.validation.isQuizComplete;
  }

  /// Validate quiz before saving - now uses validation state
  bool validateQuiz() {
    // Force re-validation to ensure current state
    updateMetadata(title: state.title, description: state.description);

    // Check if quiz is complete
    if (!state.validation.isQuizComplete) {
      // Set a user-friendly error message
      final errorMessage = state.validation.nextRequirement;
      state = state.copyWith(error: errorMessage);
      return false;
    }

    state = state.copyWith(error: null);
    return true;
  }

  /// Save quiz with Firebase integration (supports both create and update)
  Future<String?> saveQuiz({String? existingQuizId}) async {
    if (!validateQuiz()) return null;

    // For development mode, use fallback user ID if null
    final userId =
        _currentUserId ?? 'dev_user_${DateTime.now().millisecondsSinceEpoch}';

    if (_currentUserId == null) {
      // Allow saving in development mode
      debugPrint(
        'Warning: Saving quiz without authenticated user (development mode)',
      );
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Create Quiz entity from current state
      final quiz = Quiz(
        id: existingQuizId ?? '', // Use existing ID for updates, empty for new
        title: state.title,
        description: state.description,
        createdBy: userId,
        questions: state.questions,
        isPublic: state.isPublic,
        createdAt: DateTime.now(), // Always set creation date
        updatedAt: DateTime.now(), // Always update the modified time
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
        success: (savedQuiz) {
          state = state.copyWith(isLoading: false, error: null);
          return savedQuiz.id;
        },
        failure: (failure) {
          state = state.copyWith(isLoading: false, error: failure.message);
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
