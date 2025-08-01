import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_navigation_providers.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:quiz_app/features/authentication/domain/entities/auth_state.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/core/navigation/route_constants.dart';
import 'package:quiz_app/core/navigation/app_router.dart';

// Generate mocks
@GenerateMocks([GoRouter])
import 'navigation_integration_test.mocks.dart';

void main() {
  group(
    'Authentication Navigation Integration Tests - US-001 Registration Flow',
    () {
      late ProviderContainer container;
      late MockGoRouter mockRouter;

      setUp(() {
        mockRouter = MockGoRouter();
        container = ProviderContainer();
      });

      tearDown(() {
        container.dispose();
      });

      group('Registration Navigation Flow', () {
        test('should initialize with login step by default', () {
          // Act
          final navigationState = container.read(authNavigationProvider);

          // Assert
          expect(navigationState.currentStep, equals(AuthFlowStep.login));
          expect(navigationState.isOnLogin, isTrue);
          expect(navigationState.isOnRegister, isFalse);
          expect(navigationState.showBackButton, isFalse);
          expect(navigationState.isNavigating, isFalse);
        });

        test('should navigate to register from login', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Act
          navigationNotifier.navigateToRegister();

          // Assert
          final state = container.read(authNavigationProvider);
          expect(state.currentStep, equals(AuthFlowStep.register));
          expect(state.isOnRegister, isTrue);
          expect(state.isOnLogin, isFalse);
          expect(state.showBackButton, isTrue);
          expect(state.previousRoute, equals(RouteConstants.login));
        });

        test('should navigate back to login from register', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // First navigate to register
          navigationNotifier.navigateToRegister();

          // Act
          navigationNotifier.navigateToLogin(
            fromRoute: RouteConstants.register,
          );

          // Assert
          final state = container.read(authNavigationProvider);
          expect(state.currentStep, equals(AuthFlowStep.login));
          expect(state.isOnLogin, isTrue);
          expect(state.isOnRegister, isFalse);
          expect(state.previousRoute, equals(RouteConstants.register));
        });

        test('should get correct page titles for each step', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Test login step
          expect(
            container.read(authNavigationProvider).pageTitle,
            equals('Welcome Back'),
          );

          // Test register step
          navigationNotifier.navigateToRegister();
          expect(
            container.read(authNavigationProvider).pageTitle,
            equals('Create Account'),
          );

          // Test forgot password step
          navigationNotifier.navigateToForgotPassword();
          expect(
            container.read(authNavigationProvider).pageTitle,
            equals('Reset Password'),
          );
        });

        test('should get correct page subtitles for each step', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Test login step
          expect(
            container.read(authNavigationProvider).pageSubtitle,
            equals('Sign in to continue your quiz journey'),
          );

          // Test register step
          navigationNotifier.navigateToRegister();
          expect(
            container.read(authNavigationProvider).pageSubtitle,
            equals('Join thousands of quiz enthusiasts'),
          );

          // Test forgot password step
          navigationNotifier.navigateToForgotPassword();
          expect(
            container.read(authNavigationProvider).pageSubtitle,
            equals('Enter your email to reset your password'),
          );
        });

        test('should get correct route paths for each step', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Test login step
          expect(
            container.read(authNavigationProvider).currentRoutePath,
            equals(RouteConstants.login),
          );

          // Test register step
          navigationNotifier.navigateToRegister();
          expect(
            container.read(authNavigationProvider).currentRoutePath,
            equals(RouteConstants.register),
          );

          // Test forgot password step
          navigationNotifier.navigateToForgotPassword();
          expect(
            container.read(authNavigationProvider).currentRoutePath,
            equals(RouteConstants.forgotPassword),
          );
        });

        test('should use helper navigation methods correctly', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Test login to register helper
          navigationNotifier.goToRegisterFromLogin();
          expect(
            container.read(authNavigationProvider).currentStep,
            equals(AuthFlowStep.register),
          );
          expect(
            container.read(authNavigationProvider).previousRoute,
            equals(RouteConstants.login),
          );

          // Test register to login helper
          navigationNotifier.goToLoginFromRegister();
          expect(
            container.read(authNavigationProvider).currentStep,
            equals(AuthFlowStep.login),
          );
          expect(
            container.read(authNavigationProvider).previousRoute,
            equals(RouteConstants.register),
          );

          // Test login to forgot password helper
          navigationNotifier.goToForgotPasswordFromLogin();
          expect(
            container.read(authNavigationProvider).currentStep,
            equals(AuthFlowStep.forgotPassword),
          );
          expect(
            container.read(authNavigationProvider).previousRoute,
            equals(RouteConstants.login),
          );
        });

        test('should set target route for post-authentication navigation', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );
          const targetRoute = '/quiz/123';
          final params = {'quizId': '123'};

          // Act
          navigationNotifier.setTargetRoute(targetRoute, params: params);

          // Assert
          final state = container.read(authNavigationProvider);
          expect(state.targetRoute, equals(targetRoute));
          expect(state.navigationParams, equals(params));
        });
      });

      group('Authentication State Integration', () {
        test('should handle successful authentication navigation', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );
          navigationNotifier.setTargetRoute('/dashboard');

          // Act - Simulate successful authentication
          navigationNotifier.navigateToMainApp();

          // Assert
          final state = container.read(authNavigationProvider);
          expect(state.isNavigating, isFalse);
        });

        test('should handle logout navigation', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Act
          navigationNotifier.handleLogout();

          // Assert
          final state = container.read(authNavigationProvider);
          expect(state.currentStep, equals(AuthFlowStep.login));
          expect(state.previousRoute, isNull);
          expect(state.targetRoute, isNull);
          expect(state.navigationParams, isNull);
          expect(state.showBackButton, isFalse);
        });

        test('should reset navigation state correctly', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Set up some state
          navigationNotifier.navigateToRegister();
          navigationNotifier.setTargetRoute('/dashboard');

          // Act
          navigationNotifier.resetNavigationState();

          // Assert
          final state = container.read(authNavigationProvider);
          expect(state.currentStep, equals(AuthFlowStep.login));
          expect(state.isNavigating, isFalse);
          expect(state.showBackButton, isFalse);
          expect(state.previousRoute, isNull);
          expect(state.targetRoute, isNull);
          expect(state.navigationParams, isNull);
        });

        test('should update current step without navigation', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Act
          navigationNotifier.updateCurrentStep(AuthFlowStep.register);

          // Assert
          final state = container.read(authNavigationProvider);
          expect(state.currentStep, equals(AuthFlowStep.register));
          expect(state.isOnRegister, isTrue);
        });
      });

      group('Auth Flow Controller Tests', () {
        test('should initialize with correct default state', () {
          // Act
          final flowState = container.read(authFlowControllerProvider);

          // Assert
          expect(
            flowState.isInitialized,
            isTrue,
          ); // Controller initializes immediately
          expect(
            flowState.isLoading,
            isFalse,
          ); // Controller finishes loading after initialization
          expect(flowState.status, equals(AuthenticationStatus.unknown));
          expect(flowState.user, isNull);
          expect(flowState.errorMessage, isNull);
          expect(flowState.isAuthenticated, isFalse);
          expect(flowState.isUnauthenticated, isFalse);
          expect(flowState.isUnknown, isTrue);
          expect(flowState.hasError, isFalse);
        });

        test('should clear error state', () {
          // Arrange
          final flowController = container.read(
            authFlowControllerProvider.notifier,
          );

          // Act
          flowController.clearError();

          // Assert
          final state = container.read(authFlowControllerProvider);
          expect(state.errorMessage, isNull);
          expect(state.hasError, isFalse);
        });

        // Note: refreshAuthState test skipped due to Firebase initialization requirement in test environment
      });

      group('Registration Flow End-to-End Navigation', () {
        test('should complete full registration navigation flow', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Act & Assert - Step 1: Start at login
          expect(container.read(authNavigationProvider).isOnLogin, isTrue);

          // Act & Assert - Step 2: Navigate to register
          navigationNotifier.navigateToRegister();
          expect(container.read(authNavigationProvider).isOnRegister, isTrue);
          expect(container.read(authNavigationProvider).showBackButton, isTrue);

          // Act & Assert - Step 3: Set target for post-registration
          navigationNotifier.setTargetRoute('/onboarding');
          expect(
            container.read(authNavigationProvider).targetRoute,
            equals('/onboarding'),
          );

          // Act & Assert - Step 4: Simulate successful registration
          navigationNotifier.navigateToMainApp();
          expect(container.read(authNavigationProvider).isNavigating, isFalse);
        });

        test('should handle registration cancellation flow', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Start registration flow
          navigationNotifier.navigateToRegister();
          expect(container.read(authNavigationProvider).isOnRegister, isTrue);

          // Act - Cancel registration and go back
          navigationNotifier.navigateBack();

          // Assert - Should be back at login (or previous route)
          final state = container.read(authNavigationProvider);
          expect(state.isNavigating, isFalse);
        });

        test('should handle registration error flow', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Start registration flow
          navigationNotifier.navigateToRegister();

          // Act & Assert - Should stay on register page for error handling
          expect(container.read(authNavigationProvider).isOnRegister, isTrue);

          // Errors should be handled by form validation, not navigation
          expect(
            container.read(authNavigationProvider).currentStep,
            equals(AuthFlowStep.register),
          );
        });

        test('should handle complex navigation scenarios', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Scenario: Login -> Register -> Forgot Password -> Back to Login
          // Step 1: Go to register
          navigationNotifier.navigateToRegister();
          expect(container.read(authNavigationProvider).isOnRegister, isTrue);

          // Step 2: Go to forgot password from register
          navigationNotifier.navigateToForgotPassword(
            fromRoute: RouteConstants.register,
          );
          expect(
            container.read(authNavigationProvider).isOnForgotPassword,
            isTrue,
          );
          expect(
            container.read(authNavigationProvider).previousRoute,
            equals(RouteConstants.register),
          );

          // Step 3: Go back to login
          navigationNotifier.navigateToLogin(
            fromRoute: RouteConstants.forgotPassword,
          );
          expect(container.read(authNavigationProvider).isOnLogin, isTrue);
          expect(
            container.read(authNavigationProvider).previousRoute,
            equals(RouteConstants.forgotPassword),
          );
        });
      });

      group('Route Constants Validation', () {
        test('should have correct route constants for registration flow', () {
          // Assert that route constants are properly defined
          expect(RouteConstants.login, isNotNull);
          expect(RouteConstants.register, isNotNull);
          expect(RouteConstants.forgotPassword, isNotNull);

          // These should be different routes
          expect(RouteConstants.login, isNot(equals(RouteConstants.register)));
          expect(
            RouteConstants.register,
            isNot(equals(RouteConstants.forgotPassword)),
          );
        });
      });

      group('Navigation State Consistency', () {
        test('should maintain consistent state during navigation', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Act - Perform multiple navigations
          navigationNotifier.navigateToRegister();
          final registerState = container.read(authNavigationProvider);

          navigationNotifier.navigateToLogin();
          final loginState = container.read(authNavigationProvider);

          // Assert - States should be consistent with their respective steps
          expect(registerState.isOnRegister, isTrue);
          expect(registerState.isOnLogin, isFalse);

          expect(loginState.isOnLogin, isTrue);
          expect(loginState.isOnRegister, isFalse);
        });

        test('should handle rapid navigation changes gracefully', () {
          // Arrange
          final navigationNotifier = container.read(
            authNavigationProvider.notifier,
          );

          // Act - Rapid navigation changes
          navigationNotifier.navigateToRegister();
          navigationNotifier.navigateToForgotPassword();
          navigationNotifier.navigateToLogin();
          navigationNotifier.navigateToProfile();

          // Assert - Should end up at profile
          final finalState = container.read(authNavigationProvider);
          expect(finalState.isOnProfile, isTrue);
          expect(finalState.currentStep, equals(AuthFlowStep.profile));
        });
      });
    },
  );
}
