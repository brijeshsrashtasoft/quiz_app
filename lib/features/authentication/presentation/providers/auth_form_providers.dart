import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/password.dart';
import 'auth_providers.dart';
import '../../domain/usecases/update_user_profile_usecase.dart' show UpdateUserProfileParams;

part 'auth_form_providers.freezed.dart';

/// Form validation states following MVVM pattern
/// Each form has its own state and business logic

/// Login Form State
@freezed
class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default('') String email,
    @Default('') String password,
    @Default(false) bool isLoading,
    @Default(false) bool isPasswordVisible,
    @Default(false) bool rememberMe,
    String? emailError,
    String? passwordError,
    String? generalError,
    String? successMessage,
  }) = _LoginFormState;

  const LoginFormState._();

  /// Check if form is valid for submission
  bool get isValid => 
    email.isNotEmpty && 
    password.isNotEmpty && 
    emailError == null && 
    passwordError == null;

  /// Check if form has any errors
  bool get hasErrors => 
    emailError != null || 
    passwordError != null || 
    generalError != null;
}

/// Login Form Notifier
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Ref ref;

  LoginFormNotifier(this.ref) : super(const LoginFormState());

  /// Update email field with validation
  void updateEmail(String email) {
    final emailResult = Email.validate(email);
    state = state.copyWith(
      email: email,
      emailError: emailResult.isSuccess ? null : emailResult.failureOrNull?.userMessage,
      generalError: null,
    );
  }

  /// Update password field with validation
  void updatePassword(String password) {
    final passwordResult = Password.validate(password);
    state = state.copyWith(
      password: password,
      passwordError: passwordResult.isSuccess ? null : passwordResult.failureOrNull?.userMessage,
      generalError: null,
    );
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  /// Toggle remember me option
  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  /// Submit login form
  Future<void> submitLogin() async {
    if (!state.isValid) {
      AppLogger.warning('Login form submission attempted with invalid data');
      return;
    }

    state = state.copyWith(isLoading: true, generalError: null);
    
    try {
      AppLogger.firebase('LoginForm', 'Attempting login for: ${state.email}');
      
      final authService = ref.read(authServiceProvider);
      final result = await authService.signInWithEmailAndPassword(
        email: state.email,
        password: state.password,
      );

      result.when(
        success: (userCredential) {
          AppLogger.firebase('LoginForm', 'Login successful for: ${state.email}');
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Login successful! Welcome back.',
            generalError: null,
          );
          
          // Clear form after successful login
          _clearForm();
        },
        failure: (failure) {
          AppLogger.error('Login failed for: ${state.email}', failure);
          state = state.copyWith(
            isLoading: false,
            generalError: failure.userMessage,
          );
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected login error', e);
      state = state.copyWith(
        isLoading: false,
        generalError: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Clear form data
  void clearForm() {
    _clearForm();
  }

  void _clearForm() {
    state = const LoginFormState();
  }

  /// Reset error states
  void clearErrors() {
    state = state.copyWith(
      emailError: null,
      passwordError: null,
      generalError: null,
      successMessage: null,
    );
  }
}

/// Register Form State
@freezed
class RegisterFormState with _$RegisterFormState {
  const factory RegisterFormState({
    @Default('') String name,
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default(false) bool isLoading,
    @Default(false) bool isPasswordVisible,
    @Default(false) bool isConfirmPasswordVisible,
    @Default(false) bool agreeToTerms,
    String? nameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? generalError,
    String? successMessage,
  }) = _RegisterFormState;

  const RegisterFormState._();

  /// Check if form is valid for submission
  bool get isValid => 
    name.isNotEmpty && 
    email.isNotEmpty && 
    password.isNotEmpty && 
    confirmPassword.isNotEmpty &&
    password == confirmPassword &&
    agreeToTerms &&
    nameError == null && 
    emailError == null && 
    passwordError == null &&
    confirmPasswordError == null;

  /// Check if form has any errors
  bool get hasErrors => 
    nameError != null || 
    emailError != null || 
    passwordError != null || 
    confirmPasswordError != null ||
    generalError != null;

  /// Get password strength (0-4)
  int get passwordStrength {
    if (password.isEmpty) return 0;
    
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength > 4 ? 4 : strength;
  }
}

/// Register Form Notifier
class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final Ref ref;

  RegisterFormNotifier(this.ref) : super(const RegisterFormState());

  /// Update name field with validation
  void updateName(String name) {
    String? error;
    if (name.isEmpty) {
      error = 'Name is required';
    } else if (name.trim().length < 2) {
      error = 'Name must be at least 2 characters';
    }

    state = state.copyWith(
      name: name,
      nameError: error,
      generalError: null,
    );
  }

  /// Update email field with validation
  void updateEmail(String email) {
    final emailResult = Email.validate(email);
    state = state.copyWith(
      email: email,
      emailError: emailResult.isSuccess ? null : emailResult.failureOrNull?.userMessage,
      generalError: null,
    );
  }

  /// Update password field with validation
  void updatePassword(String password) {
    final passwordResult = Password.validate(password);
    state = state.copyWith(
      password: password,
      passwordError: passwordResult.isSuccess ? null : passwordResult.failureOrNull?.userMessage,
      generalError: null,
    );

    // Re-validate confirm password if it exists
    if (state.confirmPassword.isNotEmpty) {
      _validateConfirmPassword(state.confirmPassword);
    }
  }

  /// Update confirm password field with validation
  void updateConfirmPassword(String confirmPassword) {
    _validateConfirmPassword(confirmPassword);
  }

  void _validateConfirmPassword(String confirmPassword) {
    String? error;
    if (confirmPassword.isEmpty) {
      error = 'Please confirm your password';
    } else if (confirmPassword != state.password) {
      error = 'Passwords do not match';
    }

    state = state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: error,
      generalError: null,
    );
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  /// Toggle terms agreement
  void toggleTermsAgreement() {
    state = state.copyWith(agreeToTerms: !state.agreeToTerms);
  }

  /// Submit registration form
  Future<void> submitRegistration() async {
    if (!state.isValid) {
      AppLogger.warning('Registration form submission attempted with invalid data');
      return;
    }

    state = state.copyWith(isLoading: true, generalError: null);
    
    try {
      AppLogger.firebase('RegisterForm', 'Attempting registration for: ${state.email}');
      
      final authService = ref.read(authServiceProvider);
      final result = await authService.createUserWithEmailAndPassword(
        email: state.email,
        password: state.password,
        displayName: state.name,
      );

      result.when(
        success: (userCredential) {
          AppLogger.firebase('RegisterForm', 'Registration successful for: ${state.email}');
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Registration successful! Welcome to Quiz App.',
            generalError: null,
          );
          
          // Clear form after successful registration
          _clearForm();
        },
        failure: (failure) {
          AppLogger.error('Registration failed for: ${state.email}', failure);
          state = state.copyWith(
            isLoading: false,
            generalError: failure.userMessage,
          );
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected registration error', e);
      state = state.copyWith(
        isLoading: false,
        generalError: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Clear form data
  void clearForm() {
    _clearForm();
  }

  void _clearForm() {
    state = const RegisterFormState();
  }

  /// Reset error states
  void clearErrors() {
    state = state.copyWith(
      nameError: null,
      emailError: null,
      passwordError: null,
      confirmPasswordError: null,
      generalError: null,
      successMessage: null,
    );
  }
}

/// Forgot Password Form State
@freezed
class ForgotPasswordFormState with _$ForgotPasswordFormState {
  const factory ForgotPasswordFormState({
    @Default('') String email,
    @Default(false) bool isLoading,
    String? emailError,
    String? generalError,
    String? successMessage,
  }) = _ForgotPasswordFormState;

  const ForgotPasswordFormState._();

  /// Check if form is valid for submission
  bool get isValid => email.isNotEmpty && emailError == null;

  /// Check if form has any errors
  bool get hasErrors => emailError != null || generalError != null;
}

/// Forgot Password Form Notifier
class ForgotPasswordFormNotifier extends StateNotifier<ForgotPasswordFormState> {
  final Ref ref;

  ForgotPasswordFormNotifier(this.ref) : super(const ForgotPasswordFormState());

  /// Update email field with validation
  void updateEmail(String email) {
    final emailResult = Email.validate(email);
    state = state.copyWith(
      email: email,
      emailError: emailResult.isSuccess ? null : emailResult.failureOrNull?.userMessage,
      generalError: null,
      successMessage: null,
    );
  }

  /// Submit forgot password form
  Future<void> submitForgotPassword() async {
    if (!state.isValid) {
      AppLogger.warning('Forgot password form submission attempted with invalid data');
      return;
    }

    state = state.copyWith(isLoading: true, generalError: null, successMessage: null);
    
    try {
      AppLogger.firebase('ForgotPasswordForm', 'Sending password reset email to: ${state.email}');
      
      final authService = ref.read(authServiceProvider);
      final result = await authService.sendPasswordResetEmail(email: state.email);

      result.when(
        success: (_) {
          AppLogger.firebase('ForgotPasswordForm', 'Password reset email sent to: ${state.email}');
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Password reset email sent! Check your inbox.',
            generalError: null,
          );
        },
        failure: (failure) {
          AppLogger.error('Password reset failed for: ${state.email}', failure);
          state = state.copyWith(
            isLoading: false,
            generalError: failure.userMessage,
          );
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected password reset error', e);
      state = state.copyWith(
        isLoading: false,
        generalError: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Clear form data
  void clearForm() {
    state = const ForgotPasswordFormState();
  }

  /// Reset error states
  void clearErrors() {
    state = state.copyWith(
      emailError: null,
      generalError: null,
      successMessage: null,
    );
  }
}

/// Profile Form State
@freezed
class ProfileFormState with _$ProfileFormState {
  const factory ProfileFormState({
    @Default('') String name,
    @Default('') String email,
    @Default(false) bool isLoading,
    String? nameError,
    String? emailError,
    String? generalError,
    String? successMessage,
  }) = _ProfileFormState;

  const ProfileFormState._();

  /// Check if form is valid for submission
  bool get isValid => 
    name.isNotEmpty && 
    email.isNotEmpty && 
    nameError == null && 
    emailError == null;

  /// Check if form has any errors
  bool get hasErrors => 
    nameError != null || 
    emailError != null || 
    generalError != null;
}

/// Profile Form Notifier
class ProfileFormNotifier extends StateNotifier<ProfileFormState> {
  final Ref ref;

  ProfileFormNotifier(this.ref) : super(const ProfileFormState()) {
    _loadCurrentUserData();
  }

  /// Load current user data into form
  void _loadCurrentUserData() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      state = state.copyWith(
        name: currentUser.name,
        email: currentUser.email,
      );
    }
  }

  /// Update name field with validation
  void updateName(String name) {
    String? error;
    if (name.isEmpty) {
      error = 'Name is required';
    } else if (name.trim().length < 2) {
      error = 'Name must be at least 2 characters';
    }

    state = state.copyWith(
      name: name,
      nameError: error,
      generalError: null,
      successMessage: null,
    );
  }

  /// Update email field with validation
  void updateEmail(String email) {
    final emailResult = Email.validate(email);
    state = state.copyWith(
      email: email,
      emailError: emailResult.isSuccess ? null : emailResult.failureOrNull?.userMessage,
      generalError: null,
      successMessage: null,
    );
  }

  /// Submit profile update form
  Future<void> submitProfileUpdate() async {
    if (!state.isValid) {
      AppLogger.warning('Profile update form submission attempted with invalid data');
      return;
    }

    state = state.copyWith(isLoading: true, generalError: null, successMessage: null);
    
    try {
      AppLogger.firebase('ProfileForm', 'Updating profile for: ${state.email}');
      
      final updateUserProfileUseCase = ref.read(updateUserProfileUseCaseProvider);
      final currentUser = ref.read(currentUserProvider);
      
      if (currentUser == null) {
        state = state.copyWith(
          isLoading: false,
          generalError: 'User not found. Please log in again.',
        );
        return;
      }

      final result = await updateUserProfileUseCase(
        UpdateUserProfileParams(
          displayName: state.name,
        ),
      );

      result.when(
        success: (user) {
          AppLogger.firebase('ProfileForm', 'Profile updated successfully for: ${state.email}');
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Profile updated successfully!',
            generalError: null,
          );
        },
        failure: (failure) {
          AppLogger.error('Profile update failed for: ${state.email}', failure);
          state = state.copyWith(
            isLoading: false,
            generalError: failure.userMessage,
          );
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected profile update error', e);
      state = state.copyWith(
        isLoading: false,
        generalError: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Reset form to current user data
  void resetToCurrentUser() {
    _loadCurrentUserData();
    state = state.copyWith(
      nameError: null,
      emailError: null,
      generalError: null,
      successMessage: null,
    );
  }

  /// Clear form data
  void clearForm() {
    state = const ProfileFormState();
  }

  /// Reset error states
  void clearErrors() {
    state = state.copyWith(
      nameError: null,
      emailError: null,
      generalError: null,
      successMessage: null,
    );
  }
}

