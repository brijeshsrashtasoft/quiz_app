import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:quiz_app/features/authentication/domain/repositories/user_repository.dart';
import 'package:quiz_app/features/authentication/data/datasources/auth_firebase_datasource.dart';
import 'package:quiz_app/features/authentication/data/datasources/user_firestore_datasource.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/features/authentication/domain/entities/auth_state.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'auth_mocks.mocks.dart';

/// Mock Classes for US-001 Registration Flow Testing
/// Provides comprehensive mocking for authentication components

// Generate mocks using mockito annotations
@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  AuthRepository,
  UserRepository,
  AuthFirebaseDataSource,
  UserFirestoreDataSource,
])
/// Mock Provider Overrides for Testing
class MockProviders {
  MockProviders._();

  /// Create mock auth repository provider override
  static Override createMockAuthRepositoryProvider(
    MockAuthRepository mockRepo,
  ) {
    return Provider<AuthRepository>((ref) => mockRepo);
  }

  /// Create mock user repository provider override
  static Override createMockUserRepositoryProvider(
    MockUserRepository mockRepo,
  ) {
    return Provider<UserRepository>((ref) => mockRepo);
  }

  /// Create mock Firebase Auth provider override
  static Override createMockFirebaseAuthProvider(MockFirebaseAuth mockAuth) {
    return Provider<FirebaseAuth>((ref) => mockAuth);
  }

  /// Create authenticated auth state provider override
  static Override createAuthenticatedStateProvider(UserEntity user) {
    return StreamProvider<AuthState>((ref) {
      return Stream.fromIterable([AuthState.authenticated(user: user)]);
    });
  }

  /// Create unauthenticated auth state provider override
  static Override createUnauthenticatedStateProvider() {
    return StreamProvider<AuthState>((ref) {
      return Stream.fromIterable([const AuthState.unauthenticated()]);
    });
  }

  /// Create loading auth state provider override
  static Override createLoadingStateProvider() {
    return StreamProvider<AuthState>((ref) {
      return Stream.fromIterable([const AuthState.loading()]);
    });
  }

  /// Create error auth state provider override
  static Override createErrorStateProvider(String errorMessage) {
    return StreamProvider<AuthState>((ref) {
      return Stream.fromIterable([AuthState.error(message: errorMessage)]);
    });
  }
}

/// Mock Data Factory for creating test objects
class MockDataFactory {
  MockDataFactory._();

  /// Create a mock User (Firebase User)
  static MockUser createMockUser({
    String? uid,
    String? email,
    String? displayName,
    bool? emailVerified,
  }) {
    final mockUser = MockUser();

    when(mockUser.uid).thenReturn(uid ?? 'test-uid-123');
    when(mockUser.email).thenReturn(email ?? 'test@example.com');
    when(mockUser.displayName).thenReturn(displayName ?? 'Test User');
    when(mockUser.emailVerified).thenReturn(emailVerified ?? false);

    return mockUser;
  }

  /// Create a mock UserCredential
  static MockUserCredential createMockUserCredential({MockUser? user}) {
    final mockCredential = MockUserCredential();
    final mockUser = user ?? createMockUser();
    when(mockCredential.user).thenReturn(mockUser);
    return mockCredential;
  }

  /// Create a test UserEntity
  static UserEntity createUserEntity({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? 'test-user-123',
      name: name ?? 'Test User',
      email: email ?? 'test@example.com',
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Create mock FirebaseAuth with common behaviors
  static MockFirebaseAuth createMockFirebaseAuth() {
    final mockAuth = MockFirebaseAuth();

    // Set up default behaviors
    when(mockAuth.currentUser).thenReturn(null);
    when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));
    when(mockAuth.idTokenChanges()).thenAnswer((_) => Stream.value(null));
    when(mockAuth.userChanges()).thenAnswer((_) => Stream.value(null));

    return mockAuth;
  }

  /// Create mock AuthRepository with success behaviors
  static MockAuthRepository createSuccessfulAuthRepository() {
    final mockRepo = MockAuthRepository();

    // Mock successful sign up
    final userEntity = createUserEntity();
    when(
      mockRepo.createUserWithEmailPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      ),
    ).thenAnswer((_) async => Result.success(userEntity));

    // Mock successful sign in
    final userEntity2 = createUserEntity();
    when(
      mockRepo.signInWithEmailPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) async => Result.success(userEntity2));

    // Mock successful sign out
    when(
      mockRepo.signOut(),
    ).thenAnswer((_) async => const Result.success(null));

    return mockRepo;
  }

  /// Create mock AuthRepository with failure behaviors
  static MockAuthRepository createFailingAuthRepository() {
    final mockRepo = MockAuthRepository();

    // Mock failed sign up
    when(
      mockRepo.createUserWithEmailPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      ),
    ).thenAnswer(
      (_) async => Result.failure(
        const Failure.authFailure(
          message: 'Registration failed',
          code: 'AUTH_ERROR',
        ),
      ),
    );

    return mockRepo;
  }

  /// Create mock UserRepository with success behaviors
  static MockUserRepository createSuccessfulUserRepository() {
    final mockRepo = MockUserRepository();

    final testUser = createUserEntity();

    // Mock successful user creation
    when(
      mockRepo.createUser(any),
    ).thenAnswer((_) async => Result.success(testUser));

    // Mock successful user retrieval
    when(
      mockRepo.getUserById(any),
    ).thenAnswer((_) async => Result.success(testUser));

    // Mock successful user updates
    when(
      mockRepo.updateUser(any),
    ).thenAnswer((_) async => Result.success(testUser));

    return mockRepo;
  }
}

