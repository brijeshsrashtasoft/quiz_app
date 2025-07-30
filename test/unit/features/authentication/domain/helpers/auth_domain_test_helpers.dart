/// Authentication domain testing utilities and helpers
/// Provides centralized test data builders, mocks, and utilities for domain layer tests
/// Following TDD principles and CLAUDE.md testing patterns

import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/features/authentication/domain/entities/auth_state.dart';

/// Authentication domain test data builders
class AuthDomainTestHelpers {
  AuthDomainTestHelpers._();

  /// Create test user entity with customizable properties
  static UserEntity createTestUserEntity({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    UserStats? stats,
    String? profileImageUrl,
    UserPreferences? preferences,
  }) {
    return UserEntity(
      id: id ?? 'test-user-123',
      name: name ?? 'Test User',
      email: email ?? 'test@example.com',
      createdAt: createdAt ?? DateTime.parse('2024-01-01T00:00:00.000Z'),
      stats: stats,
      profileImageUrl: profileImageUrl,
      preferences: preferences,
    );
  }

  /// Create test user stats with customizable properties
  static UserStats createTestUserStats({
    int? totalQuizzes,
    int? totalGamesPlayed,
    int? totalGamesWon,
    double? averageScore,
    DateTime? lastGameDate,
  }) {
    return UserStats(
      totalQuizzes: totalQuizzes ?? 10,
      totalGamesPlayed: totalGamesPlayed ?? 20,
      totalGamesWon: totalGamesWon ?? 5,
      averageScore: averageScore ?? 85.5,
      lastGameDate: lastGameDate,
    );
  }

  /// Create test user preferences with customizable properties
  static UserPreferences createTestUserPreferences({
    bool? soundEnabled,
    bool? notificationsEnabled,
    String? theme,
    String? language,
  }) {
    return UserPreferences(
      soundEnabled: soundEnabled ?? true,
      notificationsEnabled: notificationsEnabled ?? true,
      theme: theme ?? 'light',
      language: language ?? 'en',
    );
  }

  /// Create complete test user with all nested entities
  static UserEntity createCompleteTestUser({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    bool includeStats = true,
    bool includePreferences = true,
    String? profileImageUrl,
  }) {
    return UserEntity(
      id: id ?? 'complete-user-123',
      name: name ?? 'Complete Test User',
      email: email ?? 'complete@example.com',
      createdAt: createdAt ?? DateTime.parse('2024-01-01T00:00:00.000Z'),
      stats: includeStats ? createTestUserStats() : null,
      profileImageUrl: profileImageUrl ?? 'https://example.com/profile.jpg',
      preferences: includePreferences ? createTestUserPreferences() : null,
    );
  }

  /// Create minimal test user with required fields only
  static UserEntity createMinimalTestUser({
    String? id,
    String? name,
    String? email,
  }) {
    return UserEntity(
      id: id ?? 'minimal-user-123',
      name: name ?? 'Minimal User',
      email: email ?? 'minimal@example.com',
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    );
  }

  /// Create new user (created within last 7 days)
  static UserEntity createNewUser({
    String? id,
    String? name,
    String? email,
    int daysAgo = 3,
  }) {
    return UserEntity(
      id: id ?? 'new-user-123',
      name: name ?? 'New User',
      email: email ?? 'new@example.com',
      createdAt: DateTime.now().subtract(Duration(days: daysAgo)),
    );
  }

  /// Create experienced user (10+ games played)
  static UserEntity createExperiencedUser({
    String? id,
    String? name,
    String? email,
    int totalGamesPlayed = 15,
    int totalGamesWon = 8,
  }) {
    return UserEntity(
      id: id ?? 'experienced-user-123',
      name: name ?? 'Experienced User',
      email: email ?? 'experienced@example.com',
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      stats: UserStats(
        totalQuizzes: 20,
        totalGamesPlayed: totalGamesPlayed,
        totalGamesWon: totalGamesWon,
        averageScore: 88.5,
        lastGameDate: DateTime.now().subtract(Duration(days: 1)),
      ),
    );
  }

  /// Create admin user
  static UserEntity createAdminUser({
    String? id,
    String? name,
    String email = 'admin@quizapp.com',
  }) {
    return UserEntity(
      id: id ?? 'admin-user-123',
      name: name ?? 'Admin User',
      email: email,
      createdAt: DateTime.now().subtract(Duration(days: 100)),
      stats: createTestUserStats(),
      preferences: createTestUserPreferences(),
    );
  }

  /// Create user with incomplete profile
  static UserEntity createIncompleteProfileUser({
    String? id,
    bool emptyName = true,
    bool emptyEmail = false,
  }) {
    return UserEntity(
      id: id ?? 'incomplete-user-123',
      name: emptyName ? '' : 'User',
      email: emptyEmail ? '' : 'incomplete@example.com',
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    );
  }

