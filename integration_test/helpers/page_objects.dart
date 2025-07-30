import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_data.dart';

/// Page Objects pattern for E2E testing
class PageObjects {
  final WidgetTester tester;

  PageObjects(this.tester);

  /// Authentication Page Objects
  Future<void> navigateToAuthPage() async {
    final authButton = find.text('Sign In');
    if (authButton.evaluate().isNotEmpty) {
      await tester.tap(authButton);
      await tester.pumpAndSettle();
    }
  }

  Future<void> verifyAuthPageVisible() async {
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byType(TextField), findsAtLeastNWidgets(2));
  }

  Future<void> authenticateUser(TestUser user) async {
    final emailField = find.byKey(const Key('email_field'));
    await tester.enterText(emailField, user.email);
    await tester.pumpAndSettle();

    final passwordField = find.byKey(const Key('password_field'));
    await tester.enterText(passwordField, 'testpassword123');
    await tester.pumpAndSettle();

    final signInButton = find.byKey(const Key('sign_in_button'));
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
  }

  Future<void> signOut() async {
    final profileButton = find.byKey(const Key('profile_button'));
    await tester.tap(profileButton);
    await tester.pumpAndSettle();

    final signOutButton = find.text('Sign Out');
    await tester.tap(signOutButton);
    await tester.pumpAndSettle();
  }

  /// Quiz Creation Page Objects
  Future<void> navigateToQuizCreation() async {
    final createQuizButton = find.byKey(const Key('create_quiz_button'));
    await tester.tap(createQuizButton);
    await tester.pumpAndSettle();
  }

  Future<void> createQuiz(TestQuiz quiz) async {
    final titleField = find.byKey(const Key('quiz_title_field'));
    await tester.enterText(titleField, quiz.title);
    await tester.pumpAndSettle();

    final descriptionField = find.byKey(const Key('quiz_description_field'));
    await tester.enterText(descriptionField, quiz.description);
    await tester.pumpAndSettle();

    final saveButton = find.byKey(const Key('save_quiz_button'));
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }

  /// Game Session Page Objects
  Future<String> startGameSession() async {
    final startGameButton = find.byKey(const Key('start_game_button'));
    await tester.tap(startGameButton);
    await tester.pumpAndSettle();

    final pinDisplay = find.byKey(const Key('game_pin_display'));
    expect(pinDisplay, findsOneWidget);

    final pinText = tester.widget<Text>(pinDisplay).data ?? '';
    return pinText;
  }

  Future<void> joinGameSession(String pin) async {
    final joinGameButton = find.byKey(const Key('join_game_button'));
    await tester.tap(joinGameButton);
    await tester.pumpAndSettle();

    final pinField = find.byKey(const Key('join_pin_field'));
    await tester.enterText(pinField, pin);
    await tester.pumpAndSettle();

    final joinButton = find.byKey(const Key('join_button'));
    await tester.tap(joinButton);
    await tester.pumpAndSettle();
  }

  /// Quiz Playing Page Objects
  Future<void> playQuiz(List<TestQuestion> questions) async {
    for (int i = 0; i < questions.length; i++) {
      await _answerQuestion(questions[i], i);
    }
  }

  Future<void> _answerQuestion(TestQuestion question, int index) async {
    final questionText = find.text(question.text);
    expect(questionText, findsOneWidget);

    await tester.pump(const Duration(seconds: 1));

    final optionButton = find.byKey(Key('answer_option_${index}_0'));
    await tester.tap(optionButton);
    await tester.pumpAndSettle();
  }

  /// Leaderboard Page Objects
  Future<void> verifyLeaderboard() async {
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.byKey(const Key('leaderboard_list')), findsOneWidget);
  }

  /// Navigation helpers
  Future<void> navigateBack() async {
    final backButton = find.byIcon(Icons.arrow_back);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }
  }

  /// Error handling page objects
  Future<void> verifyErrorHandling() async {
    final errorMessage = find.byKey(const Key('error_message'));
    expect(errorMessage, findsOneWidget);
  }

  Future<void> verifyOfflineMode() async {
    final offlineIndicator = find.byKey(const Key('offline_indicator'));
    expect(offlineIndicator, findsOneWidget);
  }

  Future<void> verifyAppRecovery() async {
    final homeButton = find.byKey(const Key('home_button'));
    expect(homeButton, findsOneWidget);
  }
}
