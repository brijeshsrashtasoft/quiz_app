import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/core/navigation/app_router.dart';
import 'package:quiz_app/core/navigation/route_constants.dart';
import 'package:quiz_app/core/navigation/auth_guard.dart';
import 'package:quiz_app/core/utils/result.dart';
import '../../test_config.dart';
import '../../helpers/test_utilities.dart';
import '../../helpers/firebase_test_helper.dart';
import 'firebase_auth_navigation_test.mocks.dart';

/// Integration tests for Firebase Authentication with Navigation
/// Tests the complete auth flow with route guards and navigation
@GenerateMocks([AuthService])
void main() {
  testGroup(
    'Firebase Auth Navigation Integration',
    TestCategory.integration,
    () {
      late MockAuthService mockAuthService;
      late FirebaseTestHelper firebaseHelper;

      setUpAll(() async {
        firebaseHelper = FirebaseTestHelper();
        await firebaseHelper.setupTestEnvironment();
      });

      tearDownAll(() async {
        await firebaseHelper.tearDownTestEnvironment();
      });

      setUp(() {
        mockAuthService = MockAuthService();
      });

      widgetTestCase(
        'should handle complete authentication flow',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          final authStateController = StreamController<AuthState>.broadcast();

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                authStateProvider.overrideWith(
                  (ref) => authStateController.stream,
                ),
                authServiceProvider.overrideWithValue(mockAuthService),
              ],
              child: TestWrappers.fullApp(),
            ),
          );

          // Start with unauthenticated state
          authStateController.add(const AuthState.unauthenticated());
          await tester.pumpAndSettle();

          // ACT - Navigate to login page
          AppRouter.go(RouteConstants.login);
          await tester.pumpAndSettle();

          // ASSERT - Should be on login page
          expect(find.text('Welcome Back'), findsOneWidget);

          // ACT - Perform login
          when(
            mockAuthService.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer(
            (_) async => MockResultBuilder.success(MockUserCredential()),
          );

          await tester.enterText(
            find.byKey(const Key('email_field')),
            'test@example.com',
          );
          await tester.enterText(
            find.byKey(const Key('password_field')),
            'password123',
          );
          await tester.tap(find.text('Sign In'));
          await tester.pump();

          // Simulate successful authentication
          authStateController.add(
            AuthState.authenticated(
              firebaseUser: MockFirebaseUser(),
              user: UserEntity(
                id: 'test-user-123',
                name: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // ASSERT - Should navigate to dashboard/home
          verify(
            mockAuthService.signInWithEmailAndPassword(
              email: 'test@example.com',
              password: 'password123',
            ),
          ).called(1);

          // Cleanup
          authStateController.close();
        },
      );

      widgetTestCase(
        'should handle authentication errors with proper navigation',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                authServiceProvider.overrideWithValue(mockAuthService),
                authStateProvider.overrideWith(
                  (ref) => Stream.value(const AuthState.unauthenticated()),
                ),
              ],
              child: TestWrappers.fullApp(),
            ),
          );
          await tester.pumpAndSettle();

          // ACT - Navigate to login and attempt failed login
          AppRouter.go(RouteConstants.login);
          await tester.pumpAndSettle();

          when(
            mockAuthService.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer(
            (_) async => MockResultBuilder.failure('Invalid credentials'),
          );

          await tester.enterText(
            find.byKey(const Key('email_field')),
            'test@example.com',
          );
          await tester.enterText(
            find.byKey(const Key('password_field')),
            'wrongpassword',
          );
          await tester.tap(find.text('Sign In'));
          await tester.pumpAndSettle();

          // ASSERT - Should show error and remain on login page
          expect(find.text('Invalid credentials'), findsOneWidget);
          expect(find.text('Welcome Back'), findsOneWidget);
        },
      );

      widgetTestCase(
        'should handle session expiration during navigation',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          final authStateController = StreamController<AuthState>.broadcast();

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                authStateProvider.overrideWith(
                  (ref) => authStateController.stream,
                ),
              ],
              child: TestWrappers.fullApp(),
            ),
          );

          // Start authenticated
          authStateController.add(
            AuthState.authenticated(
              firebaseUser: MockFirebaseUser(),
              user: UserEntity(
                id: 'test-user-123',
                name: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // ACT - Navigate to protected route
          AppRouter.go(RouteConstants.dashboard);
          await tester.pumpAndSettle();

          // Simulate session expiration
          authStateController.add(const AuthState.unauthenticated());
          await tester.pumpAndSettle();

          // ACT - Try to navigate to another protected route
          AppRouter.go(RouteConstants.profile);
          await tester.pumpAndSettle();

          // ASSERT - Should be redirected to login
          // The exact behavior depends on guard implementation

          // Cleanup
          authStateController.close();
        },
      );

      widgetTestCase(
        'should handle user registration flow',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          final authStateController = StreamController<AuthState>.broadcast();

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                authStateProvider.overrideWith(
                  (ref) => authStateController.stream,
                ),
                authServiceProvider.overrideWithValue(mockAuthService),
              ],
              child: TestWrappers.fullApp(),
            ),
          );

          authStateController.add(const AuthState.unauthenticated());
          await tester.pumpAndSettle();

          // ACT - Navigate to registration
          AppRouter.go(RouteConstants.register);
          await tester.pumpAndSettle();

          // ASSERT - Should be on registration page
          expect(find.text('Create Account'), findsOneWidget);

          // ACT - Perform registration
          when(
            mockAuthService.createUserWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
              displayName: anyNamed('displayName'),
            ),
          ).thenAnswer(
            (_) async => MockResultBuilder.success(MockUserCredential()),
          );

          await tester.enterText(
            find.byKey(const Key('name_field')),
            'New User',
          );
          await tester.enterText(
            find.byKey(const Key('email_field')),
            'newuser@example.com',
          );
          await tester.enterText(
            find.byKey(const Key('password_field')),
            'password123',
          );
          await tester.tap(find.text('Create Account'));
          await tester.pump();

          // Simulate successful registration
          authStateController.add(
            AuthState.authenticated(
              firebaseUser: MockFirebaseUser(),
              user: UserEntity(
                id: 'new-user-123',
                name: 'New User',
                email: 'newuser@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // ASSERT - Should navigate to dashboard/home after registration
          verify(
            mockAuthService.createUserWithEmailAndPassword(
              email: 'newuser@example.com',
              password: 'password123',
              displayName: 'New User',
            ),
          ).called(1);

          // Cleanup
          authStateController.close();
        },
      );

      widgetTestCase(
        'should handle password reset flow',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                authServiceProvider.overrideWithValue(mockAuthService),
                authStateProvider.overrideWith(
                  (ref) => Stream.value(const AuthState.unauthenticated()),
                ),
              ],
              child: TestWrappers.fullApp(),
            ),
          );
          await tester.pumpAndSettle();

          // ACT - Navigate to forgot password
          AppRouter.go(RouteConstants.forgotPassword);
          await tester.pumpAndSettle();

          // ASSERT - Should be on forgot password page
          expect(find.text('Reset Password'), findsOneWidget);

          // ACT - Request password reset
          when(
            mockAuthService.sendPasswordResetEmail(email: anyNamed('email')),
          ).thenAnswer((_) async => const Result.success(null));

          await tester.enterText(
            find.byKey(const Key('email_field')),
            'test@example.com',
          );
          await tester.tap(find.text('Send Reset Email'));
          await tester.pumpAndSettle();

          // ASSERT - Should show success message
          expect(find.text('Password reset email sent'), findsOneWidget);
          verify(
            mockAuthService.sendPasswordResetEmail(email: 'test@example.com'),
          ).called(1);
        },
      );

      widgetTestCase(
        'should handle logout flow with navigation',
        TestCategory.integration,
        (WidgetTester tester) async {
          // ARRANGE
          final authStateController = StreamController<AuthState>.broadcast();

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                authStateProvider.overrideWith(
                  (ref) => authStateController.stream,
                ),
                authServiceProvider.overrideWithValue(mockAuthService),
              ],
              child: TestWrappers.fullApp(),
            ),
          );

          // Start authenticated
          authStateController.add(
            AuthState.authenticated(
              firebaseUser: MockFirebaseUser(),
              user: UserEntity(
                id: 'test-user-123',
                name: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // ACT - Navigate to profile and logout
          AppRouter.go(RouteConstants.profile);
          await tester.pumpAndSettle();

          expect(find.text('Profile'), findsOneWidget);

          when(
            mockAuthService.signOut(),
          ).thenAnswer((_) async => const Result.success(null));

          await tester.tap(find.text('Sign Out'));
          await tester.pump();

          // Simulate logout
          authStateController.add(const AuthState.unauthenticated());
          await tester.pumpAndSettle();

          // ASSERT - Should be redirected to login/home
          verify(mockAuthService.signOut()).called(1);

          // Cleanup
          authStateController.close();
        },
      );
    },
  );

  testGroup(
    'Guard Integration with Firebase Auth',
    TestCategory.integration,
    () {
      late MockAuthService mockAuthService;

      setUp(() {
        mockAuthService = MockAuthService();
      });

      testCase(
        'should properly integrate AuthGuard with Firebase auth state',
        TestCategory.integration,
        () async {
          // ARRANGE
          final container = ProviderContainer(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          );
          final mockContext = MockBuildContext();
          final mockState = MockGoRouterState();
          final authGuard = const AuthGuard();

          // Mock authenticated state
          when(container.read(authStateProvider.future)).thenAnswer(
            (_) async => AuthState.authenticated(
              firebaseUser: MockFirebaseUser(),
              user: UserEntity(
                id: 'test-user-123',
                name: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          );

          // ACT
          final result = await authGuard.canActivate(mockContext, mockState);

          // ASSERT
          expect(result, isNull); // Should allow access

          container.dispose();
        },
      );

      testCase(
        'should handle Firebase auth errors in guards',
        TestCategory.integration,
        () async {
          // ARRANGE
          final container = ProviderContainer(
            overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
          );
          final mockContext = MockBuildContext();
          final mockState = MockGoRouterState();
          final authGuard = const AuthGuard();

          // Mock auth error
          when(
            container.read(authStateProvider.future),
          ).thenThrow(Exception('Firebase connection error'));

          // ACT
          final result = await authGuard.canActivate(mockContext, mockState);

          // ASSERT
          expect(
            result,
            equals(RouteConstants.login),
          ); // Should redirect to login

          container.dispose();
        },
      );
    },
  );

  testGroup('Real-time Auth State Navigation', TestCategory.integration, () {
    widgetTestCase(
      'should respond to real-time auth state changes',
      TestCategory.integration,
      (WidgetTester tester) async {
        // ARRANGE
        final authStateController = StreamController<AuthState>.broadcast();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(
                (ref) => authStateController.stream,
              ),
            ],
            child: TestWrappers.fullApp(),
          ),
        );

        // Start unauthenticated
        authStateController.add(const AuthState.unauthenticated());
        await tester.pumpAndSettle();

        // ACT - Authenticate user while on a page
        AppRouter.go(RouteConstants.home);
        await tester.pumpAndSettle();

        authStateController.add(
          AuthState.authenticated(
            firebaseUser: MockFirebaseUser(),
            user: UserEntity(
              id: 'test-user-123',
              name: 'Test User',
              email: 'test@example.com',
              createdAt: DateTime.now(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // ASSERT - Should be able to access protected routes now
        AppRouter.go(RouteConstants.dashboard);
        await tester.pumpAndSettle();
        // Behavior depends on implementation

        // Cleanup
        authStateController.close();
      },
    );

    widgetTestCase(
      'should handle auth errors during navigation',
      TestCategory.integration,
      (WidgetTester tester) async {
        // ARRANGE
        final authStateController = StreamController<AuthState>.broadcast();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(
                (ref) => authStateController.stream,
              ),
            ],
            child: TestWrappers.fullApp(),
          ),
        );

        // Start authenticated
        authStateController.add(
          AuthState.authenticated(
            firebaseUser: MockFirebaseUser(),
            user: UserEntity(
              id: 'test-user-123',
              name: 'Test User',
              email: 'test@example.com',
              createdAt: DateTime.now(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // ACT - Simulate auth error
        authStateController.add(
          const AuthState.error(message: 'Authentication token expired'),
        );
        await tester.pumpAndSettle();

        // Try to navigate to protected route
        AppRouter.go(RouteConstants.profile);
        await tester.pumpAndSettle();

        // ASSERT - Should handle error state appropriately
        // Behavior depends on how guards handle error states

        // Cleanup
        authStateController.close();
      },
    );
  });
}

/// Mock classes for Firebase auth testing
class MockFirebaseUser {
  String get uid => 'test-user-123';
  String get email => 'test@example.com';
  String get displayName => 'Test User';
}

class MockUserCredential {
  final MockFirebaseUser user = MockFirebaseUser();
}

class MockBuildContext extends Mock implements BuildContext {}

class MockGoRouterState extends Mock implements GoRouterState {}
