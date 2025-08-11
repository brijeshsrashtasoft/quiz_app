import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quiz_app/main.dart' as app;
import 'test_helpers/integration_test_helpers.dart';

/// Focused integration tests for quiz game flow
/// Tests the complete end-to-end scenario of:
/// 1. Host (Brijesh) creates and hosts a quiz
/// 2. Player 1 (Ayushi) joins the game
/// 3. Player 2 (Pankaj) joins the game
/// 4. Host starts the game and players participate
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Quiz Game Flow - Host and Join Tests', () {
    testWidgets(
      'Complete quiz hosting and joining flow with three users',
      (WidgetTester tester) async {
        // Initialize the app
        app.main();
        await IntegrationTestHelpers.waitForAppInit(tester);

        // Validate test preconditions
        final preconditionsValid =
            await IntegrationTestHelpers.validateTestPreconditions(tester);
        expect(
          preconditionsValid,
          isTrue,
          reason: 'Test preconditions not met',
        );

        String? gamePin;

        // PHASE 1: Host (Brijesh) creates and hosts a quiz
        debugPrint('Phase 1: Host creating and hosting quiz...');

        final hostCredentials = IntegrationTestHelpers.testUsers['host']!;
        final hostSignInSuccess = await IntegrationTestHelpers.signInUser(
          tester,
          hostCredentials['email']!,
          hostCredentials['password']!,
        );

        expect(hostSignInSuccess, isTrue, reason: 'Host failed to sign in');

        // Create test quiz
        final quizTitle = await IntegrationTestHelpers.createTestQuiz(
          tester,
          title:
              'Integration Test Quiz - ${DateTime.now().millisecondsSinceEpoch}',
        );
        expect(quizTitle, isNotNull, reason: 'Failed to create quiz');

        // Start hosting the quiz
        gamePin = await IntegrationTestHelpers.startHostingQuiz(tester);
        expect(gamePin, isNotNull, reason: 'Failed to generate game PIN');
        expect(gamePin!.length, equals(6), reason: 'Invalid PIN format');

        debugPrint('Generated game PIN: $gamePin');

        // Verify hosting screen displays correctly
        expect(
          IntegrationTestHelpers.verifyTextExists(tester, 'Players can join'),
          isTrue,
          reason: 'Host screen not displaying correctly',
        );

        // Verify initial player count is 0
        expect(
          IntegrationTestHelpers.verifyPlayerCount(tester, 0),
          isTrue,
          reason: 'Initial player count should be 0',
        );

        // Sign out host to allow players to join
        await IntegrationTestHelpers.signOutCurrentUser(tester);

        // PHASE 2: Player 1 (Ayushi) joins the game
        debugPrint('Phase 2: Player 1 (Ayushi) joining game...');

        final player1Credentials = IntegrationTestHelpers.testUsers['player1']!;
        final player1SignInSuccess = await IntegrationTestHelpers.signInUser(
          tester,
          player1Credentials['email']!,
          player1Credentials['password']!,
        );

        expect(
          player1SignInSuccess,
          isTrue,
          reason: 'Player 1 failed to sign in',
        );

        // Join game with PIN
        final player1JoinSuccess = await IntegrationTestHelpers.joinGameWithPin(
          tester,
          gamePin,
          player1Credentials['name']!,
        );

        expect(
          player1JoinSuccess,
          isTrue,
          reason: 'Player 1 failed to join game',
        );

        // Verify player is in waiting lobby
        expect(
          IntegrationTestHelpers.verifyTextExists(tester, 'Waiting'),
          isTrue,
          reason: 'Player 1 not in waiting lobby',
        );

        await IntegrationTestHelpers.signOutCurrentUser(tester);

        // PHASE 3: Player 2 (Pankaj) joins the game
        debugPrint('Phase 3: Player 2 (Pankaj) joining game...');

        final player2Credentials = IntegrationTestHelpers.testUsers['player2']!;
        final player2SignInSuccess = await IntegrationTestHelpers.signInUser(
          tester,
          player2Credentials['email']!,
          player2Credentials['password']!,
        );

        expect(
          player2SignInSuccess,
          isTrue,
          reason: 'Player 2 failed to sign in',
        );

        // Join game with PIN
        final player2JoinSuccess = await IntegrationTestHelpers.joinGameWithPin(
          tester,
          gamePin,
          player2Credentials['name']!,
        );

        expect(
          player2JoinSuccess,
          isTrue,
          reason: 'Player 2 failed to join game',
        );

        // Verify player is in waiting lobby
        expect(
          IntegrationTestHelpers.verifyTextExists(tester, 'Waiting'),
          isTrue,
          reason: 'Player 2 not in waiting lobby',
        );

        await IntegrationTestHelpers.signOutCurrentUser(tester);

        // PHASE 4: Host returns to start the game
        debugPrint('Phase 4: Host starting the game...');

        await IntegrationTestHelpers.signInUser(
          tester,
          hostCredentials['email']!,
          hostCredentials['password']!,
        );

        // Navigate back to hosting screen
        await IntegrationTestHelpers.navigateToRoute(tester, 'Host Game');

        // Verify both players have joined
        expect(
          IntegrationTestHelpers.verifyPlayerCount(tester, 2),
          isTrue,
          reason: 'Expected 2 players to be joined',
        );

        // Start the game
        final gameStartSuccess = await IntegrationTestHelpers.startGame(tester);
        expect(gameStartSuccess, isTrue, reason: 'Failed to start game');

        // Verify game is in progress
        expect(
          IntegrationTestHelpers.verifyTextExists(tester, 'Game in Progress'),
          isTrue,
          reason: 'Game should be in progress',
        );

        debugPrint('Test completed successfully!');
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );

    testWidgets('Host authentication and quiz creation flow', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelpers.waitForAppInit(tester);

      // Test host authentication
      final hostCredentials = IntegrationTestHelpers.testUsers['host']!;
      final signInSuccess = await IntegrationTestHelpers.signInUser(
        tester,
        hostCredentials['email']!,
        hostCredentials['password']!,
      );

      expect(signInSuccess, isTrue);

      // Test quiz creation
      final quizTitle = await IntegrationTestHelpers.createTestQuiz(
        tester,
        title: 'Host Test Quiz',
        question: 'What is the capital of France?',
        options: ['London', 'Paris', 'Berlin', 'Madrid'],
        correctAnswerIndex: 1,
      );

      expect(quizTitle, isNotNull);
      expect(quizTitle, equals('Host Test Quiz'));

      await IntegrationTestHelpers.signOutCurrentUser(tester);
    });

    testWidgets('Player authentication and join game flow', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelpers.waitForAppInit(tester);

      // Test Player 1 authentication
      final player1Credentials = IntegrationTestHelpers.testUsers['player1']!;
      final player1SignIn = await IntegrationTestHelpers.signInUser(
        tester,
        player1Credentials['email']!,
        player1Credentials['password']!,
      );

      expect(player1SignIn, isTrue);
      await IntegrationTestHelpers.signOutCurrentUser(tester);

      // Test Player 2 authentication
      final player2Credentials = IntegrationTestHelpers.testUsers['player2']!;
      final player2SignIn = await IntegrationTestHelpers.signInUser(
        tester,
        player2Credentials['email']!,
        player2Credentials['password']!,
      );

      expect(player2SignIn, isTrue);
      await IntegrationTestHelpers.signOutCurrentUser(tester);
    });

    testWidgets('Invalid PIN handling test', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelpers.waitForAppInit(tester);

      final playerCredentials = IntegrationTestHelpers.testUsers['player1']!;
      await IntegrationTestHelpers.signInUser(
        tester,
        playerCredentials['email']!,
        playerCredentials['password']!,
      );

      // Try to join with invalid PIN
      final joinSuccess = await IntegrationTestHelpers.joinGameWithPin(
        tester,
        '000000', // Invalid PIN
        'TestPlayer',
      );

      // Should fail to join with invalid PIN
      expect(joinSuccess, isFalse);

      // Verify error handling
      await IntegrationTestHelpers.handlePotentialError(tester);

      await IntegrationTestHelpers.signOutCurrentUser(tester);
    });

    testWidgets('Performance test - measure sign in time', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelpers.waitForAppInit(tester);

      final hostCredentials = IntegrationTestHelpers.testUsers['host']!;

      // Measure sign in performance
      final signInDuration = await IntegrationTestHelpers.measureOperationTime(
        () async {
          await IntegrationTestHelpers.signInUser(
            tester,
            hostCredentials['email']!,
            hostCredentials['password']!,
          );
        },
      );

      // Sign in should complete within reasonable time
      expect(
        signInDuration.inSeconds,
        lessThan(15),
        reason: 'Sign in took too long: ${signInDuration.inSeconds}s',
      );

      await IntegrationTestHelpers.signOutCurrentUser(tester);
    });

    testWidgets('Error recovery and stability test', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelpers.waitForAppInit(tester);

      // Test rapid navigation without crashes
      for (int i = 0; i < 3; i++) {
        await IntegrationTestHelpers.navigateToRoute(tester, 'Create Quiz');
        await tester.pageBack();
        await tester.pumpAndSettle();

        await IntegrationTestHelpers.navigateToRoute(tester, 'Join Game');
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // Verify app remains stable
      expect(tester.takeException(), isNull);
      expect(
        IntegrationTestHelpers.verifyWidgetExists(tester, MaterialApp),
        isTrue,
      );
    });

    // Cleanup after all tests
    tearDown(() async {
      // Reset any global state if needed
    });

    tearDownAll(() async {
      // Final cleanup
      debugPrint('All integration tests completed');
    });
  });
}
