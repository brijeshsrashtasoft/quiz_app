import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:quiz_app_1/features/quiz_creation/presentation/pages/quiz_creation_page.dart';
import 'package:quiz_app_1/features/quiz_creation/presentation/providers/quiz_creation_provider.dart';
import 'package:quiz_app_1/features/quiz_creation/domain/entities/quiz.dart';
import 'package:quiz_app_1/features/quiz_creation/domain/entities/question_entities.dart';
import 'package:quiz_app_1/features/quiz_creation/domain/usecases/create_quiz_usecase.dart';
import 'package:quiz_app_1/core/common/result.dart';

// Mock implementation that doesn't require build_runner
class MockCreateQuizUseCase extends Mock implements CreateQuizUseCase {
  @override
  Future<Result<Quiz, Failure>> call(CreateQuizParams params) async {
    // Simulate successful save
    await Future.delayed(const Duration(milliseconds: 50));

    final quizWithId = Quiz(
      id: 'mock_quiz_123',
      title: params.quiz.title,
      description: params.quiz.description,
      createdBy: params.quiz.createdBy,
      questions: params.quiz.questions,
      isPublic: params.quiz.isPublic,
      createdAt: DateTime.now(),
      metadata: params.quiz.metadata,
      isDraft: params.quiz.isDraft,
    );

    return Result.success(quizWithId);
  }
}

// Mock navigation tracking
class NavigationTracker {
  static final List<String> pushCalls = [];
  static final List<String> goCalls = [];

  static void clear() {
    pushCalls.clear();
    goCalls.clear();
  }

  static void trackPush(String route) {
    pushCalls.add(route);
    print('📍 PUSH tracked: $route');
  }

  static void trackGo(String route) {
    goCalls.add(route);
    print('📍 GO tracked: $route');
  }
}

