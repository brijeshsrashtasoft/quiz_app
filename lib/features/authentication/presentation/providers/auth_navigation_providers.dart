import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_providers.dart';

part 'auth_navigation_providers.freezed.dart';

/// Authentication navigation state for managing auth flow navigation
/// Handles navigation between login, register, forgot password, and main app

@freezed
class AuthNavigationState with _$AuthNavigationState {
  const factory AuthNavigationState({
    @Default(AuthFlowStep.login) AuthFlowStep currentStep,
    @Default(false) bool isNavigating,
    @Default(false) bool showBackButton,
    String? previousRoute,
    String? targetRoute,
    Map<String, dynamic>? navigationParams,
  }) = _AuthNavigationState;

  const AuthNavigationState._();

  /// Check if currently on login step
  bool get isOnLogin => currentStep == AuthFlowStep.login;

  /// Check if currently on register step
  bool get isOnRegister => currentStep == AuthFlowStep.register;

  /// Check if currently on forgot password step
  bool get isOnForgotPassword => currentStep == AuthFlowStep.forgotPassword;

  /// Check if currently on profile step
  bool get isOnProfile => currentStep == AuthFlowStep.profile;

  /// Get route path for current step
  String get currentRoutePath {
    switch (currentStep) {
      case AuthFlowStep.login:
        return RouteConstants.login;
      case AuthFlowStep.register:
        return RouteConstants.register;
      case AuthFlowStep.forgotPassword:
        return RouteConstants.forgotPassword;
      case AuthFlowStep.profile:
        return RouteConstants.profile;
    }
  }

  /// Get page title for current step
  String get pageTitle {
    switch (currentStep) {
      case AuthFlowStep.login:
        return 'Welcome Back';
      case AuthFlowStep.register:
        return 'Create Account';
      case AuthFlowStep.forgotPassword:
        return 'Reset Password';
      case AuthFlowStep.profile:
        return 'Profile Settings';
    }
  }

  /// Get subtitle for current step
  String get pageSubtitle {
    switch (currentStep) {
      case AuthFlowStep.login:
        return 'Sign in to continue your quiz journey';
      case AuthFlowStep.register:
        return 'Join thousands of quiz enthusiasts';
      case AuthFlowStep.forgotPassword:
        return 'Enter your email to reset your password';
      case AuthFlowStep.profile:
        return 'Manage your account settings';
    }
  }
}

/// Authentication flow steps
enum AuthFlowStep {
  login,
  register,
  forgotPassword,
  profile,
}

/// Authentication Navigation Notifier
class AuthNavigationNotifier extends StateNotifier<AuthNavigationState> {
  final Ref ref;

  AuthNavigationNotifier(this.ref) : super(const AuthNavigationState()) {
    _initializeAuthListener();
  }

