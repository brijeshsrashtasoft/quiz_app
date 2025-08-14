import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/quiz_firestore_datasource.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/usecases/create_quiz_usecase.dart';
import '../../domain/usecases/update_quiz_usecase.dart';
import '../../domain/usecases/validate_quiz_usecase.dart';
import '../../domain/usecases/get_quiz_by_id_usecase.dart';
import '../../domain/usecases/get_public_quizzes_usecase.dart';
import '../../domain/usecases/get_popular_quizzes_usecase.dart';
import '../../domain/usecases/get_recent_quizzes_usecase.dart';
import '../../domain/usecases/get_user_quizzes_usecase.dart';
import '../../domain/usecases/publish_quiz_usecase.dart';
import '../../domain/entities/quiz.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

/// Quiz feature dependency injection providers
/// Following CLAUDE.md Clean Architecture and Riverpod patterns

/// Data source provider
final quizDataSourceProvider = Provider<QuizFirestoreDataSource>((ref) {
  return QuizFirestoreDataSource();
});

/// Repository provider
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final dataSource = ref.watch(quizDataSourceProvider);
  return QuizRepositoryImpl(dataSource: dataSource);
});

/// Use case providers
final createQuizUseCaseProvider = Provider<CreateQuizUseCase>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return CreateQuizUseCase(repository);
});

final updateQuizUseCaseProvider = Provider<UpdateQuizUseCase>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return UpdateQuizUseCase(repository);
});

final validateQuizUseCaseProvider = Provider<ValidateQuizUseCase>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return ValidateQuizUseCase(repository);
});

final getQuizByIdUseCaseProvider = Provider<GetQuizByIdUseCase>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return GetQuizByIdUseCase(repository);
});

final getPublicQuizzesUseCaseProvider = Provider<GetPublicQuizzesUseCase>((
  ref,
) {
  final repository = ref.watch(quizRepositoryProvider);
  return GetPublicQuizzesUseCase(repository);
});

final getPopularQuizzesUseCaseProvider = Provider<GetPopularQuizzesUseCase>((
  ref,
) {
  final repository = ref.watch(quizRepositoryProvider);
  return GetPopularQuizzesUseCase(repository);
});

final getRecentQuizzesUseCaseProvider = Provider<GetRecentQuizzesUseCase>((
  ref,
) {
  final repository = ref.watch(quizRepositoryProvider);
  return GetRecentQuizzesUseCase(repository);
});

final getUserQuizzesUseCaseProvider = Provider<GetUserQuizzesUseCase>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return GetUserQuizzesUseCase(repository);
});

final publishQuizUseCaseProvider = Provider<PublishQuizUseCase>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return PublishQuizUseCase(repository);
});

/// Provider to fetch a quiz by ID for preview/editing
final quizByIdProvider = FutureProvider.family<Quiz?, String>((
  ref,
  quizId,
) async {
  if (quizId.isEmpty) return null;

  final useCase = ref.watch(getQuizByIdUseCaseProvider);
  final result = await useCase.call(GetQuizByIdParams(quizId: quizId));

  return result.when(
    success: (quiz) => quiz,
    failure: (error) {
      // Log error for debugging
      debugPrint('Failed to load quiz $quizId: ${error.message}');
      return null;
    },
  );
});

/// Provider to fetch public quizzes for home page display
final publicQuizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  debugPrint('Fetching public quizzes for home page');

  final useCase = ref.watch(getPublicQuizzesUseCaseProvider);
  final result = await useCase.call(GetPublicQuizzesParams(limit: 10));

  return result.when(
    success: (quizzes) {
      debugPrint('Successfully fetched ${quizzes.length} public quizzes');
      return quizzes;
    },
    failure: (error) {
      // Log error for debugging
      debugPrint('Failed to fetch public quizzes: ${error.message}');
      return [];
    },
  );
});

