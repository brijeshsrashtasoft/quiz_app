import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/quiz_entity.dart';

part 'quiz_creation_provider.freezed.dart';

/// State for quiz creation workflow
@freezed
class QuizCreationState with _$QuizCreationState {
  const factory QuizCreationState({
    @Default('') String title,
    @Default('') String description,
    @Default('General Knowledge') String category,
    @Default([]) List<QuestionEntity> questions,
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
      return QuizCreationNotifier();
    });

/// Notifier for quiz creation state management
class QuizCreationNotifier extends StateNotifier<QuizCreationState> {
  QuizCreationNotifier() : super(const QuizCreationState());

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
  void addQuestion(QuestionEntity question) {
    state = state.copyWith(questions: [...state.questions, question]);
  }

  /// Update an existing question
  void updateQuestion(int index, QuestionEntity question) {
    final updatedQuestions = List<QuestionEntity>.from(state.questions);
    if (index >= 0 && index < updatedQuestions.length) {
      updatedQuestions[index] = question;
      state = state.copyWith(questions: updatedQuestions);
    }
  }

  /// Remove a question
  void removeQuestion(int index) {
    final updatedQuestions = List<QuestionEntity>.from(state.questions);
    if (index >= 0 && index < updatedQuestions.length) {
      updatedQuestions.removeAt(index);
      state = state.copyWith(questions: updatedQuestions);
    }
  }

  /// Reorder questions
  void reorderQuestions(int oldIndex, int newIndex) {
    final updatedQuestions = List<QuestionEntity>.from(state.questions);
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

  /// Save quiz (to be implemented with Firebase)
  Future<void> saveQuiz() async {
    if (!validateQuiz()) return;

    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implement Firebase save logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate save
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save quiz: $e',
      );
    }
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