  /// Initialize authentication state listener
  void _initializeAuthListener() {
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      next.whenData((authState) {
        if (authState.isAuthenticated) {
          _handleAuthenticationSuccess();
        } else if (authState.hasError) {
          _handleAuthenticationError(authState.errorMessage);
        }
      });
    });
  }

  /// Navigate to login step
  void navigateToLogin({String? fromRoute}) {
    AppLogger.info('AuthNavigation', 'Navigating to login from: ${fromRoute ?? 'unknown'}');
    
    state = state.copyWith(
      currentStep: AuthFlowStep.login,
      previousRoute: fromRoute,
      showBackButton: fromRoute != null,
      isNavigating: true,
    );

    AppRouter.go(RouteConstants.login);
    
    state = state.copyWith(isNavigating: false);
  }

  /// Navigate to register step
  void navigateToRegister({String? fromRoute}) {
    AppLogger.info('AuthNavigation', 'Navigating to register from: ${fromRoute ?? 'login'}');
    
    state = state.copyWith(
      currentStep: AuthFlowStep.register,
      previousRoute: fromRoute ?? RouteConstants.login,
      showBackButton: true,
      isNavigating: true,
    );

    AppRouter.go(RouteConstants.register);
    
    state = state.copyWith(isNavigating: false);
  }

  /// Navigate to forgot password step
  void navigateToForgotPassword({String? fromRoute}) {
    AppLogger.info('AuthNavigation', 'Navigating to forgot password from: ${fromRoute ?? 'login'}');
    
    state = state.copyWith(
      currentStep: AuthFlowStep.forgotPassword,
      previousRoute: fromRoute ?? RouteConstants.login,
      showBackButton: true,
      isNavigating: true,
    );

    AppRouter.go(RouteConstants.forgotPassword);
    
    state = state.copyWith(isNavigating: false);
  }

  /// Navigate to profile step
  void navigateToProfile({String? fromRoute}) {
    AppLogger.info('AuthNavigation', 'Navigating to profile from: ${fromRoute ?? 'home'}');
    
    state = state.copyWith(
      currentStep: AuthFlowStep.profile,
      previousRoute: fromRoute ?? RouteConstants.home,
      showBackButton: true,
      isNavigating: true,
    );

    AppRouter.go(RouteConstants.profile);
    
    state = state.copyWith(isNavigating: false);
  }

  /// Navigate back to previous route
  void navigateBack() {
    if (state.previousRoute != null) {
      AppLogger.info('AuthNavigation', 'Navigating back to: ${state.previousRoute}');
      
      state = state.copyWith(isNavigating: true);
      AppRouter.go(state.previousRoute!);
      state = state.copyWith(isNavigating: false);
    } else {
      // Default back navigation
      if (AppRouter.canPop()) {
        AppRouter.pop();
      } else {
        navigateToLogin();
      }
    }
  }

  /// Set target route for post-authentication navigation
  void setTargetRoute(String route, {Map<String, dynamic>? params}) {
    AppLogger.info('AuthNavigation', 'Setting target route: $route');
    
    state = state.copyWith(
      targetRoute: route,
      navigationParams: params,
    );
  }

  /// Handle successful authentication
  void _handleAuthenticationSuccess() {
    AppLogger.info('AuthNavigation', 'Authentication successful, navigating to target or home');
    
    final targetRoute = state.targetRoute ?? RouteConstants.home;
    
    state = state.copyWith(
      isNavigating: true,
      targetRoute: null,
      navigationParams: null,
    );

    // Navigate to target route or home
    AppRouter.clearAndGoTo(targetRoute);
    
    state = state.copyWith(isNavigating: false);
  }

  /// Handle authentication error
  void _handleAuthenticationError(String? errorMessage) {
    AppLogger.warning('AuthNavigation', 'Authentication error: $errorMessage');
    
    // Stay on current auth page and let form handle error display
    state = state.copyWith(isNavigating: false);
  }

  /// Handle logout navigation
  void handleLogout() {
    AppLogger.info('AuthNavigation', 'User logged out, navigating to login');
    
    state = state.copyWith(
      currentStep: AuthFlowStep.login,
      previousRoute: null,
      targetRoute: null,
      navigationParams: null,
      showBackButton: false,
      isNavigating: true,
    );

    AppRouter.clearAndGoTo(RouteConstants.login);
    
    state = state.copyWith(isNavigating: false);
  }

  /// Navigate to main app after authentication
  void navigateToMainApp() {
    AppLogger.info('AuthNavigation', 'Navigating to main app');
    
    state = state.copyWith(isNavigating: true);
    AppRouter.clearAndGoTo(RouteConstants.home);
    state = state.copyWith(isNavigating: false);
  }

  /// Check if user should be redirected from auth pages
  bool shouldRedirectFromAuthPages() {
    final authState = ref.read(authStateProvider).value;
    return authState?.isAuthenticated == true;
  }

  /// Get appropriate auth route based on current state
  String getAuthRouteForUnauthenticatedUser() {
    // Default to login for unauthenticated users
    return RouteConstants.login;
  }

  /// Update current step without navigation (for external navigation)
  void updateCurrentStep(AuthFlowStep step) {
    state = state.copyWith(currentStep: step);
  }

  /// Reset navigation state
  void resetNavigationState() {
    state = const AuthNavigationState();
  }
}

/// Authentication flow helper methods
extension AuthNavigationHelper on AuthNavigationNotifier {
  /// Quick navigation method: Login -> Register
  void goToRegisterFromLogin() {
    navigateToRegister(fromRoute: RouteConstants.login);
  }

