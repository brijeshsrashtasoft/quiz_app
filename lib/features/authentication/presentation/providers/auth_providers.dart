import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/firebase/auth_config.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/user_firestore_datasource.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/watch_user_usecase.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../domain/usecases/delete_user_account_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/repositories/user_repository.dart';

/// Firebase Auth Data Source provider
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource();
});

/// Auth Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.read(firebaseAuthDataSourceProvider);
  return AuthRepositoryImpl(dataSource: dataSource);
});

/// Firebase Auth state provider - core authentication state
final firebaseAuthProvider = StreamProvider<User?>((ref) {
  AppLogger.firebase('AuthProvider', 'Setting up Firebase Auth state stream');
  final authRepository = ref.read(authRepositoryProvider);
  return authRepository.idTokenChanges();
});

/// Authentication state provider - enhanced auth state with user data
final authStateProvider = StreamProvider<AuthState>((ref) async* {
  await for (final firebaseUser in ref.watch(firebaseAuthProvider.stream)) {
    if (firebaseUser == null) {
      AppLogger.firebase('AuthProvider', 'User not authenticated');
      yield const AuthState.unauthenticated();
      continue;
    }

    AppLogger.firebase(
      'AuthProvider',
      'User authenticated: ${firebaseUser.email}',
    );

    // Get user data from Firestore
    try {
      final getUserUseCase = ref.read(getUserByIdUseCaseProvider);
      final userResult = await getUserUseCase(
        GetUserByIdParams(userId: firebaseUser.uid),
      );

      if (userResult.isSuccess) {
        final userEntity = userResult.dataOrNull!;
        AppLogger.firebase(
          'AuthProvider',
          'User data loaded: ${userEntity.email}',
        );
        yield AuthState.authenticated(
          firebaseUser: firebaseUser,
          user: userEntity,
        );
      } else {
        final failure = userResult.failureOrNull!;
        AppLogger.warning(
          'User data not found, creating new user profile',
          failure,
        );

        // Create user profile if doesn't exist
        try {
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
            final createdUser = createResult.dataOrNull!;
            AppLogger.firebase(
              'AuthProvider',
              'New user profile created: ${createdUser.email}',
            );
            yield AuthState.authenticated(
              firebaseUser: firebaseUser,
              user: createdUser,
            );
          } else {
            final createFailure = createResult.failureOrNull!;
            AppLogger.error('Failed to create user profile', createFailure);
            yield AuthState.error(
              firebaseUser: firebaseUser,
              message:
                  'Failed to create user profile: ${createFailure.userMessage}',
            );
          }
        } catch (e) {
          AppLogger.error('Error creating user profile', e);
          yield AuthState.error(
            firebaseUser: firebaseUser,
            message: 'Failed to create user profile: ${e.toString()}',
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error loading user data', e);
      yield AuthState.error(
        firebaseUser: firebaseUser,
        message: 'Failed to load user data: ${e.toString()}',
      );
    }
  }
});

/// Current user provider - quick access to current user entity
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.user;
});

/// Current Firebase user provider - quick access to Firebase user
final currentFirebaseUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.firebaseUser;
});

/// Authentication status provider - simple boolean for auth status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.isAuthenticated ?? false;
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

/// Authentication service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthService(repository: authRepository);
});

/// Authentication use case providers
final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  final repository = UserRepositoryImpl(dataSource: UserFirestoreDataSource());
  return GetUserByIdUseCase(repository: repository);
});

final createUserUseCaseProvider = Provider<CreateUserUseCase>((ref) {
  final repository = UserRepositoryImpl(dataSource: UserFirestoreDataSource());
  return CreateUserUseCase(repository: repository);
});

final watchUserUseCaseProvider = Provider<WatchUserUseCase>((ref) {
  final repository = UserRepositoryImpl(dataSource: UserFirestoreDataSource());
  return WatchUserUseCase(repository: repository);
});

/// Authentication state model
class AuthState {
  final User? firebaseUser;
  final UserEntity? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState._({
    this.firebaseUser,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  const AuthState.loading() : this._(isLoading: true);

  const AuthState.unauthenticated() : this._();

  const AuthState.authenticated({
    required User firebaseUser,
    required UserEntity user,
  }) : this._(firebaseUser: firebaseUser, user: user);

  const AuthState.error({User? firebaseUser, required String message})
    : this._(firebaseUser: firebaseUser, errorMessage: message);

  bool get isAuthenticated =>
      firebaseUser != null && user != null && errorMessage == null;
  bool get hasError => errorMessage != null;
  bool get isUnauthenticated =>
      firebaseUser == null && user == null && errorMessage == null;
}

/// Authentication service for handling auth operations
class AuthService {
  final AuthRepository _authRepository;

  AuthService({required AuthRepository repository})
    : _authRepository = repository;

  /// Sign in with email and password
  Future<Result<UserCredential>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    AppLogger.firebase('AuthService', 'Attempting sign in for: $email');
    return await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Create user with email and password
  Future<Result<UserCredential>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    AppLogger.firebase('AuthService', 'Attempting user creation for: $email');
    return await _authRepository.createUserWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  /// Sign in with Google
  Future<Result<UserCredential>> signInWithGoogle() async {
    AppLogger.firebase('AuthService', 'Attempting Google sign in');
    return await _authRepository.signInWithGoogle();
  }

  /// Sign out current user
  Future<Result<void>> signOut() async {
    final currentUser = _authRepository.currentUser;
    AppLogger.firebase(
      'AuthService',
      'Attempting sign out for: ${currentUser?.email}',
    );
    return await _authRepository.signOut();
  }

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    AppLogger.firebase(
      'AuthService',
      'Sending password reset email to: $email',
    );
    return await _authRepository.sendPasswordResetEmail(email: email);
  }

  /// Send email verification
  Future<Result<void>> sendEmailVerification() async {
    AppLogger.firebase('AuthService', 'Sending email verification');
    return await _authRepository.sendEmailVerification();
  }

  /// Update user profile
  Future<Result<void>> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final currentUser = _authRepository.currentUser;
    AppLogger.firebase(
      'AuthService',
      'Updating profile for: ${currentUser?.email}',
    );
    return await _authRepository.updateUserProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
  }