/// Provider to fetch popular quizzes for home page display
final popularQuizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  debugPrint('Fetching popular quizzes for home page');

  final useCase = ref.watch(getPopularQuizzesUseCaseProvider);
  final result = await useCase.call(GetPopularQuizzesParams(limit: 5));

  return result.when(
    success: (quizzes) {
      debugPrint('Successfully fetched ${quizzes.length} popular quizzes');
      return quizzes;
    },
    failure: (error) {
      // Log error for debugging
      debugPrint('Failed to fetch popular quizzes: ${error.message}');
      return [];
    },
  );
});

/// Provider to fetch recent quizzes for home page display
final recentQuizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  debugPrint('Fetching recent quizzes for home page');

  final useCase = ref.watch(getRecentQuizzesUseCaseProvider);
  final result = await useCase.call(GetRecentQuizzesParams(limit: 5));

  return result.when(
    success: (quizzes) {
      debugPrint('Successfully fetched ${quizzes.length} recent quizzes');
      return quizzes;
    },
    failure: (error) {
      // Log error for debugging
      debugPrint('Failed to fetch recent quizzes: ${error.message}');
      return [];
    },
  );
});

/// Provider to fetch user's created quizzes for hosting/management
final userQuizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  debugPrint('🔍 [userQuizzesProvider] Starting to fetch user quizzes');

  final currentUserId = ref.watch(currentUserIdProvider);
  debugPrint('🔍 [userQuizzesProvider] Current user ID: $currentUserId');

  if (currentUserId == null) {
    debugPrint(
      '❌ [userQuizzesProvider] No user authenticated, returning empty quiz list',
    );
    return [];
  }

  debugPrint(
    '✅ [userQuizzesProvider] Fetching quizzes for user: $currentUserId',
  );

  final useCase = ref.watch(getUserQuizzesUseCaseProvider);
  debugPrint(
    '🔍 [userQuizzesProvider] Use case obtained: ${useCase.runtimeType}',
  );

  final params = GetUserQuizzesParams(
    userId: currentUserId,
    limit: 50,
    includeDrafts: false, // Only published quizzes for hosting
    sortBy: QuizSortOption.updatedAt,
  );
  debugPrint(
    '🔍 [userQuizzesProvider] Calling use case with params: userId=$currentUserId, limit=50, includeDrafts=false',
  );

  final result = await useCase.call(params);
  debugPrint(
    '🔍 [userQuizzesProvider] Use case result type: ${result.runtimeType}',
  );

  return result.when(
    success: (quizzes) {
      debugPrint(
        '✅ [userQuizzesProvider] Successfully fetched ${quizzes.length} user quizzes',
      );
      debugPrint(
        '🔍 [userQuizzesProvider] Quiz titles: ${quizzes.map((q) => q.title).toList()}',
      );

      // Filter only quizzes suitable for multiplayer hosting
      final suitableQuizzes = quizzes
          .where((quiz) => quiz.isMultiplayerSuitable)
          .toList();
      debugPrint(
        '✅ [userQuizzesProvider] ${suitableQuizzes.length} quizzes suitable for hosting',
      );
      debugPrint(
        '🔍 [userQuizzesProvider] Suitable quiz titles: ${suitableQuizzes.map((q) => q.title).toList()}',
      );

      return suitableQuizzes;
    },
    failure: (error) {
      debugPrint(
        '❌ [userQuizzesProvider] Failed to fetch user quizzes: ${error.message}',
      );
      debugPrint('❌ [userQuizzesProvider] Error type: ${error.runtimeType}');
      return [];
    },
  );
});