  /// Quick navigation method: Register -> Login
  void goToLoginFromRegister() {
    navigateToLogin(fromRoute: RouteConstants.register);
  }

  /// Quick navigation method: Login -> Forgot Password
  void goToForgotPasswordFromLogin() {
    navigateToForgotPassword(fromRoute: RouteConstants.login);
  }

  /// Quick navigation method: Forgot Password -> Login
  void goToLoginFromForgotPassword() {
    navigateToLogin(fromRoute: RouteConstants.forgotPassword);
  }

  /// Quick navigation method: Any Auth Page -> Profile
  void goToProfileFromAuth() {
    navigateToProfile(fromRoute: state.currentRoutePath);
  }
}

/// Global authentication flow controller
/// Manages authentication state across the entire app
final authFlowControllerProvider = StateNotifierProvider<AuthFlowController, AuthFlowState>((ref) {
  return AuthFlowController(ref);
});

@freezed
class AuthFlowState with _$AuthFlowState {
  const factory AuthFlowState({
    @Default(false) bool isInitialized,
    @Default(false) bool isLoading,
    @Default(AuthenticationStatus.unknown) AuthenticationStatus status,
    UserEntity? user,
    String? errorMessage,
  }) = _AuthFlowState;

  const AuthFlowState._();

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthenticationStatus.authenticated;

  /// Check if user is unauthenticated
  bool get isUnauthenticated => status == AuthenticationStatus.unauthenticated;

  /// Check if authentication status is unknown
  bool get isUnknown => status == AuthenticationStatus.unknown;

  /// Check if there's an error
  bool get hasError => errorMessage != null;
}

enum AuthenticationStatus {
  unknown,
  authenticated,
  unauthenticated,
}

/// Authentication Flow Controller
/// Handles global authentication state and navigation decisions
class AuthFlowController extends StateNotifier<AuthFlowState> {
  final Ref ref;

  AuthFlowController(this.ref) : super(const AuthFlowState()) {
    _initialize();
  }

  /// Initialize authentication flow
  void _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Listen to authentication state changes
      ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
        next.when(
          data: (authState) {
            if (authState.isAuthenticated) {
              _updateAuthenticationStatus(
                AuthenticationStatus.authenticated,
                user: authState.user,
              );
            } else if (authState.isUnauthenticated) {
              _updateAuthenticationStatus(AuthenticationStatus.unauthenticated);
            } else if (authState.hasError) {
              _updateAuthenticationError(authState.errorMessage);
            }
          },
          loading: () {
            state = state.copyWith(isLoading: true);
          },
          error: (error, stackTrace) {
            _updateAuthenticationError('Authentication error: ${error.toString()}');
          },
        );
      });

      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
      );

      AppLogger.info('AuthFlowController', 'Authentication flow initialized');
    } catch (e) {
      AppLogger.error('AuthFlowController initialization failed', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize authentication',
      );
    }
  }

  /// Update authentication status
  void _updateAuthenticationStatus(
    AuthenticationStatus status, {
    UserEntity? user,
  }) {
    state = state.copyWith(
      status: status,
      user: user,
      errorMessage: null,
      isLoading: false,
    );

    AppLogger.info(
      'AuthFlowController',
      'Authentication status updated: $status',
    );
  }

  /// Update authentication error
  void _updateAuthenticationError(String? errorMessage) {
    state = state.copyWith(
      errorMessage: errorMessage,
      isLoading: false,
    );

    AppLogger.error('AuthFlowController', errorMessage ?? 'Unknown auth error');
  }

  /// Sign out user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signOut();

      result.when(
        success: (_) {
          _updateAuthenticationStatus(AuthenticationStatus.unauthenticated);
          
          // Navigate to login
          final authNavigation = ref.read(authNavigationProvider.notifier);
          authNavigation.handleLogout();
        },
        failure: (failure) {
          _updateAuthenticationError(failure.userMessage);
        },
      );
    } catch (e) {
      _updateAuthenticationError('Sign out failed: ${e.toString()}');
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Refresh authentication state
  void refreshAuthState() {
    // This will trigger the auth state provider to re-evaluate
    ref.invalidate(authStateProvider);
  }
}