import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/firebase/auth_config.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_state.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/datasources/user_firestore_datasource.dart';
import '../../data/datasources/auth_firebase_datasource.dart';
import '../../domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/watch_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/watch_auth_state_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';

// Import form and navigation providers
import 'auth_form_providers.dart';
import 'auth_navigation_providers.dart';

/// Firebase Auth state provider - core authentication state
final firebaseAuthProvider = StreamProvider<User?>((ref) {
  AppLogger.firebase('AuthProvider', 'Setting up Firebase Auth state stream');
  return AuthConfig.idTokenChanges;
});

/// Enhanced authentication state with Firebase user

/// Authentication state provider - enhanced auth state with user data
final authStateProvider = StreamProvider<domain.AuthState>((ref) async* {
  await for (final firebaseUser
      in ref.watch(firebaseAuthProvider.future).asStream()) {
    if (firebaseUser == null) {
      AppLogger.firebase('AuthProvider', 'User not authenticated');
      yield const domain.AuthState.unauthenticated();
      continue;
    }

    AppLogger.firebase(
      'AuthProvider',
      'User authenticated: ${firebaseUser.email}',
    );

    // Try to get user data from Firestore
    try {
      final getUserUseCase = ref.read(getUserByIdUseCaseProvider);
      final userResult = await getUserUseCase(
        GetUserByIdParams(userId: firebaseUser.uid),
      );

      if (userResult.isSuccess) {
        final userEntity = userResult.dataOrNull!;
        AppLogger.firebase(
          'AuthProvider',
          'User data loaded from Firestore: ${userEntity.email}',
        );
        yield domain.AuthState.authenticated(user: userEntity);
      } else {
        // User doesn't exist in Firestore, create it
        AppLogger.firebase(
          'AuthProvider',
          'User not found in Firestore, creating profile',
        );

        final createUserUseCase = ref.read(createUserUseCaseProvider);
        final newUser = UserEntity(
          id: firebaseUser.uid,
          name:
              firebaseUser.displayName ??
              firebaseUser.email?.split('@').first ??
              'User',
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(),
        );

        final createResult = await createUserUseCase(
          CreateUserParams(user: newUser),
        );

        if (createResult.isSuccess) {
          AppLogger.firebase(
            'AuthProvider',
            'User profile created in Firestore',
          );
          yield domain.AuthState.authenticated(user: newUser);
        } else {
          // If Firestore fails, still authenticate with basic data
          AppLogger.warning(
            'Failed to create Firestore profile, using basic auth data',
          );
          yield domain.AuthState.authenticated(user: newUser);
        }
      }
    } catch (e) {
      AppLogger.error('Error with Firestore user data', e);
      // If Firestore operations fail, still authenticate with basic data
      final basicUser = UserEntity(
        id: firebaseUser.uid,
        name:
            firebaseUser.displayName ??
            firebaseUser.email?.split('@').first ??
            'User',
        email: firebaseUser.email ?? '',
        createdAt: DateTime.now(),
      );
      yield domain.AuthState.authenticated(user: basicUser);
    }
  }
});

/// Current user provider - quick access to current user entity
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authStateAsync = ref.watch(authStateProvider);
  // For testing purposes, also check if we have a synchronous value
  final syncValue = authStateAsync.value;
  if (syncValue != null) {
    return syncValue.user;
  }

  return authStateAsync.when(
    data: (authState) => authState.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Current Firebase user provider - quick access to Firebase user
final currentFirebaseUserProvider = Provider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).value;
});

/// Authentication status provider - simple boolean for auth status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authStateAsync = ref.watch(authStateProvider);
  // For testing purposes, also check if we have a synchronous value
  final syncValue = authStateAsync.value;
  if (syncValue != null) {
    return syncValue.isAuthenticated;
  }

  return authStateAsync.when(
    data: (authState) => authState.isAuthenticated,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// User ID provider - quick access to current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id;
});

/// Watch user provider - real-time user data updates
final watchUserProvider = StreamProvider.family<UserEntity?, String>((
  ref,
  userId,
) {
  final watchUserUseCase = ref.read(watchUserUseCaseProvider);
  return watchUserUseCase(WatchUserParams(userId: userId)).asyncMap(
    (result) => result.when(success: (user) => user, failure: (error) => null),
  );
});

/// Authentication Firebase datasource provider
final authFirebaseDataSourceProvider = Provider<AuthFirebaseDataSource>((ref) {
  return AuthFirebaseDataSource();
});

