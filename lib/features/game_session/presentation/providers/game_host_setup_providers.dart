import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/game_session_entity.dart';
import '../../../quiz_creation/domain/entities/quiz.dart';

/// Game host setup configuration state
class GameHostSetupConfiguration {
  final Quiz? selectedQuiz;
  final int maxPlayers;
  final int questionTimeLimit;
  final bool showCorrectAnswers;
  final bool shuffleQuestions;
  final bool allowReplay;
  final bool isPublicRoom;

  const GameHostSetupConfiguration({
    this.selectedQuiz,
    this.maxPlayers = 50,
    this.questionTimeLimit = 20,
    this.showCorrectAnswers = true,
    this.shuffleQuestions = false,
    this.allowReplay = true,
    this.isPublicRoom = true,
  });

  GameHostSetupConfiguration copyWith({
    Quiz? selectedQuiz,
    int? maxPlayers,
    int? questionTimeLimit,
    bool? showCorrectAnswers,
    bool? shuffleQuestions,
    bool? allowReplay,
    bool? isPublicRoom,
  }) {
    return GameHostSetupConfiguration(
      selectedQuiz: selectedQuiz ?? this.selectedQuiz,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      questionTimeLimit: questionTimeLimit ?? this.questionTimeLimit,
      showCorrectAnswers: showCorrectAnswers ?? this.showCorrectAnswers,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      allowReplay: allowReplay ?? this.allowReplay,
      isPublicRoom: isPublicRoom ?? this.isPublicRoom,
    );
  }

  /// Convert configuration to GameSessionSettings entity
  GameSessionSettings toGameSessionSettings() {
    return GameSessionSettings(
      maxPlayers: maxPlayers,
      showCorrectAnswers: showCorrectAnswers,
      shuffleQuestions: shuffleQuestions,
      allowReplay: allowReplay,
    );
  }

  /// Check if configuration is valid for hosting
  bool get isValidForHosting {
    return selectedQuiz != null &&
        selectedQuiz!.questions.isNotEmpty &&
        maxPlayers >= 2 &&
        maxPlayers <= 100 &&
        questionTimeLimit >= 5 &&
        questionTimeLimit <= 60;
  }

  /// Get configuration summary for display
  String get summaryText {
    if (selectedQuiz == null) return 'No quiz selected';
    
    return '${selectedQuiz!.title} • $maxPlayers players • ${questionTimeLimit}s per question';
  }

  @override
  String toString() {
    return 'GameHostSetupConfiguration('
        'selectedQuiz: ${selectedQuiz?.title}, '
        'maxPlayers: $maxPlayers, '
        'questionTimeLimit: $questionTimeLimit, '
        'showCorrectAnswers: $showCorrectAnswers, '
        'shuffleQuestions: $shuffleQuestions, '
        'allowReplay: $allowReplay, '
        'isPublicRoom: $isPublicRoom)';
  }
}

/// Game host setup state notifier
class GameHostSetupNotifier extends StateNotifier<GameHostSetupConfiguration> {
  GameHostSetupNotifier() : super(const GameHostSetupConfiguration()) {
    AppLogger.info('GameHostSetupNotifier initialized with default configuration');
  }

  /// Update selected quiz
  void updateSelectedQuiz(Quiz? quiz) {
    AppLogger.info('Updating selected quiz: ${quiz?.title}');
    state = state.copyWith(selectedQuiz: quiz);
  }

  /// Update maximum players
  void updateMaxPlayers(int maxPlayers) {
    if (maxPlayers < 2 || maxPlayers > 100) {
      AppLogger.warning('Invalid max players value: $maxPlayers. Must be between 2-100');
      return;
    }
    
    AppLogger.info('Updating max players: $maxPlayers');
    state = state.copyWith(maxPlayers: maxPlayers);
  }

  /// Update question time limit
  void updateQuestionTimeLimit(int timeLimit) {
    if (timeLimit < 5 || timeLimit > 60) {
      AppLogger.warning('Invalid time limit value: $timeLimit. Must be between 5-60 seconds');
      return;
    }
    
    AppLogger.info('Updating question time limit: $timeLimit');
    state = state.copyWith(questionTimeLimit: timeLimit);
  }

  /// Update show correct answers setting
  void updateShowCorrectAnswers(bool show) {
    AppLogger.info('Updating show correct answers: $show');
    state = state.copyWith(showCorrectAnswers: show);
  }

  /// Update shuffle questions setting
  void updateShuffleQuestions(bool shuffle) {
    AppLogger.info('Updating shuffle questions: $shuffle');
    state = state.copyWith(shuffleQuestions: shuffle);
  }

  /// Update allow replay setting
  void updateAllowReplay(bool allow) {
    AppLogger.info('Updating allow replay: $allow');
    state = state.copyWith(allowReplay: allow);
  }

  /// Update room type (public/private)
  void updateIsPublicRoom(bool isPublic) {
    AppLogger.info('Updating room type: ${isPublic ? "Public" : "Private"}');
    state = state.copyWith(isPublicRoom: isPublic);
  }

  /// Reset configuration to defaults
  void resetConfiguration() {
    AppLogger.info('Resetting game host setup configuration to defaults');
    state = const GameHostSetupConfiguration();
  }