  /// Delete current user account
  Future<Result<void>> deleteUserAccount() async {
    final currentUser = _authRepository.currentUser;
    AppLogger.firebase(
      'AuthService',
      'Deleting account for: ${currentUser?.email}',
    );
    return await _authRepository.deleteUserAccount();
  }

  /// Get ID token for current user
  Future<Result<String>> getIdToken({bool forceRefresh = false}) async {
    return await _authRepository.getIdToken(forceRefresh: forceRefresh);
  }

  /// Link account with email and password
  Future<Result<UserCredential>> linkWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _authRepository.linkWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Link account with Google
  Future<Result<UserCredential>> linkWithGoogle() async {
    return await _authRepository.linkWithGoogle();
  }

  /// Unlink authentication provider
  Future<Result<User>> unlinkProvider(String providerId) async {
    return await _authRepository.unlinkProvider(providerId);
  }

  /// Re-authenticate user with email and password
  Future<Result<UserCredential>> reauthenticateWithEmailAndPassword({
    required String password,
  }) async {
    return await _authRepository.reauthenticateWithEmailAndPassword(
      password: password,
    );
  }

  /// Re-authenticate user with Google
  Future<Result<UserCredential>> reauthenticateWithGoogle() async {
    return await _authRepository.reauthenticateWithGoogle();
  }

  /// Reload current user
  Future<Result<void>> reloadUser() async {
    return await _authRepository.reloadUser();
  }

  /// Get current user
  User? get currentUser => _authRepository.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _authRepository.isAuthenticated;

  /// Get current user ID
  String? get currentUserId => _authRepository.currentUserId;

  /// Check if current user's email is verified
  bool get isEmailVerified => _authRepository.isEmailVerified;

  /// Get current user's email safely
  String? get currentUserEmail => _authRepository.currentUserEmail;

  /// Get current user's display name safely
  String? get currentUserDisplayName => _authRepository.currentUserDisplayName;

  /// Get current user's photo URL safely
  String? get currentUserPhotoURL => _authRepository.currentUserPhotoURL;

  /// Check if user signed in with Google
  bool get isSignedInWithGoogle => _authRepository.isSignedInWithGoogle;

  /// Check if user signed in with email/password
  bool get isSignedInWithEmailPassword =>
      _authRepository.isSignedInWithEmailPassword;

  /// Get authentication provider IDs for current user
  List<String> get providerIds => _authRepository.providerIds;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  /// Stream of ID token changes (recommended for auth state)
  Stream<User?> get idTokenChanges => _authRepository.idTokenChanges;

  /// Stream of user changes (includes profile updates)
  Stream<User?> get userChanges => _authRepository.userChanges;
}

// ================================
// AUTHENTICATION USE CASE PROVIDERS
// ================================

/// Sign in with email use case provider
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return SignInWithEmailUseCase(repository: repository);
});

/// Sign up with email use case provider
final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return SignUpWithEmailUseCase(repository: repository);
});

/// Sign in with Google use case provider
final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((
  ref,
) {
  final repository = ref.read(authRepositoryProvider);
  return SignInWithGoogleUseCase(repository: repository);
});

/// Sign out use case provider
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return SignOutUseCase(repository: repository);
});

/// Send password reset use case provider
final sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>((
  ref,
) {
  final repository = ref.read(authRepositoryProvider);
  return SendPasswordResetUseCase(repository: repository);
});

/// Verify email use case provider
final verifyEmailUseCaseProvider = Provider<VerifyEmailUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return VerifyEmailUseCase(repository: repository);
});

/// Check email verification use case provider
final checkEmailVerificationUseCaseProvider =
    Provider<CheckEmailVerificationUseCase>((ref) {
      final repository = ref.read(authRepositoryProvider);
      return CheckEmailVerificationUseCase(repository: repository);
    });

/// Update user profile use case provider
final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((
  ref,
) {
  final repository = ref.read(authRepositoryProvider);
  return UpdateUserProfileUseCase(repository: repository);
});

/// Delete user account use case provider
final deleteUserAccountUseCaseProvider = Provider<DeleteUserAccountUseCase>((
  ref,
) {
  final authRepository = ref.read(authRepositoryProvider);
  final userRepository = ref.read(userRepositoryProvider);
  return DeleteUserAccountUseCase(
    authRepository: authRepository,
    userRepository: userRepository,
  );
});

/// Get current user use case provider
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return GetCurrentUserUseCase(repository: repository);
});

/// Is authenticated use case provider
final isAuthenticatedUseCaseProvider = Provider<IsAuthenticatedUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return IsAuthenticatedUseCase(repository: repository);
});

/// Watch auth state use case provider
final watchAuthStateUseCaseProvider = Provider<WatchAuthStateUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return WatchAuthStateUseCase(repository: repository);
});

/// User repository provider (for coordination with authentication)
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dataSource = UserFirestoreDataSource();
  return UserRepositoryImpl(dataSource: dataSource);
});