  /// Create various test users for different scenarios
  static Map<String, UserEntity> createTestUserScenarios() {
    return {
      'minimal': createMinimalTestUser(),
      'complete': createCompleteTestUser(),
      'newUser': createNewUser(),
      'experienced': createExperiencedUser(),
      'admin': createAdminUser(),
      'incompleteProfile': createIncompleteProfileUser(),
      'perfectWinRate': createExperiencedUser(
        totalGamesPlayed: 10,
        totalGamesWon: 10,
      ),
      'zeroWinRate': createExperiencedUser(
        totalGamesPlayed: 10,
        totalGamesWon: 0,
      ),
    };
  }

  /// Create test auth states
  static AuthState createAuthenticatedState({UserEntity? user}) {
    return AuthState.authenticated(user: user ?? createTestUserEntity());
  }

  static AuthState createUnauthenticatedState() {
    return AuthState.unauthenticated();
  }

  static AuthState createLoadingState() {
    return AuthState.loading();
  }

  static AuthState createErrorState({String? message, String? code}) {
    return AuthState.error(
      message: message ?? 'Authentication error',
      code: code,
    );
  }

  /// Create test result objects
  static Result<T> createSuccessResult<T>(T data) {
    return Result.success(data);
  }

  static Result<T> createFailureResult<T>(Failure failure) {
    return Result.failure(failure);
  }

  /// Create test failure objects
  static Failure createAuthFailure({String? message, String? code}) {
    return Failure.authFailure(
      message: message ?? 'Authentication failed',
      code: code ?? 'AUTH_ERROR',
    );
  }

  static Failure createValidationFailure({
    String? message,
    Map<String, String>? fieldErrors,
  }) {
    return Failure.validationFailure(
      message: message ?? 'Validation failed',
      fieldErrors: fieldErrors ?? {'field': 'Field is invalid'},
    );
  }

  static Failure createNetworkFailure({String? message}) {
    return Failure.networkFailure(message: message ?? 'Network error');
  }

  static Failure createFirestoreFailure({String? message, String? code}) {
    return Failure.firestoreFailure(
      message: message ?? 'Firestore operation failed',
      code: code,
    );
  }

  /// Create test email validation scenarios
  static Map<String, bool> getEmailValidationTestCases() {
    return {
      // Valid emails
      'test@example.com': true,
      'user.name@domain.co.uk': true,
      'test123@subdomain.example.org': true,
      'user+tag@example.com': true,
      'user_name@example-domain.com': true,
      'a@b.co': true,

      // Invalid emails
      'plainaddress': false,
      '@missingdomain.com': false,
      'missing@.com': false,
      'spaces @example.com': false,
      'test@': false,
      'test..test@example.com': false,
      'test@domain': false,
      '': false,
      'test@domain.': false,
      '.test@domain.com': false,
    };
  }

  /// Create test password validation scenarios
  static Map<String, bool> getPasswordValidationTestCases() {
    return {
      // Valid passwords
      'password123': true,
      'StrongPassword123!': true,
      'simple123': true,
      'password1': true,
      'Test123': true,
      'abcd12': true,

      // Invalid passwords
      '123': false,
      'short': false,
      '12345': false,
      'password': false, // No numbers
      '123456': false, // No letters
      '': false,
    };
  }

  /// Create test name validation scenarios
  static Map<String, bool> getNameValidationTestCases() {
    return {
      // Valid names
      'John Doe': true,
      'María García': true,
      '李明': true,
      'Jean-Pierre': true,
      'O\'Connor': true,
      'Al': true,

      // Invalid names
      '': false,
      ' ': false,
      'A': false,
      '   ': false,
    };
  }

  /// Create performance test data
  static List<UserEntity> createPerformanceTestUsers(int count) {
    return List.generate(count, (index) {
      return UserEntity(
        id: 'perf-user-$index',
        name: 'Performance User $index',
        email: 'perf$index@example.com',
        createdAt: DateTime.now().subtract(Duration(days: index % 100)),
        stats: UserStats(
          totalQuizzes: index % 50,
          totalGamesPlayed: index % 100,
          totalGamesWon: index % 50,
          averageScore: (index % 100).toDouble(),
          lastGameDate: DateTime.now().subtract(Duration(days: index % 30)),
        ),
        preferences: UserPreferences(
          soundEnabled: index % 2 == 0,
          notificationsEnabled: index % 3 == 0,
          theme: index % 2 == 0 ? 'light' : 'dark',
          language: index % 2 == 0 ? 'en' : 'es',
        ),
      );
    });
  }