void main() {
  group('Quiz Creation Comprehensive Tests', () {
    late MockCreateQuizUseCase mockCreateUseCase;
    late ProviderContainer container;

    setUp(() {
      mockCreateUseCase = MockCreateQuizUseCase();
      NavigationTracker.clear();

      container = ProviderContainer(
        overrides: [
          quizCreationProvider.overrideWith(
            (ref) => QuizCreationNotifier(
              createUseCase: mockCreateUseCase,
              currentUserId: 'test_user_123',
            ),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Quiz Creation Flow Tests', () {
      testWidgets('should complete quiz creation and save successfully', (
        tester,
      ) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const QuizCreationPage()),
          ),
        );

        // Wait for initial load
        await tester.pumpAndSettle();

        // Verify we're on the quiz creation page
        expect(find.text('Create New Quiz'), findsOneWidget);
        expect(find.text('Preview'), findsOneWidget);

        // Fill in quiz data using the provider directly
        container
            .read(quizCreationProvider.notifier)
            .updateMetadata(
              title: 'Test Quiz Title',
              description:
                  'This is a comprehensive test quiz description that meets the minimum length requirement',
            );

        container
            .read(quizCreationProvider.notifier)
            .addQuestion(
              MultipleChoiceQuestion(
                id: 'test_q1',
                questionText: 'What is the capital of France?',
                options: ['London', 'Berlin', 'Paris', 'Madrid'],
                correctAnswerIndex: 2,
                questionTimeLimit: 30,
                points: 100,
              ),
            );

        await tester.pump();

        // Navigate to final step
        for (int i = 0; i < 2; i++) {
          final nextButton = find.text('Next');
          if (nextButton.evaluate().isNotEmpty) {
            await tester.tap(nextButton);
            await tester.pumpAndSettle();
          }
        }

        // Should be on settings step now
        expect(find.text('Save & Preview'), findsOneWidget);

        // Check the provider state before saving
        final stateBefore = container.read(quizCreationProvider);
        expect(stateBefore.title, 'Test Quiz Title');
        expect(stateBefore.questions.length, 1);
        expect(stateBefore.isLoading, false);

        // Tap save button
        await tester.tap(find.text('Save & Preview'));
        await tester.pump();

        // Should show loading state
        final stateLoading = container.read(quizCreationProvider);
        expect(stateLoading.isLoading, true);

        // Complete async operations
        await tester.pumpAndSettle();

        // Check final state
        final stateFinal = container.read(quizCreationProvider);
        expect(stateFinal.isLoading, false);
        expect(stateFinal.error, isNull);

        // Should show success message
        expect(find.text('Quiz saved successfully!'), findsOneWidget);

        // Verify the use case was called
        verify(mockCreateUseCase.call(any)).called(1);
      });

      testWidgets('should handle validation errors correctly', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const QuizCreationPage()),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to final step without filling data
        for (int i = 0; i < 2; i++) {
          final nextButton = find.text('Next');
          if (nextButton.evaluate().isNotEmpty) {
            await tester.tap(nextButton);
            await tester.pumpAndSettle();
          }
        }

        // Try to save without proper data
        await tester.tap(find.text('Save & Preview'));
        await tester.pump();

        // Should show validation error
        final state = container.read(quizCreationProvider);
        expect(state.error, isNotNull);
        expect(
          state.error,
          contains('Quiz title must be at least 3 characters'),
        );

        // Use case should not be called for invalid data
        verifyNever(mockCreateUseCase.call(any));
      });

      testWidgets('should handle save failure correctly', (tester) async {
        // Override the mock to return failure
        when(mockCreateUseCase.call(any)).thenAnswer((_) async {
          return const Result.failure(
            Failure(
              code: 'SAVE_ERROR',
              message: 'Failed to save quiz to database',
            ),
          );
        });

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(home: const QuizCreationPage()),
          ),
        );

        await tester.pumpAndSettle();

        // Fill valid data
        container
            .read(quizCreationProvider.notifier)
            .updateMetadata(
              title: 'Valid Quiz Title',
              description:
                  'This is a valid quiz description with sufficient length',
            );

        container
            .read(quizCreationProvider.notifier)
            .addQuestion(
              MultipleChoiceQuestion(
                id: 'test_q1',
                questionText: 'Test question?',
                options: ['A', 'B', 'C', 'D'],
                correctAnswerIndex: 0,
                questionTimeLimit: 30,
                points: 100,
              ),
            );

        await tester.pump();

        // Navigate to final step
        for (int i = 0; i < 2; i++) {
          final nextButton = find.text('Next');
          if (nextButton.evaluate().isNotEmpty) {
            await tester.tap(nextButton);
            await tester.pumpAndSettle();
          }
        }

        // Try to save
        await tester.tap(find.text('Save & Preview'));
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.text('Failed to save quiz to database'), findsOneWidget);

        // Check error state
        final state = container.read(quizCreationProvider);
        expect(state.error, 'Failed to save quiz to database');
        expect(state.isLoading, false);
      });
    });

    group('Navigation Analysis Tests', () {
      testWidgets('should analyze navigation behavior after save', (
        tester,
      ) async {
        // This test focuses on understanding what happens after a successful save

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Column(
                      children: [
                        const Text('Navigation Test Page'),
                        ElevatedButton(
                          onPressed: () async {
                            // Simulate the save operation from QuizCreationPage
                            final notifier = container.read(
                              quizCreationProvider.notifier,
                            );

                            // Set up valid data
                            notifier.updateMetadata(
                              title: 'Navigation Test Quiz',
                              description:
                                  'Testing navigation after quiz save operation',
                            );

                            notifier.addQuestion(
                              MultipleChoiceQuestion(
                                id: 'nav_q1',
                                questionText: 'Navigation test question?',
                                options: ['A', 'B', 'C', 'D'],
                                correctAnswerIndex: 0,
                                questionTimeLimit: 30,
                                points: 100,
                              ),
                            );

                            // Call saveQuiz and see what ID we get
                            final quizId = await notifier.saveQuiz();
                            print('📊 Save operation completed');
                            print('📊 Returned quiz ID: $quizId');

                            if (quizId != null) {
                              // This is what QuizCreationPage does on line 67
                              final navigationRoute =
                                  '/quiz-creation/preview?id=$quizId';
                              print('📊 Would navigate to: $navigationRoute');
                              NavigationTracker.trackPush(navigationRoute);

                              // Try to understand if the route is valid
                              print('📊 Route analysis:');
                              print('   - Base route: /quiz-creation');
                              print('   - Sub route: preview');
                              print('   - Query param: id=$quizId');
                              print('   - Full route: $navigationRoute');
                            } else {
                              print('❌ Save failed - no quiz ID returned');
                            }
                          },
                          child: const Text('Simulate Save & Navigate'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Simulate Save & Navigate'));
        await tester.pumpAndSettle();

        // Verify the navigation was tracked
        expect(NavigationTracker.pushCalls, isNotEmpty);
        final navigationRoute = NavigationTracker.pushCalls.first;

        expect(navigationRoute, startsWith('/quiz-creation/preview?id='));
        expect(navigationRoute, contains('mock_quiz_123'));

        print('✅ Navigation route successfully generated: $navigationRoute');
      });
    });

    group('Provider State Management Tests', () {
      testWidgets('should manage loading states correctly', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(quizCreationProvider);
                  return Scaffold(
                    body: Column(
                      children: [
                        Text('Loading: ${state.isLoading}'),
                        Text('Error: ${state.error ?? "none"}'),
                        Text('Title: "${state.title}"'),
                        Text('Questions: ${state.questions.length}'),
                        ElevatedButton(
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  // Set up data
                                  ref
                                      .read(quizCreationProvider.notifier)
                                      .updateMetadata(
                                        title: 'State Test Quiz',
                                        description:
                                            'Testing state management during save operations',
                                      );

                                  ref
                                      .read(quizCreationProvider.notifier)
                                      .addQuestion(
                                        MultipleChoiceQuestion(
                                          id: 'state_q1',
                                          questionText: 'State test question?',
                                          options: ['A', 'B', 'C', 'D'],
                                          correctAnswerIndex: 0,
                                          questionTimeLimit: 30,
                                          points: 100,
                                        ),
                                      );

                                  // Save quiz
                                  await ref
                                      .read(quizCreationProvider.notifier)
                                      .saveQuiz();
                                },
                          child: const Text('Test Save'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Initial state
        expect(find.text('Loading: false'), findsOneWidget);
        expect(find.text('Error: none'), findsOneWidget);
        expect(find.text('Questions: 0'), findsOneWidget);

        // Start save operation
        await tester.tap(find.text('Test Save'));
        await tester.pump();

        // Should show loading
        expect(find.text('Loading: true'), findsOneWidget);

        // Complete operation
        await tester.pumpAndSettle();

        // Should return to not loading
        expect(find.text('Loading: false'), findsOneWidget);
        expect(find.text('Error: none'), findsOneWidget);
        expect(find.text('Questions: 1'), findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle provider errors gracefully', (tester) async {
        // Test what happens when the provider encounters an error
        when(mockCreateUseCase.call(any)).thenThrow(Exception('Network error'));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(quizCreationProvider);
                  return Scaffold(
                    body: Column(
                      children: [
                        Text('Error: ${state.error ?? "none"}'),
                        ElevatedButton(
                          onPressed: () async {
                            // Set up valid data
                            ref
                                .read(quizCreationProvider.notifier)
                                .updateMetadata(
                                  title: 'Error Test Quiz',
                                  description:
                                      'Testing error handling during save operations',
                                );

                            ref
                                .read(quizCreationProvider.notifier)
                                .addQuestion(
                                  MultipleChoiceQuestion(
                                    id: 'error_q1',
                                    questionText: 'Error test question?',
                                    options: ['A', 'B', 'C', 'D'],
                                    correctAnswerIndex: 0,
                                    questionTimeLimit: 30,
                                    points: 100,
                                  ),
                                );

                            // This should trigger an error
                            await ref
                                .read(quizCreationProvider.notifier)
                                .saveQuiz();
                          },
                          child: const Text('Trigger Error'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Trigger Error'));
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.textContaining('Failed to save quiz:'), findsOneWidget);
      });
    });
  });
}

// Helper function to simulate form filling
Future<void> fillQuizForm(
  WidgetTester tester,
  ProviderContainer container,
) async {
  container
      .read(quizCreationProvider.notifier)
      .updateMetadata(
        title: 'Test Quiz Title',
        description:
            'This is a test quiz description with sufficient length to pass validation',
      );

  container
      .read(quizCreationProvider.notifier)
      .addQuestion(
        MultipleChoiceQuestion(
          id: 'test_question_1',
          questionText: 'What is 2 + 2?',
          options: ['3', '4', '5', '6'],
          correctAnswerIndex: 1,
          questionTimeLimit: 30,
          points: 100,
        ),
      );

  await tester.pump();
}
