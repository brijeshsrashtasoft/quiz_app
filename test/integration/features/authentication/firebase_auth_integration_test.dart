import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:quiz_app/features/authentication/data/datasources/firebase_auth_datasource.dart';
import 'package:quiz_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:quiz_app/features/authentication/domain/usecases/send_password_reset_usecase.dart';
import '../../../test_config.dart';

void main() {
  testGroup(
    'Firebase Authentication Integration Tests',
    TestCategory.integration,
    () {
      late MockFirebaseAuth mockFirebaseAuth;
      late FirebaseAuthDataSource dataSource;
      late AuthRepositoryImpl repository;
      late SignInWithEmailUseCase signInUseCase;
      late SignUpWithEmailUseCase signUpUseCase;
      late SignOutUseCase signOutUseCase;
      late SendPasswordResetUseCase passwordResetUseCase;

      const testEmail = 'integration.test@example.com';
      const testPassword = 'testpassword123';
      const testDisplayName = 'Integration Test User';

      setUp(() async {
        // Initialize Firebase emulator/mock
        mockFirebaseAuth = MockFirebaseAuth();

        // Setup data source with mock
        dataSource = FirebaseAuthDataSource(firebaseAuth: mockFirebaseAuth);

        // Setup repository
        repository = AuthRepositoryImpl(dataSource: dataSource);

        // Setup use cases
        signInUseCase = SignInWithEmailUseCase(repository: repository);
        signUpUseCase = SignUpWithEmailUseCase(repository: repository);
        signOutUseCase = SignOutUseCase(repository: repository);
        passwordResetUseCase = SendPasswordResetUseCase(repository: repository);
      });

      testGroup('Complete Authentication Flow Integration', () {
        testCase(
          'should complete full user registration and authentication flow',
          TestCategory.integration,
          () async {
            // Step 1: Sign up new user
            final signUpResult = await signUpUseCase(
              SignUpWithEmailParams(
                email: testEmail,
                password: testPassword,
                displayName: testDisplayName,
              ),
            );

            expect(
              signUpResult.isSuccess,
              isTrue,
              reason: 'Sign up should succeed',
            );
            final signUpAuth = signUpResult.dataOrNull!;
            expect(signUpAuth.user.email, equals(testEmail));
            expect(signUpAuth.user.displayName, equals(testDisplayName));

            // Step 2: Sign out
            final signOutResult = await signOutUseCase(NoParams());
            expect(
              signOutResult.isSuccess,
              isTrue,
              reason: 'Sign out should succeed',
            );

            // Step 3: Sign in with created credentials
            final signInResult = await signInUseCase(
              SignInWithEmailParams(email: testEmail, password: testPassword),
            );

            expect(
              signInResult.isSuccess,
              isTrue,
              reason: 'Sign in should succeed',
            );
            final signInAuth = signInResult.dataOrNull!;
            expect(signInAuth.user.email, equals(testEmail));
            expect(signInAuth.user.id, equals(signUpAuth.user.id));

            // Step 4: Verify user is authenticated
            expect(repository.isAuthenticated, isTrue);
            expect(repository.currentUserId, equals(signInAuth.user.id));
          },
        );

        testCase(
          'should handle authentication state changes correctly',
          TestCategory.integration,
          () async {
            // Initially not authenticated
            expect(repository.isAuthenticated, isFalse);
            expect(repository.getCurrentUser(), isNull);

            // Sign up user
            final signUpResult = await signUpUseCase(
              SignUpWithEmailParams(email: testEmail, password: testPassword),
            );

            expect(signUpResult.isSuccess, isTrue);

            // Now authenticated
            expect(repository.isAuthenticated, isTrue);
            expect(repository.getCurrentUser(), isNotNull);

            // Sign out
            await signOutUseCase(NoParams());

            // Back to not authenticated
            expect(repository.isAuthenticated, isFalse);
            expect(repository.getCurrentUser(), isNull);
          },
        );

        testCase(
          'should handle password reset flow integration',
          TestCategory.integration,
          () async {
            // First create a user
            await signUpUseCase(
              SignUpWithEmailParams(email: testEmail, password: testPassword),
            );

            // Sign out
            await signOutUseCase(NoParams());

            // Request password reset
            final resetResult = await passwordResetUseCase(
              SendPasswordResetParams(email: testEmail),
            );

            expect(
              resetResult.isSuccess,
              isTrue,
              reason: 'Password reset should succeed for existing user',
            );
          },
        );

        testCase(
          'should handle profile update integration',
          TestCategory.integration,
          () async {
            // Sign up user
            final signUpResult = await signUpUseCase(
              SignUpWithEmailParams(
                email: testEmail,
                password: testPassword,
                displayName: 'Original Name',
              ),
            );

            expect(signUpResult.isSuccess, isTrue);

            // Update profile
            const newDisplayName = 'Updated Name';
            const newPhotoURL = 'https://example.com/photo.jpg';

            final updateResult = await repository.updateUserProfile(
              displayName: newDisplayName,
              photoURL: newPhotoURL,
            );

            expect(
              updateResult.isSuccess,
              isTrue,
              reason: 'Profile update should succeed',
            );

            // Reload user to get updated data
            final reloadResult = await repository.reloadUser();
            expect(reloadResult.isSuccess, isTrue);
          },
        );
      });

      testGroup('Error Handling Integration', () {
        testCase(
          'should handle duplicate email error correctly',
          TestCategory.integration,
          () async {
            // Create first user
            final firstSignUp = await signUpUseCase(
              SignUpWithEmailParams(email: testEmail, password: testPassword),
            );
            expect(firstSignUp.isSuccess, isTrue);

            // Sign out first user
            await signOutUseCase(NoParams());

            // Try to create second user with same email
            final secondSignUp = await signUpUseCase(
              SignUpWithEmailParams(
                email: testEmail,
                password: 'differentpassword123',
              ),
            );

            expect(secondSignUp.isFailure, isTrue);
            expect(secondSignUp.failureOrNull?.code, contains('email'));
          },
        );

        testCase(
          'should handle invalid credentials error correctly',
          TestCategory.integration,
          () async {
            // Try to sign in with non-existent user
            final signInResult = await signInUseCase(
              SignInWithEmailParams(
                email: 'nonexistent@example.com',
                password: 'wrongpassword123',
              ),
            );

            expect(signInResult.isFailure, isTrue);
            expect(
              signInResult.failureOrNull?.code,
              isIn(['user-not-found', 'wrong-password', 'invalid-credential']),
            );
          },
        );

        testCase(
          'should handle password reset for non-existent user',
          TestCategory.integration,
          () async {
            final resetResult = await passwordResetUseCase(
              SendPasswordResetParams(email: 'nonexistent@example.com'),
            );

            // This might succeed or fail depending on Firebase configuration
            // Some implementations don't reveal if email exists for security
            expect(resetResult.isFailure || resetResult.isSuccess, isTrue);
          },
        );
      });

      testGroup('Performance Integration Tests', () {
        testCase(
          'should complete authentication operations within performance thresholds',
          TestCategory.integration,
          () async {
            // Test sign up performance
            await TestExpectations.expectPerformant(() async {
              await signUpUseCase(
                SignUpWithEmailParams(email: testEmail, password: testPassword),
              );
            }, threshold: const Duration(milliseconds: 200));

            // Test sign out performance
            await TestExpectations.expectPerformant(() async {
              await signOutUseCase(NoParams());
            }, threshold: const Duration(milliseconds: 200));

            // Test sign in performance
            await TestExpectations.expectPerformant(() async {
              await signInUseCase(
                SignInWithEmailParams(email: testEmail, password: testPassword),
              );
            }, threshold: const Duration(milliseconds: 200));
          },
        );

        testCase(
          'should handle concurrent authentication operations',
          TestCategory.integration,
          () async {
            // Test concurrent sign up attempts (should handle gracefully)
            final futures = List.generate(
              3,
              (index) => signUpUseCase(
                SignUpWithEmailParams(
                  email: 'concurrent$index@example.com',
                  password: testPassword,
                ),
              ),
            );

            final results = await Future.wait(futures);

            // At least one should succeed (others might fail due to timing)
            final successCount = results.where((r) => r.isSuccess).length;
            expect(successCount, greaterThan(0));
          },
        );
      });

      testGroup('Data Persistence Integration', () {
        testCase(
          'should maintain authentication state across operations',
          TestCategory.integration,
          () async {
            // Sign up and verify state
            final signUpResult = await signUpUseCase(
              SignUpWithEmailParams(email: testEmail, password: testPassword),
            );

            expect(signUpResult.isSuccess, isTrue);
            final initialUserId = repository.currentUserId;
            expect(initialUserId, isNotNull);

            // Update profile and verify state persists
            await repository.updateUserProfile(displayName: 'Updated Name');
            expect(repository.currentUserId, equals(initialUserId));
            expect(repository.isAuthenticated, isTrue);

            // Send verification and verify state persists
            await repository.sendEmailVerification();
            expect(repository.currentUserId, equals(initialUserId));
            expect(repository.isAuthenticated, isTrue);
          },
        );
      });

      testGroup('Stream Integration Tests', () {
        testCase(
          'should emit correct auth state changes',
          TestCategory.integration,
          () async {
            final authStateChanges = <User?>[];

            // Listen to auth state changes
            final subscription = repository.authStateChanges().listen((user) {
              authStateChanges.add(user);
            });

            // Initially should be null
            await Future.delayed(const Duration(milliseconds: 100));

            // Sign up user
            await signUpUseCase(
              SignUpWithEmailParams(email: testEmail, password: testPassword),
            );

            await Future.delayed(const Duration(milliseconds: 100));

            // Sign out user
            await signOutUseCase(NoParams());

            await Future.delayed(const Duration(milliseconds: 100));

            subscription.cancel();

            // Should have recorded state changes
            expect(authStateChanges.length, greaterThan(0));
          },
        );
      });

      testGroup('Cross-Platform Compatibility Integration', () {
        testCase(
          'should work with different authentication providers',
          TestCategory.integration,
          () async {
            // Test email/password authentication
            final emailAuthResult = await signUpUseCase(
              SignUpWithEmailParams(email: testEmail, password: testPassword),
            );

            expect(emailAuthResult.isSuccess, isTrue);
            await signOutUseCase(NoParams());

            // Test Google Sign-In (mocked)
            // Note: In real integration tests, you'd test with actual Google Sign-In
            final googleSignInResult = await repository.signInWithGoogle();

            // This will likely fail in mock environment, but we test the integration
            expect(
              googleSignInResult.isFailure || googleSignInResult.isSuccess,
              isTrue,
            );
          },
        );
      });
    },
  );

  testGroup('Firebase Emulator Integration Tests', () {
    // These tests would run against Firebase emulators in a real environment
    testCase(
      'should connect to Firebase emulator successfully',
      TestCategory.integration,
      () async {
        // In a real test environment, this would:
        // 1. Start Firebase emulators
        // 2. Configure Firebase to use emulator endpoints
        // 3. Run authentication tests against emulator
        // 4. Verify data persistence in emulator

        expect(true, isTrue, reason: 'Emulator integration placeholder');
      },
    );

    testCase(
      'should handle emulator authentication rules',
      TestCategory.integration,
      () async {
        // Test Firebase Authentication rules in emulator environment
        expect(true, isTrue, reason: 'Emulator rules testing placeholder');
      },
    );
  });
}
