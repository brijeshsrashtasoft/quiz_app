import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quiz_app/main.dart' as app;
import '../helpers/widget_test_helper.dart';
import '../helpers/test_utilities.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete App Flow Integration Tests', () {
    testWidgets('User registration and quiz creation flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app starts at login screen
      expect(find.text('Welcome'), findsOneWidget);

      // Navigate to registration
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Fill registration form
      final testEmail = TestUtilities.randomEmail();
      final testPassword = TestUtilities.randomString(12);
      final testName = 'Test User ${TestUtilities.randomString(4)}';

      await tester.enterText(find.byKey(const Key('name_input')), testName);
      await tester.enterText(find.byKey(const Key('email_input')), testEmail);
      await tester.enterText(find.byKey(const Key('password_input')), testPassword);

      // Submit registration
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should navigate to home screen
      expect(find.text('My Quizzes'), findsOneWidget);

      // Navigate to quiz creation
      await tester.tap(find.byKey(const Key('create_quiz_fab')));
      await tester.pumpAndSettle();

      // Fill quiz creation form
      final quizTitle = 'Test Quiz ${TestUtilities.randomString(4)}';
      final quizDescription = 'A test quiz created during integration testing';

      await tester.enterText(find.byKey(const Key('quiz_title_input')), quizTitle);
      await tester.enterText(find.byKey(const Key('quiz_description_input')), quizDescription);

      // Add questions
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('add_question_button')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(Key('question_${i}_text')),
          'Test Question ${i + 1}?',
        );

        // Add answer options
        for (int j = 0; j < 4; j++) {
          await tester.enterText(
            find.byKey(Key('question_${i}_option_$j')),
            'Option ${j + 1}',
          );
        }

        // Set correct answer
        await tester.tap(find.byKey(Key('question_${i}_correct_0')));
        await tester.pumpAndSettle();
      }

      // Save quiz
      await tester.tap(find.byKey(const Key('save_quiz_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate back to home with new quiz
      expect(find.text('My Quizzes'), findsOneWidget);
      expect(find.text(quizTitle), findsOneWidget);
    });

    testWidgets('Quiz gameplay flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Assume user is already logged in (mock auth state)
      // Or login first if needed

      // Navigate to join game
      await tester.tap(find.byKey(const Key('join_game_button')));
      await tester.pumpAndSettle();

      // Enter game PIN
      const gamePin = '123456';
      await tester.enterText(find.byKey(const Key('pin_input')), gamePin);
      await tester.tap(find.byKey(const Key('join_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be in game lobby
      expect(find.text('Waiting for game to start'), findsOneWidget);

      // Simulate game start (this would normally come from host)
      // For integration test, we might need to mock this

      // Once game starts, should see first question
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Question 1'), findsOneWidget);

      // Answer questions
      for (int i = 0; i < 3; i++) {
        // Wait for question to load
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Find and tap an answer button
        final answerButtons = find.byType(GestureDetector);
        if (answerButtons.evaluate().isNotEmpty) {
          await tester.tap(answerButtons.first);
          await tester.pumpAndSettle();
        }

        // Wait for next question or results
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Should show final results
      expect(find.text('Final Results'), findsOneWidget);
      expect(find.text('Your Score'), findsOneWidget);
    });

    testWidgets('Quiz hosting flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to host game
      await tester.tap(find.byKey(const Key('host_game_button')));
      await tester.pumpAndSettle();

      // Select a quiz to host
      final quizCards = find.byType(GestureDetector);
      if (quizCards.evaluate().isNotEmpty) {
        await tester.tap(quizCards.first);
        await tester.pumpAndSettle();
      }

      // Start hosting
      await tester.tap(find.byKey(const Key('start_hosting_button')));
      await tester.pumpAndSettle();

      // Should show game PIN and waiting screen
      expect(find.text('Game PIN'), findsOneWidget);
      expect(find.textContaining('PIN:'), findsOneWidget);

      // Start the game
      await tester.tap(find.byKey(const Key('start_game_button')));
      await tester.pumpAndSettle();

      // Should show host view of questions
      expect(find.text('Question 1'), findsOneWidget);
      expect(find.text('Players:'), findsOneWidget);
    });

    testWidgets('Offline functionality', (tester) async {
      // Test app behavior when offline
      app.main();
      await tester.pumpAndSettle();

      // Simulate offline state
      // This would require mocking network connectivity

      // Try to create quiz while offline
      await tester.tap(find.byKey(const Key('create_quiz_fab')));
      await tester.pumpAndSettle();

      // Should show offline indicator or cached content
      // Exact behavior depends on implementation
    });

    testWidgets('Theme switching', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();

      // Switch to dark theme
      await tester.tap(find.byKey(const Key('dark_theme_toggle')));
      await tester.pumpAndSettle();

      // Verify theme changed
      // This would check for dark theme colors in UI
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, isNot(equals(Colors.white)));

      // Switch back to light theme
      await tester.tap(find.byKey(const Key('dark_theme_toggle')));
      await tester.pumpAndSettle();
    });

    testWidgets('Performance under load', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Measure performance with many quizzes
      final stopwatch = Stopwatch()..start();

      // Navigate to quiz list
      await tester.tap(find.byKey(const Key('all_quizzes_tab')));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should load within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      // Test scrolling performance
      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.fling(listView, const Offset(0, -500), 1000);
        await tester.pumpAndSettle();

        // Should handle scrolling smoothly
        expect(find.byType(ListView), findsOneWidget);
      }
    });

    testWidgets('Error handling and recovery', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulate network error during quiz creation
      await tester.tap(find.byKey(const Key('create_quiz_fab')));
      await tester.pumpAndSettle();

      // Fill form with invalid data
      await tester.enterText(find.byKey(const Key('quiz_title_input')), '');
      await tester.tap(find.byKey(const Key('save_quiz_button')));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Title is required'), findsOneWidget);

      // Fix the error
      await tester.enterText(find.byKey(const Key('quiz_title_input')), 'Valid Title');
      await tester.tap(find.byKey(const Key('save_quiz_button')));
      await tester.pumpAndSettle();

      // Should proceed without error
      expect(find.text('Title is required'), findsNothing);
    });

    testWidgets('Memory usage stability', (tester) async {
      // Test for memory leaks during navigation
      app.main();
      await tester.pumpAndSettle();

      // Navigate through multiple screens repeatedly
      for (int i = 0; i < 10; i++) {
        // Home -> Quiz Creation -> Back
        await tester.tap(find.byKey(const Key('create_quiz_fab')));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();

        // Home -> Settings -> Back
        await tester.tap(find.byKey(const Key('settings_button')));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();
      }

      // App should still be responsive
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Accessibility compliance', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Check semantic labels are present
      final semantics = tester.allSemantics;
      expect(semantics.length, greaterThan(5));

      // Check for proper button semantics
      final buttons = semantics.where((s) => s.hasFlag(SemanticsFlag.isButton));
      expect(buttons.length, greaterThan(2));

      // Check for text field semantics
      await tester.tap(find.byKey(const Key('create_quiz_fab')));
      await tester.pumpAndSettle();

      final updatedSemantics = tester.allSemantics;
      final textFields = updatedSemantics.where((s) => s.hasFlag(SemanticsFlag.isTextField));
      expect(textFields.length, greaterThan(0));
    });

    testWidgets('Real-time functionality', (tester) async {
      // Test real-time features like live leaderboards
      app.main();
      await tester.pumpAndSettle();

      // Join a game session
      await tester.tap(find.byKey(const Key('join_game_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('pin_input')), '123456');
      await tester.tap(find.byKey(const Key('join_button')));
      await tester.pumpAndSettle();

      // Should see real-time player count updates
      // This would require mocking Firestore streams
      expect(find.text('Players: 1'), findsOneWidget);

      // Simulate another player joining
      // This would be handled by Firestore listeners
      await tester.pump(const Duration(seconds: 2));

      // Should update player count
      // expect(find.text('Players: 2'), findsOneWidget);
    });
  });

  group('Platform-Specific Tests', () {
    testWidgets('Web-specific functionality', (tester) async {
      // Test web-specific features like URL handling
      app.main();
      await tester.pumpAndSettle();

      // These tests would only run on web platform
      // and test browser-specific functionality
    });

    testWidgets('Mobile-specific functionality', (tester) async {
      // Test mobile-specific features like push notifications
      app.main();
      await tester.pumpAndSettle();

      // These tests would only run on mobile platforms
      // and test device-specific functionality
    });
  });
}