/// User Firestore datasource provider
final userFirestoreDataSourceProvider = Provider<UserFirestoreDataSource>((
  ref,
) {
  return UserFirestoreDataSource();
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authDataSource = ref.read(authFirebaseDataSourceProvider);
  return AuthRepositoryImpl(authDataSource: authDataSource);
});

/// User repository provider
final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  final userDataSource = ref.read(userFirestoreDataSourceProvider);
  return UserRepositoryImpl(dataSource: userDataSource);
});

/// Authentication service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

/// User management use case providers
final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  final repository = ref.read(userRepositoryProvider);
  return GetUserByIdUseCase(repository: repository);
});

final createUserUseCaseProvider = Provider<CreateUserUseCase>((ref) {
  final repository = ref.read(userRepositoryProvider);
  return CreateUserUseCase(repository: repository);
});

final watchUserUseCaseProvider = Provider<WatchUserUseCase>((ref) {
  final repository = ref.read(userRepositoryProvider);
  return WatchUserUseCase(repository: repository);
});

/// Core authentication use case providers
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return SignInUseCase(authRepository: authRepository);
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((
  ref,
) {
  final authRepository = ref.read(authRepositoryProvider);
  return SignInWithGoogleUseCase(authRepository: authRepository);
});

final watchAuthStateUseCaseProvider = Provider<WatchAuthStateUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return WatchAuthStateUseCase(authRepository: authRepository);
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase();
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase();
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase();
});

/// User profile management use case providers
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.read(userRepositoryProvider);
  return GetCurrentUserUseCase(userRepository: repository);
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((
  ref,
) {
  final repository = ref.read(userRepositoryProvider);
  return UpdateUserProfileUseCase(userRepository: repository);
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  final repository = ref.read(userRepositoryProvider);
  return DeleteAccountUseCase(userRepository: repository);
});

/// Form state management providers for authentication forms
/// Following MVVM pattern with Riverpod state management

/// Login form state provider
final loginFormProvider =
    StateNotifierProvider<LoginFormNotifier, LoginFormState>((ref) {
      return LoginFormNotifier(ref);
    });

/// Register form state provider
final registerFormProvider =
    StateNotifierProvider<RegisterFormNotifier, RegisterFormState>((ref) {
      return RegisterFormNotifier(ref);
    });

/// Forgot password form state provider
final forgotPasswordFormProvider =
    StateNotifierProvider<ForgotPasswordFormNotifier, ForgotPasswordFormState>((
      ref,
    ) {
      return ForgotPasswordFormNotifier(ref);
    });

/// Profile form state provider
final profileFormProvider =
    StateNotifierProvider<ProfileFormNotifier, ProfileFormState>((ref) {
      return ProfileFormNotifier(ref);
    });

/// Authentication navigation state provider
final authNavigationProvider =
    StateNotifierProvider<AuthNavigationNotifier, AuthNavigationState>((ref) {
      return AuthNavigationNotifier(ref);
    });

/// Authentication service for handling auth operations
class AuthService {
  final Ref ref;

  AuthService(this.ref);

