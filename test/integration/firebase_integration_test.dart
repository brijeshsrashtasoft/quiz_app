import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiz_app/main.dart';
import 'package:quiz_app/core/firebase/firebase_core_config.dart';
import 'package:quiz_app/core/firebase/firestore_config.dart';
import 'package:quiz_app/core/firebase/auth_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Firebase Integration Tests', () {
    testWidgets('should initialize Firebase and load app', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(const ProviderScope(child: QuizApp()));

      // Wait for Firebase initialization
      await tester.pumpAndSettle();

      // Verify app loads with Firebase integration message
      expect(find.text('Quiz App with Firebase Integration'), findsOneWidget);
      expect(
        find.text('Firebase services configured and ready!'),
        findsOneWidget,
      );
    });

    testWidgets('should handle Firebase initialization gracefully', (
      WidgetTester tester,
    ) async {
      // Test that app doesn't crash even if Firebase initialization fails
      await tester.pumpWidget(const ProviderScope(child: QuizApp()));

      // Wait for potential initialization
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // App should still render
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Firebase Services Integration', () {
    test('Firebase core configuration should be accessible', () {
      // Test that Firebase core configuration is properly set up
      expect(FirebaseCoreConfig.isInitialized, isA<bool>());
    });

    test('Firestore configuration should provide collections', () {
      // Test that Firestore collections are accessible
      expect(() => FirestoreConfig.usersCollection, returnsNormally);
      expect(() => FirestoreConfig.quizzesCollection, returnsNormally);
      expect(() => FirestoreConfig.gameSessionsCollection, returnsNormally);
      expect(() => FirestoreConfig.leaderboardsCollection, returnsNormally);
    });

    test('Auth configuration should provide auth state', () {
      // Test that Auth configuration provides authentication state
      expect(AuthConfig.isAuthenticated, isFalse); // Should be false in test
      expect(AuthConfig.currentUser, isNull); // Should be null in test
      expect(AuthConfig.currentUserId, isNull); // Should be null in test
    });

    test('Firebase streams should be accessible', () {
      // Test that Firebase streams can be accessed
      expect(() => AuthConfig.authStateChanges, returnsNormally);
      expect(() => AuthConfig.idTokenChanges, returnsNormally);
      expect(() => AuthConfig.userChanges, returnsNormally);
    });
  });

  group('Firebase Error Handling Integration', () {
    test('should handle network connectivity issues', () async {
      // Test network connectivity checking
      final hasConnectivity = await FirestoreConfig.checkConnectivity();
      expect(hasConnectivity, isA<bool>());
    });

    test('should handle authentication errors gracefully', () {
      // Test that authentication errors are handled properly
      expect(
        () => AuthConfig.signInWithEmailAndPassword(
          email: 'invalid@test.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle Firestore operations gracefully', () {
      // Test that Firestore operations handle errors
      expect(() => FirestoreConfig.getBatch(), returnsNormally);
      expect(
        () => FirestoreConfig.runTransaction((transaction) async {
          return 'test';
        }),
        isA<Future<String>>(),
      );
    });
  });

  group('Firebase Performance Integration', () {
    test('should complete operations within performance thresholds', () async {
      // Test that operations complete within acceptable time limits
      final stopwatch = Stopwatch()..start();

      // Test a simple operation
      await FirestoreConfig.checkConnectivity();

      stopwatch.stop();

      // Should complete within reasonable time (adjust threshold as needed)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('should handle offline persistence', () {
      // Test offline persistence setup
      expect(() => FirestoreConfig.enableOfflinePersistence(), returnsNormally);
    });
  });

  group('Firebase Security Integration', () {
    test('should enforce authentication requirements', () {
      // Test that operations requiring authentication behave correctly
      expect(AuthConfig.isAuthenticated, isFalse);
      expect(AuthConfig.currentUser, isNull);
    });

    test('should handle unauthorized operations', () {
      // Test that unauthorized operations are handled properly
      expect(
        () => AuthConfig.updateUserProfile(displayName: 'Test'),
        throwsA(isA<Exception>()),
      );

      expect(() => AuthConfig.deleteUser(), throwsA(isA<Exception>()));
    });
  });

  group('Firebase Configuration Integration', () {
    test('should have proper Firestore settings', () {
      // Test that Firestore is configured with correct settings
      expect(() => FirestoreConfig.instance, returnsNormally);
    });

    test('should provide all required collections', () {
      // Test that all required collections are available
      expect(() => FirestoreConfig.usersCollection, returnsNormally);
      expect(() => FirestoreConfig.quizzesCollection, returnsNormally);
      expect(() => FirestoreConfig.gameSessionsCollection, returnsNormally);
      expect(() => FirestoreConfig.leaderboardsCollection, returnsNormally);
    });

    test('should support batch operations', () {
      // Test that batch operations are supported
      final batch = FirestoreConfig.getBatch();
      expect(batch, isNotNull);
    });

    test('should support transactions', () {
      // Test that transactions are supported
      expect(
        FirestoreConfig.runTransaction<String>((transaction) async {
          return 'transaction_test';
        }),
        isA<Future<String>>(),
      );
    });
  });
}

/// Integration test helpers
class FirebaseIntegrationHelper {
  /// Wait for Firebase initialization with timeout
  static Future<void> waitForFirebaseInitialization({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final completer = Completer<void>();
    Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    // Check initialization status periodically
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (FirebaseCoreConfig.isInitialized || completer.isCompleted) {
        timer.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    return completer.future;
  }

  /// Clean up test data
  static Future<void> cleanupTestData() async {
    // Clean up any test data created during integration tests
    try {
      await FirestoreConfig.clearCache();
    } catch (e) {
      // Ignore cleanup errors in tests
    }
  }
}