/// Provider to fetch user's draft quizzes
final userDraftQuizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  debugPrint(
    '🔍 [userDraftQuizzesProvider] Starting to fetch user draft quizzes',
  );

  final currentUserId = ref.watch(currentUserIdProvider);
  debugPrint('🔍 [userDraftQuizzesProvider] Current user ID: $currentUserId');

  if (currentUserId == null) {
    debugPrint(
      '❌ [userDraftQuizzesProvider] No user authenticated, returning empty draft quiz list',
    );
    return [];
  }

  debugPrint(
    '✅ [userDraftQuizzesProvider] Fetching draft quizzes for user: $currentUserId',
  );

  final useCase = ref.watch(getUserQuizzesUseCaseProvider);
  debugPrint(
    '🔍 [userDraftQuizzesProvider] Use case obtained: ${useCase.runtimeType}',
  );

  final params = GetUserQuizzesParams(
    userId: currentUserId,
    limit: 20,
    includeDrafts: true, // Only drafts
    sortBy: QuizSortOption.updatedAt,
  );
  debugPrint(
    '🔍 [userDraftQuizzesProvider] Calling use case with params: userId=$currentUserId, limit=20, includeDrafts=true',
  );

  final result = await useCase.call(params);
  debugPrint(
    '🔍 [userDraftQuizzesProvider] Use case result type: ${result.runtimeType}',
  );

  return result.when(
    success: (quizzes) {
      debugPrint(
        '✅ [userDraftQuizzesProvider] Received ${quizzes.length} total quizzes',
      );
      final drafts = quizzes.where((quiz) => quiz.isDraft).toList();
      debugPrint(
        '✅ [userDraftQuizzesProvider] Successfully filtered ${drafts.length} draft quizzes',
      );
      debugPrint(
        '🔍 [userDraftQuizzesProvider] Draft quiz titles: ${drafts.map((q) => q.title).toList()}',
      );
      return drafts;
    },
    failure: (error) {
      debugPrint(
        '❌ [userDraftQuizzesProvider] Failed to fetch draft quizzes: ${error.message}',
      );
      debugPrint(
        '❌ [userDraftQuizzesProvider] Error type: ${error.runtimeType}',
      );
      return [];
    },
  );
});

/// Provider for quiz publishing state and functionality
final quizPublishProvider =
    StateNotifierProvider.family<QuizPublishNotifier, QuizPublishState, String>(
      (ref, quizId) {
        final publishUseCase = ref.watch(publishQuizUseCaseProvider);
        final currentUserId = ref.watch(currentUserIdProvider);
        return QuizPublishNotifier(
          publishUseCase: publishUseCase,
          quizId: quizId,
          currentUserId: currentUserId,
        );
      },
    );

/// Publish state
class QuizPublishState {
  final bool isPublishing;
  final bool isPublished;
  final String? error;
  final Quiz? publishedQuiz;

  const QuizPublishState({
    this.isPublishing = false,
    this.isPublished = false,
    this.error,
    this.publishedQuiz,
  });

  QuizPublishState copyWith({
    bool? isPublishing,
    bool? isPublished,
    String? error,
    Quiz? publishedQuiz,
  }) {
    return QuizPublishState(
      isPublishing: isPublishing ?? this.isPublishing,
      isPublished: isPublished ?? this.isPublished,
      error: error ?? this.error,
      publishedQuiz: publishedQuiz ?? this.publishedQuiz,
    );
  }
}

/// Publish notifier
class QuizPublishNotifier extends StateNotifier<QuizPublishState> {
  final PublishQuizUseCase _publishUseCase;
  final String _quizId;
  final String? _currentUserId;

  QuizPublishNotifier({
    required PublishQuizUseCase publishUseCase,
    required String quizId,
    required String? currentUserId,
  }) : _publishUseCase = publishUseCase,
       _quizId = quizId,
       _currentUserId = currentUserId,
       super(const QuizPublishState());

  /// Publish the quiz
  Future<bool> publishQuiz() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'You must be logged in to publish a quiz');
      return false;
    }

    state = state.copyWith(isPublishing: true, error: null);

    try {
      final result = await _publishUseCase(
        PublishQuizParams(quizId: _quizId, userId: userId),
      );

      return result.when(
        success: (publishedQuiz) {
          state = state.copyWith(
            isPublishing: false,
            isPublished: true,
            publishedQuiz: publishedQuiz,
            error: null,
          );
          return true;
        },
        failure: (failure) {
          state = state.copyWith(
            isPublishing: false,
            isPublished: false,
            error: failure.message,
          );
          return false;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isPublishing: false,
        isPublished: false,
        error: 'Failed to publish quiz: $e',
      );
      return false;
    }
  }

  /// Reset publish state
  void reset() {
    state = const QuizPublishState();
  }
}
