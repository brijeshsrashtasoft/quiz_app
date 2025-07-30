import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_entity.dart';

part 'auth_state.freezed.dart';

/// Authentication state entity representing the current auth status
/// Following Clean Architecture domain layer patterns
@freezed
class AuthState with _$AuthState {
  /// User is authenticated with valid user data
  const factory AuthState.authenticated({required UserEntity user}) =
      AuthenticatedState;

  /// User is not authenticated
  const factory AuthState.unauthenticated() = UnauthenticatedState;

  /// Authentication state is loading
  const factory AuthState.loading() = LoadingAuthState;

  /// Authentication error occurred
  const factory AuthState.error({required String message, String? code}) =
      ErrorAuthState;
}

/// Extension methods for AuthState
extension AuthStateX on AuthState {
  /// Check if user is authenticated
  bool get isAuthenticated => when(
    authenticated: (_) => true,
    unauthenticated: () => false,
    loading: () => false,
    error: (_, __) => false,
  );

  /// Check if user is unauthenticated
  bool get isUnauthenticated => when(
    authenticated: (_) => false,
    unauthenticated: () => true,
    loading: () => false,
    error: (_, __) => false,
  );

  /// Check if auth state is loading
  bool get isLoading => when(
    authenticated: (_) => false,
    unauthenticated: () => false,
    loading: () => true,
    error: (_, __) => false,
  );

  /// Check if auth state has error
  bool get hasError => when(
    authenticated: (_) => false,
    unauthenticated: () => false,
    loading: () => false,
    error: (_, __) => true,
  );

  /// Get user if authenticated, null otherwise
  UserEntity? get user => when(
    authenticated: (user) => user,
    unauthenticated: () => null,
    loading: () => null,
    error: (_, __) => null,
  );

  /// Get error message if in error state
  String? get errorMessage => when(
    authenticated: (_) => null,
    unauthenticated: () => null,
    loading: () => null,
    error: (message, _) => message,
  );
}