/// Mock Behaviors for specific test scenarios
class MockBehaviors {
  MockBehaviors._();

  /// Set up successful registration flow
  static void setupSuccessfulRegistration(
    MockAuthRepository mockAuthRepo,
    MockUserRepository mockUserRepo,
  ) {
    final mockCredential = MockDataFactory.createMockUserCredential();
    final testUser = MockDataFactory.createUserEntity();

    when(
      mockAuthRepo.createUserWithEmailPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      ),
    ).thenAnswer((_) async => Result.success(testUser));

    when(
      mockUserRepo.createUser(any),
    ).thenAnswer((_) async => Result.success(testUser));
  }

  /// Set up email already exists error
  static void setupEmailAlreadyExistsError(MockAuthRepository mockAuthRepo) {
    when(
      mockAuthRepo.createUserWithEmailPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      ),
    ).thenAnswer(
      (_) async => Result.failure(
        const Failure.authFailure(
          message: 'An account with this email already exists',
          code: 'AUTH_EMAIL_ALREADY_IN_USE',
        ),
      ),
    );
  }

  /// Set up weak password error
  static void setupWeakPasswordError(MockAuthRepository mockAuthRepo) {
    when(
      mockAuthRepo.createUserWithEmailPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      ),
    ).thenAnswer(
      (_) async => Result.failure(
        const Failure.validationFailure(
          message: 'Password is too weak',
          fieldErrors: {'password': 'Password is too weak'},
        ),
      ),
    );
  }

  /// Set up network error
  static void setupNetworkError(MockAuthRepository mockAuthRepo) {
    when(
      mockAuthRepo.createUserWithEmailPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      ),
    ).thenAnswer(
      (_) async => Result.failure(
        const Failure.networkFailure(message: 'Network connection failed'),
      ),
    );
  }

  /// Set up authentication state changes
  static void setupAuthStateChanges(
    MockFirebaseAuth mockAuth,
    List<User?> userStates,
  ) {
    when(
      mockAuth.authStateChanges(),
    ).thenAnswer((_) => Stream.fromIterable(userStates));
  }

  /// Set up user data loading success
  static void setupUserDataSuccess(
    MockUserRepository mockUserRepo,
    UserEntity user,
  ) {
    when(
      mockUserRepo.getUserById(any),
    ).thenAnswer((_) async => Result.success(user));
  }

  /// Set up user data loading failure
  static void setupUserDataFailure(MockUserRepository mockUserRepo) {
    when(mockUserRepo.getUserById(any)).thenAnswer(
      (_) async => Result.failure(
        const Failure.firestoreFailure(message: 'User data not found'),
      ),
    );
  }

  /// Set up email verification flow
  static void setupEmailVerificationFlow(MockUser mockUser) {
    // Initially not verified
    when(mockUser.emailVerified).thenReturn(false);

    // Mock sending verification email
    when(mockUser.sendEmailVerification()).thenAnswer((_) async => {});

    // Mock reloading user data
    when(mockUser.reload()).thenAnswer((_) async => {});
  }

  /// Set up form validation scenarios
  static Map<String, dynamic> createFormValidationScenarios() {
    return {
      'validEmail': 'test@example.com',
      'invalidEmail': 'invalid-email',
      'validPassword': 'StrongPass123',
      'weakPassword': 'weak',
      'validName': 'John Doe',
      'invalidName': 'A',
    };
  }

  /// Set up navigation scenarios
  static void setupNavigationMocks() {
    // This would set up mocks for navigation components
    // Implementation depends on the actual navigation system
  }
}

/// Test Utilities for working with mocks
class MockTestUtils {
  MockTestUtils._();

  /// Verify that a mock was called with specific parameters
  static void verifyMockCall(
    dynamic mock,
    String methodName,
    List<dynamic> arguments,
  ) {
    // Implementation would verify specific mock calls
    // This is a placeholder for test documentation
  }

  /// Reset all mocks to clean state
  static void resetAllMocks(List<Mock> mocks) {
    for (final mock in mocks) {
      reset(mock);
    }
  }

  /// Verify no unexpected interactions occurred
  static void verifyNoUnexpectedInteractions(List<Mock> mocks) {
    for (final mock in mocks) {
      verifyNoMoreInteractions(mock);
    }
  }

  /// Create a list of common provider overrides for testing
  static List<Override> createCommonOverrides({
    MockAuthRepository? authRepo,
    MockUserRepository? userRepo,
    MockFirebaseAuth? firebaseAuth,
  }) {
    final overrides = <Override>[];

    if (authRepo != null) {
      overrides.add(MockProviders.createMockAuthRepositoryProvider(authRepo));
    }

    if (userRepo != null) {
      overrides.add(MockProviders.createMockUserRepositoryProvider(userRepo));
    }

    if (firebaseAuth != null) {
      overrides.add(MockProviders.createMockFirebaseAuthProvider(firebaseAuth));
    }

    return overrides;
  }
}

/// Export all mocks for easy importing in test files
class _AuthMocksClass {}