  /// Load configuration from quiz ID
  void loadConfigurationFromQuiz(Quiz quiz) {
    AppLogger.info('Loading configuration from quiz: ${quiz.title}');
    
    // Calculate optimal question time limit based on quiz complexity
    int optimalTimeLimit = 20; // default
    if (quiz.questions.isNotEmpty) {
      final avgQuestionLength = quiz.questions
          .map((q) => q.questionText.length)
          .reduce((a, b) => a + b) / quiz.questions.length;
      
      if (avgQuestionLength > 100) {
        optimalTimeLimit = 30; // Longer questions need more time
      } else if (avgQuestionLength < 50) {
        optimalTimeLimit = 15; // Shorter questions need less time
      }
    }

    // Calculate optimal max players based on quiz difficulty
    int optimalMaxPlayers = 50; // default
    if (quiz.questions.isNotEmpty) {
      final hasComplexQuestions = quiz.questions
          .any((q) => q.options.length > 4 || q.questionText.length > 150);
      
      if (hasComplexQuestions) {
        optimalMaxPlayers = 30; // Fewer players for complex quizzes
      }
    }

    state = state.copyWith(
      selectedQuiz: quiz,
      questionTimeLimit: optimalTimeLimit,
      maxPlayers: optimalMaxPlayers,
    );
  }

  /// Apply bulk configuration updates
  void updateConfiguration({
    Quiz? selectedQuiz,
    int? maxPlayers,
    int? questionTimeLimit,
    bool? showCorrectAnswers,
    bool? shuffleQuestions,
    bool? allowReplay,
    bool? isPublicRoom,
  }) {
    AppLogger.info('Applying bulk configuration updates');
    
    state = state.copyWith(
      selectedQuiz: selectedQuiz,
      maxPlayers: maxPlayers,
      questionTimeLimit: questionTimeLimit,
      showCorrectAnswers: showCorrectAnswers,
      shuffleQuestions: shuffleQuestions,
      allowReplay: allowReplay,
      isPublicRoom: isPublicRoom,
    );
  }
}

/// Provider for game host setup configuration
final gameHostSetupProvider = StateNotifierProvider<GameHostSetupNotifier, GameHostSetupConfiguration>(
  (ref) => GameHostSetupNotifier(),
);

/// Provider for checking if current configuration is valid
final isHostSetupValidProvider = Provider<bool>((ref) {
  final configuration = ref.watch(gameHostSetupProvider);
  return configuration.isValidForHosting;
});

/// Provider for getting configuration summary text
final hostSetupSummaryProvider = Provider<String>((ref) {
  final configuration = ref.watch(gameHostSetupProvider);
  return configuration.summaryText;
});

/// Provider for getting optimal player count based on selected quiz
final optimalPlayerCountProvider = Provider<int>((ref) {
  final configuration = ref.watch(gameHostSetupProvider);
  
  if (configuration.selectedQuiz == null) {
    return 50; // Default
  }

  final quiz = configuration.selectedQuiz!;
  
  // Calculate optimal based on quiz characteristics
  if (quiz.questions.isEmpty) return 50;
  
  final avgQuestionComplexity = quiz.questions
      .map((q) => q.options.length + (q.questionText.length / 50).round())
      .reduce((a, b) => a + b) / quiz.questions.length;
  
  if (avgQuestionComplexity > 8) {
    return 20; // Complex quizzes work better with fewer players
  } else if (avgQuestionComplexity > 6) {
    return 30;
  } else {
    return 50; // Simple quizzes can handle more players
  }
});

/// Provider for getting optimal time limit based on selected quiz
final optimalTimeLimitProvider = Provider<int>((ref) {
  final configuration = ref.watch(gameHostSetupProvider);
  
  if (configuration.selectedQuiz == null) {
    return 20; // Default
  }

  final quiz = configuration.selectedQuiz!;
  
  if (quiz.questions.isEmpty) return 20;
  
  final avgQuestionLength = quiz.questions
      .map((q) => q.questionText.length)
      .reduce((a, b) => a + b) / quiz.questions.length;
  
  if (avgQuestionLength > 150) {
    return 35; // Long questions need more time
  } else if (avgQuestionLength > 100) {
    return 25;
  } else if (avgQuestionLength > 50) {
    return 20;
  } else {
    return 15; // Short questions can be answered quickly
  }
});

/// Provider for configuration validation errors
final hostSetupValidationErrorsProvider = Provider<List<String>>((ref) {
  final configuration = ref.watch(gameHostSetupProvider);
  final errors = <String>[];

  if (configuration.selectedQuiz == null) {
    errors.add('Please select a quiz to host');
  } else if (configuration.selectedQuiz!.questions.isEmpty) {
    errors.add('Selected quiz must have at least one question');
  } else if (configuration.selectedQuiz!.questions.length < 3) {
    errors.add('Quiz should have at least 3 questions for better gameplay');
  }

  if (configuration.maxPlayers < 2) {
    errors.add('Minimum 2 players required');
  } else if (configuration.maxPlayers > 100) {
    errors.add('Maximum 100 players allowed');
  }

  if (configuration.questionTimeLimit < 5) {
    errors.add('Question time limit must be at least 5 seconds');
  } else if (configuration.questionTimeLimit > 60) {
    errors.add('Question time limit cannot exceed 60 seconds');
  }

  return errors;
});