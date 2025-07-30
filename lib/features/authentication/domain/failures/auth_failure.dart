import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

/// Authentication-specific failure types for Clean Architecture domain layer
/// Following CLAUDE.md error handling patterns with detailed auth failures
@freezed
class AuthFailure with _$AuthFailure {
  /// Invalid email address format
  const factory AuthFailure.invalidEmail({
    required String message,
    String? email,
  }) = InvalidEmailFailure;

  /// Weak password that doesn't meet requirements
  const factory AuthFailure.weakPassword({
    required String message,
    List<String>? requirements,
  }) = WeakPasswordFailure;

  /// Email already exists during registration
  const factory AuthFailure.emailAlreadyInUse({
    required String message,
    String? email,
  }) = EmailAlreadyInUseFailure;

  /// User not found during sign in
  const factory AuthFailure.userNotFound({
    required String message,
    String? email,
  }) = UserNotFoundFailure;

  /// Wrong password during sign in
  const factory AuthFailure.wrongPassword({required String message}) =
      WrongPasswordFailure;

  /// Account disabled by admin
  const factory AuthFailure.userDisabled({
    required String message,
    String? email,
  }) = UserDisabledFailure;

  /// Too many sign in attempts
  const factory AuthFailure.tooManyRequests({
    required String message,
    DateTime? retryAfter,
  }) = TooManyRequestsFailure;

  /// Email not verified when verification is required
  const factory AuthFailure.emailNotVerified({
    required String message,
    String? email,
  }) = EmailNotVerifiedFailure;

  /// No user currently signed in
  const factory AuthFailure.userNotSignedIn({required String message}) =
      UserNotSignedInFailure;

  /// Session expired, requires re-authentication
  const factory AuthFailure.sessionExpired({required String message}) =
      SessionExpiredFailure;

  /// Re-authentication required for sensitive operations
  const factory AuthFailure.requiresRecentLogin({required String message}) =
      RequiresRecentLoginFailure;

  /// Account already linked with this credential
  const factory AuthFailure.accountExistsWithDifferentCredential({
    required String message,
    String? email,
    List<String>? signInMethods,
  }) = AccountExistsWithDifferentCredentialFailure;

  /// Invalid credential provided
  const factory AuthFailure.invalidCredential({required String message}) =
      InvalidCredentialFailure;

  /// Operation not allowed (e.g., provider not enabled)
  const factory AuthFailure.operationNotAllowed({
    required String message,
    String? operation,
  }) = OperationNotAllowedFailure;

  /// Network error during authentication
  const factory AuthFailure.networkError({required String message}) =
      NetworkErrorFailure;

  /// Provider-specific error (Google, Apple, etc.)
  const factory AuthFailure.providerError({
    required String message,
    String? provider,
    String? code,
  }) = ProviderErrorFailure;

  /// Unknown authentication error
  const factory AuthFailure.unknown({required String message, String? code}) =
      UnknownAuthFailure;
}

/// Extension for user-friendly error messages and recovery suggestions
extension AuthFailureX on AuthFailure {
  /// Get user-friendly error message
  String get userMessage {
    return when(
      invalidEmail: (message, email) => 'Please enter a valid email address',
      weakPassword: (message, requirements) => 'Password is too weak. $message',
      emailAlreadyInUse: (message, email) =>
          'An account with this email already exists',
      userNotFound: (message, email) =>
          'No account found with this email address',
      wrongPassword: (message) => 'Incorrect password. Please try again',
      userDisabled: (message, email) => 'This account has been disabled',
      tooManyRequests: (message, retryAfter) =>
          'Too many attempts. Please try again later',
      emailNotVerified: (message, email) =>
          'Please verify your email address before continuing',
      userNotSignedIn: (message) => 'Please sign in to continue',
      sessionExpired: (message) =>
          'Your session has expired. Please sign in again',
      requiresRecentLogin: (message) => 'Please sign in again to continue',
      accountExistsWithDifferentCredential: (message, email, methods) =>
          'An account with this email already exists. Try signing in with ${methods?.join(" or ") ?? "another method"}',
      invalidCredential: (message) =>
          'Invalid credentials. Please check and try again',
      operationNotAllowed: (message, operation) =>
          'This sign-in method is not enabled',
      networkError: (message) =>
          'Network error. Please check your connection and try again',
      providerError: (message, provider, code) =>
          'Error with ${provider ?? "sign-in provider"}. Please try again',
      unknown: (message, code) => 'Sign-in failed. Please try again',
    );
  }

