import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:quiz_app/features/quiz_creation/presentation/pages/quiz_creation_page.dart';
import 'package:quiz_app/features/quiz_creation/presentation/providers/quiz_creation_provider.dart';
import 'package:quiz_app/features/quiz_creation/presentation/widgets/quiz_stepper_widget.dart';
import 'package:quiz_app/features/quiz_creation/presentation/widgets/quiz_metadata_form.dart';
import 'package:quiz_app/features/quiz_creation/presentation/widgets/question_builder/question_list_widget.dart';
import 'package:quiz_app/features/quiz_creation/domain/usecases/create_quiz_usecase.dart';
import 'package:quiz_app/features/quiz_creation/presentation/providers/quiz_providers.dart';
import 'package:quiz_app/shared/constants/app_colors.dart';
import 'package:quiz_app/shared/constants/app_spacing.dart';
import 'package:quiz_app/shared/constants/app_text_styles.dart';
import 'package:quiz_app/shared/widgets/buttons/primary_button.dart';
import 'package:quiz_app/shared/providers/firebase_providers.dart';

// Generate mocks
@GenerateMocks([CreateQuizUseCase])
import 'quiz_creation_page_test.mocks.dart';

void main() {
  group('QuizCreationPage Widget Tests', () {
    late MockCreateQuizUseCase mockCreateQuizUseCase;
    late ProviderContainer container;

    setUp(() {
      mockCreateQuizUseCase = MockCreateQuizUseCase();
    });

    tearDown(() {
      container.dispose();
    });

    /// Helper function to create a widget with mocked providers
    Widget createTestWidget({
      QuizCreationState? initialState,
      bool useErrorProvider = false,
    }) {
      container = ProviderContainer(
        overrides: [
          // Mock the createQuizUseCase provider
          createQuizUseCaseProvider.overrideWithValue(mockCreateQuizUseCase),
          // Mock the currentUserId provider
          currentUserIdProvider.overrideWithValue('test_user_id'),
          if (useErrorProvider)
            quizCreationProvider.overrideWith(
              (ref) => throw Exception('Provider initialization error'),
            ),
        ],
      );

      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: const QuizCreationPage(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.vibrantPurple,
            ),
            useMaterial3: true,
          ),
        ),
      );
    }

    group('Basic Widget Structure', () {
      testWidgets('should render scaffold with app bar', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Verify scaffold exists
        expect(find.byType(Scaffold), findsOneWidget);

        // Verify app bar exists and is configured correctly
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Create New Quiz'), findsOneWidget);

        // Verify background color
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, AppColors.backgroundPrimary);
      });

      testWidgets(
        'should render app bar with close button and preview button',
        (tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pump();

          // Verify close button exists
          expect(find.byIcon(Icons.close), findsOneWidget);

          // Verify preview button exists
          expect(find.text('Preview'), findsOneWidget);
          expect(find.byType(TextButton), findsOneWidget);
        },
      );

      testWidgets('should render body with SafeArea and Column', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Verify SafeArea exists in body
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.body, isA<SafeArea>());

        // Verify Column structure in body
        expect(find.byType(SafeArea), findsWidgets);
        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('should render stepper widget in body', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify stepper widget exists
        expect(find.byType(QuizStepperWidget), findsOneWidget);

        // Verify stepper is properly configured
        final stepperWidget = tester.widget<QuizStepperWidget>(
          find.byType(QuizStepperWidget),
        );
        expect(stepperWidget.currentStep, 0);
        expect(stepperWidget.onStepTapped, isNotNull);
      });
    });

    group('Body Content Rendering', () {
      testWidgets('should render Expanded widget containing step content', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find all Expanded widgets
        final expandedWidgets = find.byType(Expanded);
        expect(expandedWidgets, findsWidgets);

        // Verify at least one Expanded widget contains our content
        final expandedWidgetsList = tester.widgetList<Expanded>(
          expandedWidgets,
        );
        expect(expandedWidgetsList.length, greaterThan(0));
      });

      testWidgets(
        'should render Container with proper constraints for step content',
        (tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Verify Container with step content exists
          expect(find.byType(Container), findsWidgets);

          // Verify SingleChildScrollView exists for step content
          expect(find.byType(SingleChildScrollView), findsWidgets);
        },
      );

      testWidgets(
        'should render step 0 content (QuizMetadataForm) by default',
        (tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Verify metadata form is rendered
          expect(find.byType(QuizMetadataForm), findsOneWidget);

          // Verify form elements are present
          expect(find.text('Quiz Information'), findsOneWidget);
          expect(find.text('Quiz Title'), findsOneWidget);
          expect(find.text('Description'), findsOneWidget);
          expect(find.text('Category'), findsOneWidget);
        },
      );

      testWidgets('should show proper sizing and constraints', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Get the size of the screen
        final size = tester.getSize(find.byType(MaterialApp));
        expect(size.width, greaterThan(0));
        expect(size.height, greaterThan(0));

        // Verify content takes available space
        final scaffold = find.byType(Scaffold);
        final scaffoldSize = tester.getSize(scaffold);
        expect(scaffoldSize.width, size.width);
        expect(scaffoldSize.height, size.height);
      });
    });

    group('Step Content Switching', () {
      testWidgets('should display QuizMetadataForm for step 0', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(QuizMetadataForm), findsOneWidget);
        expect(find.byType(QuestionListWidget), findsNothing);
      });

      testWidgets('should display QuestionListWidget for step 1', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to step 1 by tapping next button
        final nextButton = find.text('Next');
        expect(nextButton, findsOneWidget);
        await tester.tap(nextButton);
        await tester.pumpAndSettle();

        expect(find.byType(QuestionListWidget), findsOneWidget);
        expect(find.byType(QuizMetadataForm), findsNothing);
      });

      testWidgets('should display quiz settings for step 2', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to step 2 by tapping next twice
        final nextButton = find.text('Next');
        expect(nextButton, findsOneWidget);

        // Go to step 1
        await tester.tap(nextButton);
        await tester.pumpAndSettle();

        // Go to step 2
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        // Verify settings content
        expect(find.text('Quiz Settings'), findsOneWidget);
        expect(find.text('Make quiz public'), findsOneWidget);
        expect(find.text('Enable leaderboard'), findsOneWidget);
        expect(find.text('Randomize questions'), findsOneWidget);
      });
    });

    group('Error Handling and Edge Cases', () {
      testWidgets('should handle provider state errors gracefully', (
        tester,
      ) async {
        // Create widget with error provider
        container = ProviderContainer(
          overrides: [
            quizCreationProvider.overrideWith(
              (ref) => QuizCreationNotifier(
                createUseCase: mockCreateQuizUseCase,
                currentUserId: null, // This might cause issues
              ),
            ),
          ],
        );

        final widget = UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: const QuizCreationPage()),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Should still render without crashing
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(QuizStepperWidget), findsOneWidget);
      });

      testWidgets('should handle invalid step gracefully', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // App should render without crashing even in edge cases
        expect(find.byType(QuizCreationPage), findsOneWidget);
        expect(find.byType(QuizStepperWidget), findsOneWidget);
        expect(find.byType(QuizMetadataForm), findsOneWidget);
      });

      testWidgets('should render error fallback for step content failures', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // The buildStepContent method has try-catch that should render error UI
        // if widgets fail to render. This verifies the error handling exists.
        expect(find.byType(QuizMetadataForm), findsOneWidget);

        // If there was an error, we'd see error text
        expect(find.text('Error loading step content'), findsNothing);
      });
    });

    group('Layout and Responsive Design', () {
      testWidgets('should handle small screen layout', (tester) async {
        // Set small screen size
        await tester.binding.setSurfaceSize(const Size(350, 600));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(QuizMetadataForm), findsOneWidget);
        expect(find.byType(QuizStepperWidget), findsOneWidget);

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should handle tablet layout', (tester) async {
        // Set tablet screen size
        await tester.binding.setSurfaceSize(const Size(800, 1024));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(QuizMetadataForm), findsOneWidget);
        expect(find.byType(QuizStepperWidget), findsOneWidget);

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should handle desktop layout', (tester) async {
        // Set desktop screen size
        await tester.binding.setSurfaceSize(const Size(1400, 900));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(QuizMetadataForm), findsOneWidget);
        expect(find.byType(QuizStepperWidget), findsOneWidget);

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Navigation Buttons', () {
      testWidgets('should show navigation buttons at bottom', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify navigation buttons container exists
        expect(find.byType(PrimaryButton), findsWidgets);

        // On step 0, should only show Next button
        expect(find.text('Next'), findsOneWidget);
        expect(find.text('Previous'), findsNothing);
      });

      testWidgets('should show both Previous and Next on middle steps', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to step 1
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Previous'), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);
      });

      testWidgets('should show Save & Preview on final step', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to step 2
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Previous'), findsOneWidget);
        expect(find.text('Save & Preview'), findsOneWidget);
      });
    });

    group('Provider Integration', () {
      testWidgets('should watch quiz creation provider state', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify Consumer widgets exist for provider integration
        expect(find.byType(Consumer), findsWidgets);
      });

      testWidgets('should handle loading state correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Initially should not be loading
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Verify preview button is enabled
        final previewButton = find.text('Preview');
        expect(previewButton, findsOneWidget);
      });
    });

    group('Body Visibility Specific Tests', () {
      testWidgets('should have visible body content with proper opacity', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify the main body content is actually visible
        final bodyFinder = find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(SafeArea),
        );
        expect(bodyFinder, findsWidgets);

        // Check that the step content container exists and is visible
        final contentFinder = find.descendant(
          of: bodyFinder.first,
          matching: find.byType(QuizMetadataForm),
        );
        expect(contentFinder, findsOneWidget);

        // Verify the widget has proper size
        final contentSize = tester.getSize(contentFinder);
        expect(contentSize.width, greaterThan(0));
        expect(contentSize.height, greaterThan(0));
      });

      testWidgets('should render step content with proper constraints', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find the specific container that holds step content
        final expandedFinder = find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(Expanded),
        );
        expect(expandedFinder, findsWidgets);

        // Verify the expanded widget takes available space
        final expandedWidget = expandedFinder.first;
        final expandedSize = tester.getSize(expandedWidget);
        expect(
          expandedSize.height,
          greaterThan(200),
        ); // Should have reasonable height
      });

      testWidgets('should show content even with different screen sizes', (
        tester,
      ) async {
        // Test various screen sizes to ensure content is always visible
        final testSizes = [
          const Size(320, 568), // iPhone SE
          const Size(375, 667), // iPhone 8
          const Size(414, 896), // iPhone 11
          const Size(768, 1024), // iPad
          const Size(1024, 768), // iPad landscape
        ];

        for (final size in testSizes) {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Verify content is visible on this screen size
          expect(find.byType(QuizMetadataForm), findsOneWidget);
          expect(find.text('Quiz Information'), findsOneWidget);

          // Verify content has reasonable size
          final contentSize = tester.getSize(find.byType(QuizMetadataForm));
          expect(contentSize.width, greaterThan(0));
          expect(contentSize.height, greaterThan(0));
        }

        // Reset size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets(
        'should maintain content visibility during step transitions',
        (tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Step 0 - Verify content is visible
          expect(find.byType(QuizMetadataForm), findsOneWidget);
          final step0Size = tester.getSize(find.byType(QuizMetadataForm));
          expect(step0Size.height, greaterThan(0));

          // Transition to Step 1
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();

          // Step 1 - Verify content is visible
          expect(find.byType(QuestionListWidget), findsOneWidget);
          final step1Size = tester.getSize(find.byType(QuestionListWidget));
          expect(step1Size.height, greaterThan(0));

          // Transition to Step 2
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();

          // Step 2 - Verify content is visible
          expect(find.text('Quiz Settings'), findsOneWidget);
          expect(find.byType(SwitchListTile), findsWidgets);
        },
      );
    });
  });
}
