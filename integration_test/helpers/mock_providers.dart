import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/features/authentication/domain/entities/auth_state.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';

/// Mock providers for E2E testing
/// These help isolate tests and avoid external dependencies

/// Test data helpers
class TestAuthStates {
  const TestAuthStates._();

  /// Mock authenticated user for testing
  static AuthState get authenticatedState => AuthState.authenticated(
        user: UserEntity(
          id: 'test_user_id',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      );

  /// Mock unauthenticated state for testing
  static AuthState get unauthenticatedState => const AuthState.unauthenticated();

  /// Mock loading state for testing
  static AuthState get loadingState => const AuthState.loading();

  /// Mock error state for testing
  static AuthState errorState(String message) => AuthState.error(message: message);
}

/// Provider overrides for testing different authentication states
class TestProviderOverrides {
  const TestProviderOverrides._();

  /// Override for authenticated user
  static List<Override> authenticatedUser() {
    return [
      authStateProvider.overrideWith(
        (ref) => Stream.value(TestAuthStates.authenticatedState),
      ),
    ];
  }

  /// Override for unauthenticated user
  static List<Override> unauthenticatedUser() {
    return [
      authStateProvider.overrideWith(
        (ref) => Stream.value(TestAuthStates.unauthenticatedState),
      ),
    ];
  }

  /// Override for loading state
  static List<Override> loadingState() {
    return [
      authStateProvider.overrideWith(
        (ref) => Stream.value(TestAuthStates.loadingState),
      ),
    ];
  }

  /// Override for error state
  static List<Override> errorState(String errorMessage) {
    return [
      authStateProvider.overrideWith(
        (ref) => Stream.error(errorMessage, StackTrace.current),
      ),
    ];
  }

  /// Override for slow loading (useful for testing loading states)
  static List<Override> slowLoading() {
    return [
      authStateProvider.overrideWith(
        (ref) => Stream.fromFuture(
          Future.delayed(
            const Duration(seconds: 2),
            () => TestAuthStates.authenticatedState,
          ),
        ),
      ),
    ];
  }
}

/// Test scenarios for different app states
enum TestScenario {
  authenticatedUser,
  unauthenticatedUser,
  loadingState,
  errorState,
  slowLoading,
}

/// Helper to get provider overrides for a specific test scenario
class TestScenarioManager {
  const TestScenarioManager._();

  static List<Override> getOverrides(TestScenario scenario, [String? errorMessage]) {
    switch (scenario) {
      case TestScenario.authenticatedUser:
        return TestProviderOverrides.authenticatedUser();
      case TestScenario.unauthenticatedUser:
        return TestProviderOverrides.unauthenticatedUser();
      case TestScenario.loadingState:
        return TestProviderOverrides.loadingState();
      case TestScenario.errorState:
        return TestProviderOverrides.errorState(errorMessage ?? 'Test error');
      case TestScenario.slowLoading:
        return TestProviderOverrides.slowLoading();
    }
  }
}