  /// Get technical error code for logging
  String get errorCode {
    return when(
      invalidEmail: (_, __) => 'AUTH_INVALID_EMAIL',
      weakPassword: (_, __) => 'AUTH_WEAK_PASSWORD',
      emailAlreadyInUse: (_, __) => 'AUTH_EMAIL_ALREADY_IN_USE',
      userNotFound: (_, __) => 'AUTH_USER_NOT_FOUND',
      wrongPassword: (_) => 'AUTH_WRONG_PASSWORD',
      userDisabled: (_, __) => 'AUTH_USER_DISABLED',
      tooManyRequests: (_, __) => 'AUTH_TOO_MANY_REQUESTS',
      emailNotVerified: (_, __) => 'AUTH_EMAIL_NOT_VERIFIED',
      userNotSignedIn: (_) => 'AUTH_USER_NOT_SIGNED_IN',
      sessionExpired: (_) => 'AUTH_SESSION_EXPIRED',
      requiresRecentLogin: (_) => 'AUTH_REQUIRES_RECENT_LOGIN',
      accountExistsWithDifferentCredential: (_, __, ___) =>
          'AUTH_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL',
      invalidCredential: (_) => 'AUTH_INVALID_CREDENTIAL',
      operationNotAllowed: (_, __) => 'AUTH_OPERATION_NOT_ALLOWED',
      networkError: (_) => 'AUTH_NETWORK_ERROR',
      providerError: (_, __, code) => code ?? 'AUTH_PROVIDER_ERROR',
      unknown: (_, code) => code ?? 'AUTH_UNKNOWN',
    );
  }

  /// Check if error is recoverable (user can retry)
  bool get isRecoverable {
    return when(
      invalidEmail: (_, __) => true,
      weakPassword: (_, __) => true,
      emailAlreadyInUse: (_, __) => true,
      userNotFound: (_, __) => true,
      wrongPassword: (_) => true,
      userDisabled: (_, __) => false,
      tooManyRequests: (_, __) => true,
      emailNotVerified: (_, __) => true,
      userNotSignedIn: (_) => true,
      sessionExpired: (_) => true,
      requiresRecentLogin: (_) => true,
      accountExistsWithDifferentCredential: (_, __, ___) => true,
      invalidCredential: (_) => true,
      operationNotAllowed: (_, __) => false,
      networkError: (_) => true,
      providerError: (_, __, ___) => true,
      unknown: (_, __) => true,
    );
  }

  /// Check if error requires user action
  bool get requiresUserAction {
    return when(
      invalidEmail: (_, __) => true,
      weakPassword: (_, __) => true,
      emailAlreadyInUse: (_, __) => true,
      userNotFound: (_, __) => true,
      wrongPassword: (_) => true,
      userDisabled: (_, __) => false,
      tooManyRequests: (_, __) => false,
      emailNotVerified: (_, __) => true,
      userNotSignedIn: (_) => true,
      sessionExpired: (_) => true,
      requiresRecentLogin: (_) => true,
      accountExistsWithDifferentCredential: (_, __, ___) => true,
      invalidCredential: (_) => true,
      operationNotAllowed: (_, __) => false,
      networkError: (_) => false,
      providerError: (_, __, ___) => true,
      unknown: (_, __) => true,
    );
  }

  /// Get suggested recovery action for user
  String? get recoveryAction {
    return when(
      invalidEmail: (_, __) => 'Please enter a valid email address',
      weakPassword: (_, requirements) =>
          'Create a stronger password with ${requirements?.join(", ") ?? "uppercase, lowercase, numbers, and special characters"}',
      emailAlreadyInUse: (_, __) =>
          'Try signing in instead, or use a different email',
      userNotFound: (_, __) =>
          'Check your email address or create a new account',
      wrongPassword: (_) => 'Check your password or reset it if forgotten',
      userDisabled: (_, __) => 'Contact support for assistance',
      tooManyRequests: (_, retryAfter) => 'Wait a moment and try again',
      emailNotVerified: (_, __) =>
          'Check your email and click the verification link',
      userNotSignedIn: (_) => 'Please sign in to your account',
      sessionExpired: (_) => 'Sign in again to continue',
      requiresRecentLogin: (_) => 'Sign in again to verify your identity',
      accountExistsWithDifferentCredential: (_, __, methods) =>
          'Sign in using ${methods?.join(" or ") ?? "your existing method"}',
      invalidCredential: (_) => 'Check your credentials and try again',
      operationNotAllowed: (_, __) => 'Contact support if you need help',
      networkError: (_) => 'Check your internet connection',
      providerError: (_, provider, __) =>
          'Try again or use a different sign-in method',
      unknown: (_, __) =>
          'Try again or contact support if the problem persists',
    );
  }
}
