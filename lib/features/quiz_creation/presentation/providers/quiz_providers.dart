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
import '../../domain/entities/quiz.dart';

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