  /// Sign in with email and password
  Future<Result<UserCredential>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.firebase('AuthService', 'Attempting sign in for: $email');
      final credential = await AuthConfig.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      AppLogger.firebase('AuthService', 'Sign in successful for: $email');
      return Result.success(credential);
    } catch (e) {
      AppLogger.error('Sign in failed for: $email', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Sign in failed: ${e.toString()}',
          code: 'AUTH_SIGNIN_ERROR',
        ),
      );
    }
  }

  /// Create user with email and password
  Future<Result<UserCredential>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      AppLogger.firebase('AuthService', 'Attempting user creation for: $email');
      final credential = await AuthConfig.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && credential.user != null) {
        await AuthConfig.updateUserProfile(displayName: displayName);
      }

      AppLogger.firebase('AuthService', 'User creation successful for: $email');
      return Result.success(credential);
    } catch (e) {
      AppLogger.error('User creation failed for: $email', e);
      return Result.failure(
        Failure.authFailure(
          message: 'User creation failed: ${e.toString()}',
          code: 'AUTH_CREATE_USER_ERROR',
        ),
      );
    }
  }

  /// Sign out current user
  Future<Result<void>> signOut() async {
    try {
      final currentUser = AuthConfig.currentUser;
      AppLogger.firebase(
        'AuthService',
        'Attempting sign out for: ${currentUser?.email}',
      );

      await AuthConfig.signOut();

      AppLogger.firebase('AuthService', 'Sign out successful');
      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Sign out failed', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Sign out failed: ${e.toString()}',
          code: 'AUTH_SIGNOUT_ERROR',
        ),
      );
    }
  }

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      AppLogger.firebase(
        'AuthService',
        'Sending password reset email to: $email',
      );
      await AuthConfig.sendPasswordResetEmail(email: email);

      AppLogger.firebase('AuthService', 'Password reset email sent to: $email');
      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Password reset failed for: $email', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Password reset failed: ${e.toString()}',
          code: 'AUTH_PASSWORD_RESET_ERROR',
        ),
      );
    }
  }

  /// Update user profile
  Future<Result<void>> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final currentUser = AuthConfig.currentUser;
      AppLogger.firebase(
        'AuthService',
        'Updating profile for: ${currentUser?.email}',
      );

      await AuthConfig.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      AppLogger.firebase('AuthService', 'Profile update successful');
      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Profile update failed', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Profile update failed: ${e.toString()}',
          code: 'AUTH_PROFILE_UPDATE_ERROR',
        ),
      );
    }
  }

  /// Sign in with Google
  Future<Result<User>> signInWithGoogle() async {
    try {
      AppLogger.firebase('AuthService', 'Attempting Google sign in');

      // Use the AuthFirebaseDataSource for Google sign-in
      final authDataSource = ref.read(authFirebaseDataSourceProvider);
      final result = await authDataSource.signInWithGoogle();

      return result.when(
        success: (userModel) {
          AppLogger.firebase(
            'AuthService',
            'Google sign in successful for: ${userModel.email}',
          );
          final currentUser = AuthConfig.currentUser;
          if (currentUser != null) {
            return Result.success(currentUser);
          } else {
            return Result.failure(
              Failure.authFailure(
                message: 'Google sign in succeeded but no Firebase user found',
                code: 'AUTH_GOOGLE_NO_USER',
              ),
            );
          }
        },
        failure: (failure) {
          AppLogger.error('Google sign in failed', failure);
          return Result.failure(failure);
        },
      );
    } catch (e) {
      AppLogger.error('Google sign in failed', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Google sign in failed: ${e.toString()}',
          code: 'AUTH_GOOGLE_SIGNIN_ERROR',
        ),
      );
    }
  }

  /// Delete current user account
  Future<Result<void>> deleteUserAccount() async {
    try {
      final currentUser = AuthConfig.currentUser;
      AppLogger.firebase(
        'AuthService',
        'Deleting account for: ${currentUser?.email}',
      );

      await AuthConfig.deleteUser();

      AppLogger.firebase('AuthService', 'Account deletion successful');
      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Account deletion failed', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Account deletion failed: ${e.toString()}',
          code: 'AUTH_DELETE_ACCOUNT_ERROR',
        ),
      );
    }
  }

  /// Get current user
  User? get currentUser => AuthConfig.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => AuthConfig.isAuthenticated;

  /// Get current user ID
  String? get currentUserId => AuthConfig.currentUserId;

  /// Send email verification
  Future<Result<void>> sendEmailVerification() async {
    try {
      final currentUser = AuthConfig.currentUser;
      if (currentUser == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'No user signed in',
            code: 'AUTH_NO_USER',
          ),
        );
      }

      AppLogger.firebase(
        'AuthService',
        'Sending email verification to: ${currentUser.email}',
      );

      await currentUser.sendEmailVerification();

      AppLogger.firebase('AuthService', 'Email verification sent successfully');
      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Email verification failed', e);
      return Result.failure(
        Failure.authFailure(
          message: 'Email verification failed: ${e.toString()}',
          code: 'AUTH_EMAIL_VERIFICATION_ERROR',
        ),
      );
    }
  }

  /// Reload user data
  Future<Result<void>> reloadUser() async {
    try {
      final currentUser = AuthConfig.currentUser;
      if (currentUser == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'No user signed in',
            code: 'AUTH_NO_USER',
          ),
        );
      }

      await currentUser.reload();

      AppLogger.firebase('AuthService', 'User data reloaded');
      return const Result.success(null);
    } catch (e) {
      AppLogger.error('User reload failed', e);
      return Result.failure(
        Failure.authFailure(
          message: 'User reload failed: ${e.toString()}',
          code: 'AUTH_RELOAD_ERROR',
        ),
      );
    }
  }

  /// Check if email is verified
  bool get isEmailVerified {
    final currentUser = AuthConfig.currentUser;
    return currentUser?.emailVerified ?? false;
  }
}