  /// Create edge case test data
  static Map<String, UserEntity> createEdgeCaseUsers() {
    return {
      'emptyStrings': UserEntity(
        id: '',
        name: '',
        email: '',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      ),
      'longStrings': UserEntity(
        id: 'a' * 100,
        name: 'Very Long Name ' * 10,
        email: '${'verylongemail' * 5}@${'verylongdomain' * 3}.com',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      ),
      'specialCharacters': UserEntity(
        id: 'user-123!@#',
        name: 'José María Ñoño',
        email: 'josé@ñoño.com',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      ),
      'futureDate': UserEntity(
        id: 'future-user-123',
        name: 'Future User',
        email: 'future@example.com',
        createdAt: DateTime.now().add(Duration(days: 365)),
      ),
      'veryOldDate': UserEntity(
        id: 'old-user-123',
        name: 'Old User',
        email: 'old@example.com',
        createdAt: DateTime.parse('1900-01-01T00:00:00.000Z'),
      ),
    };
  }

  /// Create concurrent testing scenarios
  static List<Future<UserEntity>> createConcurrentTestScenarios(int count) {
    return List.generate(count, (index) async {
      // Simulate async operations with random delays
      await Future.delayed(Duration(milliseconds: index % 100));
      return createTestUserEntity(
        id: 'concurrent-user-$index',
        name: 'Concurrent User $index',
        email: 'concurrent$index@example.com',
      );
    });
  }

  /// Verify user entity business logic
  static void verifyUserBusinessLogic(UserEntity user) {
    // Verify profile completeness logic
    final expectedProfileComplete =
        user.name.isNotEmpty && user.email.isNotEmpty;
    assert(user.isProfileComplete == expectedProfileComplete);

    // Verify win rate calculation
    if (user.stats == null || user.stats!.totalGamesPlayed == 0) {
      assert(user.winRate == 0.0);
    } else {
      final expectedWinRate =
          (user.stats!.totalGamesWon / user.stats!.totalGamesPlayed) * 100;
      assert(user.winRate == expectedWinRate);
    }

    // Verify experienced player logic
    final expectedExperienced =
        user.stats != null && user.stats!.totalGamesPlayed >= 10;
    assert(user.isExperiencedPlayer == expectedExperienced);

    // Verify new user logic
    final daysDifference = DateTime.now().difference(user.createdAt).inDays;
    final expectedNewUser = daysDifference <= 7;
    assert(user.isNewUser == expectedNewUser);

    // Verify host games logic
    final expectedCanHost = user.isProfileComplete && !user.isNewUser;
    assert(user.canHostGames == expectedCanHost);

    // Verify admin logic
    const adminEmails = ['admin@quizapp.com', 'support@quizapp.com'];
    final expectedAdmin =
        adminEmails.contains(user.email.toLowerCase()) ||
        user.email.toLowerCase().endsWith('@quizapp.com');
    assert(user.isAdmin == expectedAdmin);
  }

  /// Verify auth state business logic
  static void verifyAuthStateLogic(AuthState state) {
    state.when(
      authenticated: (user) {
        assert(state.isAuthenticated == true);
        assert(state.isUnauthenticated == false);
        assert(state.isLoading == false);
        assert(state.hasError == false);
        assert(state.user == user);
        assert(state.errorMessage == null);
      },
      unauthenticated: () {
        assert(state.isAuthenticated == false);
        assert(state.isUnauthenticated == true);
        assert(state.isLoading == false);
        assert(state.hasError == false);
        assert(state.user == null);
        assert(state.errorMessage == null);
      },
      loading: () {
        assert(state.isAuthenticated == false);
        assert(state.isUnauthenticated == false);
        assert(state.isLoading == true);
        assert(state.hasError == false);
        assert(state.user == null);
        assert(state.errorMessage == null);
      },
      error: (message, code) {
        assert(state.isAuthenticated == false);
        assert(state.isUnauthenticated == false);
        assert(state.isLoading == false);
        assert(state.hasError == true);
        assert(state.user == null);
        assert(state.errorMessage == message);
      },
    );
  }

  /// Common test data constants
  static const String validEmail = 'test@example.com';
  static const String invalidEmail = 'invalid-email';
  static const String validPassword = 'password123';
  static const String weakPassword = '123';
  static const String validName = 'Test User';
  static const String shortName = 'A';
  static const String validUserId = 'test-user-123';

  /// Test data generation utilities
  static String generateRandomEmail([int index = 0]) {
    return 'test$index@example.com';
  }

  static String generateRandomUserId([int index = 0]) {
    return 'test-user-$index';
  }

  static String generateRandomName([int index = 0]) {
    return 'Test User $index';
  }

  static DateTime generateRandomDate({
    int minDaysAgo = 0,
    int maxDaysAgo = 365,
  }) {
    final random =
        DateTime.now().millisecondsSinceEpoch % (maxDaysAgo - minDaysAgo);
    return DateTime.now().subtract(Duration(days: minDaysAgo + random));
  }
}
