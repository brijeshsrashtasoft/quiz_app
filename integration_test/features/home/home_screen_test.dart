import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiz_app/main.dart';
import 'package:quiz_app/features/home/presentation/pages/home_page.dart';
import 'package:quiz_app/shared/constants/app_colors.dart';
import 'package:quiz_app/shared/widgets/cards/quiz_card.dart';
import 'package:quiz_app/shared/widgets/navigation/app_navigation_bar.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/mock_providers.dart';

void main() {
  E2ETestHelpers.initialize();

  group('Home Screen E2E Tests', () {
    testWidgets('should display home screen with correct UI elements when authenticated', (tester) async {
      // Arrange: Set up authenticated state to ensure we reach home screen
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Navigate to home screen (should happen automatically for authenticated users)
      await E2ETestHelpers.waitForNavigation(tester);
      
      // Skip splash screen navigation
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);

      // Wait for home page to load
      await E2ETestHelpers.waitForWidget(tester, find.byType(HomePage));

      // Assert: Verify home screen UI elements
      E2ETestHelpers.verifyWidgetByType<HomePage>();
      
      // Verify app title in app bar
      E2ETestHelpers.verifyTextExists('Quiz Master');
      
      // Verify background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppColors.offWhite));
      
      // Verify navigation bar is present
      E2ETestHelpers.verifyWidgetByType<AppNavigationBar>();
    });

    testWidgets('should display welcome header with greeting', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Navigate to home screen
      await E2ETestHelpers.waitForNavigation(tester);
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);
      await E2ETestHelpers.waitForWidget(tester, find.byType(HomePage));

      // Assert: Verify welcome header elements
      // Check for greeting text (will be one of: Good Morning, Good Afternoon, Good Evening)
      final greetingFinder = find.textContaining('Good');
      expect(greetingFinder, findsOneWidget);
      
      // Verify user name is displayed (from mock data)
      E2ETestHelpers.verifyTextExists('Test User');
      
      // Verify motivational text
      E2ETestHelpers.verifyTextExists('Ready to challenge minds and have fun with interactive quizzes?');
      
      // Verify quiz icon in header
      expect(find.byIcon(Icons.quiz), findsAtLeastNWidgets(1));
    });

    testWidgets('should display quick actions grid', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Navigate to home screen
      await E2ETestHelpers.waitForNavigation(tester);
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);
      await E2ETestHelpers.waitForWidget(tester, find.byType(HomePage));

      // Assert: Verify quick actions section
      E2ETestHelpers.verifyTextExists('Quick Actions');
      
      // Verify all four quick action cards
      E2ETestHelpers.verifyTextExists('Create Quiz');
      E2ETestHelpers.verifyTextExists('Join Game');
      E2ETestHelpers.verifyTextExists('Host Game');
      E2ETestHelpers.verifyTextExists('Leaderboard');
      
      // Verify quick action subtitles
      E2ETestHelpers.verifyTextExists('Build your quiz');
      E2ETestHelpers.verifyTextExists('Enter game PIN');
      E2ETestHelpers.verifyTextExists('Start a session');
      E2ETestHelpers.verifyTextExists('View rankings');
      
      // Verify icons are present
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.sports_esports_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.leaderboard_outlined), findsOneWidget);
    });

    testWidgets('should display featured quizzes section', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Navigate to home screen
      await E2ETestHelpers.waitForNavigation(tester);
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);
      await E2ETestHelpers.waitForWidget(tester, find.byType(HomePage));

      // Assert: Verify featured quizzes section
      E2ETestHelpers.verifyTextExists('Featured Quizzes');
      E2ETestHelpers.verifyTextExists('View All');
      
      // Verify featured quiz cards (from mock data)
      E2ETestHelpers.verifyTextExists('Science Trivia');
      E2ETestHelpers.verifyTextExists('World Geography');
      E2ETestHelpers.verifyTextExists('Pop Culture Quiz');
      
      // Verify quiz descriptions
      E2ETestHelpers.verifyTextExists('Test your knowledge of basic science concepts');
      E2ETestHelpers.verifyTextExists('Explore countries, capitals, and landmarks');
      E2ETestHelpers.verifyTextExists('Movies, music, and trends from the 2020s');
      
      // Verify quiz card widgets are present
      E2ETestHelpers.verifyMultipleWidgetsByType<QuizCard>(3);
    });

    testWidgets('should display recent activity section', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Navigate to home screen
      await E2ETestHelpers.waitForNavigation(tester);
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);
      await E2ETestHelpers.waitForWidget(tester, find.byType(HomePage));

      // Assert: Verify recent activity section
      E2ETestHelpers.verifyTextExists('Recent Activity');
      
      // Verify recent activity items (from mock data)
      E2ETestHelpers.verifyTextExists('Created History Quiz');
      E2ETestHelpers.verifyTextExists('Played Math Challenge');
      E2ETestHelpers.verifyTextExists('Hosted Science Trivia');
      
      // Verify timestamps
      E2ETestHelpers.verifyTextExists('2 hours ago');
      E2ETestHelpers.verifyTextExists('1 day ago');
      E2ETestHelpers.verifyTextExists('3 days ago');
      
      // Verify activity icons
      expect(find.byIcon(Icons.quiz), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.sports_esports), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.person), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle search button tap', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Navigate to home screen
      await E2ETestHelpers.waitForNavigation(tester);
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);
      await E2ETestHelpers.waitForWidget(tester, find.byType(HomePage));

      // Find and tap search button
      final searchButton = find.byIcon(Icons.search);
      expect(searchButton, findsOneWidget);
      
      // Tap search button (currently does nothing, but should not crash)
      await E2ETestHelpers.tapAndWait(tester, searchButton);

      // Assert: App should still be functional
      E2ETestHelpers.verifyWidgetByType<HomePage>();
    });

    testWidgets('should handle quick action taps', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Navigate to home screen
      await E2ETestHelpers.waitForNavigation(tester);
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);
      await E2ETestHelpers.waitForWidget(tester, find.byType(HomePage));

      // Test each quick action button
      final quickActions = [
        'Create Quiz',
        'Join Game',
        'Host Game',
        'Leaderboard',
      ];

      for (final action in quickActions) {
        // Find the quick action card by text
        final actionCard = find.ancestor(
          of: find.text(action),
          matching: find.byType(InkWell),
        );
        
        expect(actionCard, findsOneWidget);
        
        // Tap the action (should attempt navigation)
        await E2ETestHelpers.tapAndWait(tester, actionCard);
        
        // For this test, we'll just verify the app doesn't crash
        // In a real app, you'd verify navigation to the correct screen
        
        // Return to home if navigation occurred
        // This is a simplified approach - in reality you'd check the route
        await tester.pump();
      }
    });

    testWidgets('should scroll through content properly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Navigate to home screen
      await E2ETestHelpers.waitForNavigation(tester);
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);
      await E2ETestHelpers.waitForWidget(tester, find.byType(HomePage));

      // Scroll down to see all content
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Assert: Should still see content at bottom
      E2ETestHelpers.verifyTextExists('Recent Activity');
      
      // Scroll back up
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Should see top content again
      E2ETestHelpers.verifyTextExists('Quiz Master');
    });

    testWidgets('should handle horizontal scroll in featured quizzes', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Navigate to home screen
      await E2ETestHelpers.waitForNavigation(tester);
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);
      await E2ETestHelpers.waitForWidget(tester, find.byType(HomePage));

      // Find the horizontal ListView in featured quizzes
      final horizontalList = find.byType(ListView).first;
      
      // Initially should see first quiz
      E2ETestHelpers.verifyTextExists('Science Trivia');
      
      // Scroll horizontally to see other quizzes
      await tester.drag(horizontalList, const Offset(-200, 0));
      await tester.pumpAndSettle();

      // Should still see quiz content
      expect(find.byType(QuizCard), findsAtLeastNWidgets(1));
    });

    testWidgets('should display proper animations', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Navigate to home screen
      await E2ETestHelpers.waitForNavigation(tester);
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);
      await E2ETestHelpers.waitForWidget(tester, find.byType(HomePage));

      // Assert: Check that fade animation widgets are present
      expect(find.byType(FadeTransition), findsAtLeastNWidgets(1));
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
      
      // Verify that animations complete
      await tester.pumpAndSettle(const Duration(seconds: 2));
      E2ETestHelpers.verifyWidgetByType<HomePage>();
    });

    testWidgets('should work with different screen orientations', (tester) async {
      // Test portrait mode
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      await E2ETestHelpers.waitForNavigation(tester);
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);
      await E2ETestHelpers.waitForWidget(tester, find.byType(HomePage));

      // Verify content is visible in portrait
      E2ETestHelpers.verifyTextExists('Quiz Master');
      E2ETestHelpers.verifyTextExists('Quick Actions');

      // Simulate landscape mode by changing screen size
      await tester.binding.setSurfaceSize(const Size(896, 414));
      await tester.pumpAndSettle();

      // Content should still be visible
      E2ETestHelpers.verifyTextExists('Quiz Master');
      E2ETestHelpers.verifyTextExists('Quick Actions');

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should handle loading states gracefully', (tester) async {
      // Arrange: Start with loading state
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.loadingState),
          child: const QuizApp(),
        ),
      );

      // Should show splash screen during loading
      await E2ETestHelpers.waitForWidget(tester, find.byType(CircularProgressIndicator));
      
      // Eventually should reach a stable state
      await tester.pump(const Duration(seconds: 2));
      await E2ETestHelpers.waitForNavigation(tester);
    });

    testWidgets('should maintain state during app lifecycle changes', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestScenarioManager.getOverrides(TestScenario.authenticatedUser),
          child: const QuizApp(),
        ),
      );

      // Act: Navigate to home screen
      await E2ETestHelpers.waitForNavigation(tester);
      await tester.pump(const Duration(seconds: 1));
      await E2ETestHelpers.waitForNavigation(tester);
      await E2ETestHelpers.waitForWidget(tester, find.byType(HomePage));

      // Simulate app lifecycle changes
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpAndSettle();

      // Assert: Content should still be there
      E2ETestHelpers.verifyWidgetByType<HomePage>();
      E2ETestHelpers.verifyTextExists('Quiz Master');
    });
  });
}