import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/quiz_firestore_datasource.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/usecases/create_quiz_usecase.dart';
import '../../domain/usecases/update_quiz_usecase.dart';
import '../../domain/usecases/validate_quiz_usecase.dart';

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