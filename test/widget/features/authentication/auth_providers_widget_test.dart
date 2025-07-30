import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:quiz_app/features/authentication/domain/entities/user_entity.dart';
import 'package:quiz_app/features/authentication/domain/entities/auth_entity.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:quiz_app/features/authentication/domain/repositories/auth_repository.dart';
import '../../../test_config.dart';

import 'auth_providers_widget_test.mocks.dart';

// Generate mocks using build_runner
@GenerateMocks([AuthRepository, User])
void main() {
  late MockAuthRepository mockAuthRepository;
  late MockUser mockFirebaseUser;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockFirebaseUser = MockUser();
  });

  // Test data
  final testUserEntity = UserEntity(
    id: 'test-user-id',
    name: 'Test User',
    email: 'test@example.com',
    createdAt: DateTime.now(),
  );

  final testAuthUser = AuthUser(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    photoURL: null,
  );

  final testAuthEntity = AuthEntity(
    user: testAuthUser,
    isEmailVerified: true,
    lastSignInTime: DateTime.now(),
    creationTime: DateTime.now(),
  );

  testGroup('Authentication Providers Widget Tests', TestCategory.widget, () {
    testGroup('AuthState Provider Tests', () {
      widgetTestCase(
        'should show unauthenticated state when no user',
        TestCategory.widget,
        (tester) async {
          // Arrange
          when(
            mockAuthRepository.authStateChanges(),
          ).thenAnswer((_) => Stream.value(null));

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authRepositoryProvider.overrideWithValue(mockAuthRepository),
              ],
              child: TestWrappers.materialApp(
                child: Consumer(
                  builder: (context, ref, child) {
                    final authState = ref.watch(authStateProvider);
                    return authState.when(
                      data: (state) => Text(
                        state?.isAuthenticated == true
                            ? 'Authenticated'
                            : 'Unauthenticated',
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Assert
          expect(find.text('Unauthenticated'), findsOneWidget);
          expect(find.text('Authenticated'), findsNothing);
        },
      );

      widgetTestCase(
        'should show authenticated state with user data',
        TestCategory.widget,
        (tester) async {
          // Arrange
          when(mockFirebaseUser.uid).thenReturn('test-user-id');
          when(mockFirebaseUser.email).thenReturn('test@example.com');
          when(mockFirebaseUser.displayName).thenReturn('Test User');
          when(mockFirebaseUser.emailVerified).thenReturn(true);

          when(
            mockAuthRepository.authStateChanges(),
          ).thenAnswer((_) => Stream.value(mockFirebaseUser));

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authRepositoryProvider.overrideWithValue(mockAuthRepository),
              ],
              child: TestWrappers.materialApp(
                child: Consumer(
                  builder: (context, ref, child) {
                    final authState = ref.watch(authStateProvider);
                    return authState.when(
                      data: (state) => Column(
                        children: [
                          Text(
                            state?.isAuthenticated == true
                                ? 'Authenticated'
                                : 'Unauthenticated',
                          ),
                          if (state?.user != null)
                            Text('User: ${state!.user.email}'),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Assert
          expect(find.text('Authenticated'), findsOneWidget);
          expect(find.text('User: test@example.com'), findsOneWidget);
        },
      );

      widgetTestCase(
        'should handle authentication state transitions',
        TestCategory.widget,
        (tester) async {
          // Arrange
          final controller = StreamController<User?>();
          when(
            mockAuthRepository.authStateChanges(),
          ).thenAnswer((_) => controller.stream);

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authRepositoryProvider.overrideWithValue(mockAuthRepository),
              ],
              child: TestWrappers.materialApp(
                child: Consumer(
                  builder: (context, ref, child) {
                    final authState = ref.watch(authStateProvider);
                    return authState.when(
                      data: (state) => Text(
                        state?.isAuthenticated == true
                            ? 'Authenticated'
                            : 'Unauthenticated',
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    );
                  },
                ),
              ),
            ),
          );

          // Initially unauthenticated
          controller.add(null);
          await tester.pumpAndSettle();
          expect(find.text('Unauthenticated'), findsOneWidget);

          // Then authenticated
          when(mockFirebaseUser.uid).thenReturn('test-user-id');
          when(mockFirebaseUser.email).thenReturn('test@example.com');
          controller.add(mockFirebaseUser);
          await tester.pumpAndSettle();
          expect(find.text('Authenticated'), findsOneWidget);

          // Then unauthenticated again
          controller.add(null);
          await tester.pumpAndSettle();
          expect(find.text('Unauthenticated'), findsOneWidget);

          controller.close();
        },
      );
    });

    testGroup('Current User Provider Tests', () {
      widgetTestCase(
        'should provide current user when authenticated',
        TestCategory.widget,
        (tester) async {
          // Arrange
          when(
            mockAuthRepository.getCurrentUser(),
          ).thenReturn(mockFirebaseUser);
          when(mockAuthRepository.isAuthenticated).thenReturn(true);
          when(mockFirebaseUser.uid).thenReturn('test-user-id');
          when(mockFirebaseUser.email).thenReturn('test@example.com');

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authRepositoryProvider.overrideWithValue(mockAuthRepository),
              ],
              child: TestWrappers.materialApp(
                child: Consumer(
                  builder: (context, ref, child) {
                    final currentUser = ref.watch(currentFirebaseUserProvider);
                    return Text(currentUser?.email ?? 'No user');
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Assert
          expect(find.text('test@example.com'), findsOneWidget);
          expect(find.text('No user'), findsNothing);
        },
      );

      widgetTestCase(
        'should show no user when not authenticated',
        TestCategory.widget,
        (tester) async {
          // Arrange
          when(mockAuthRepository.getCurrentUser()).thenReturn(null);
          when(mockAuthRepository.isAuthenticated).thenReturn(false);

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authRepositoryProvider.overrideWithValue(mockAuthRepository),
              ],
              child: TestWrappers.materialApp(
                child: Consumer(
                  builder: (context, ref, child) {
                    final currentUser = ref.watch(currentFirebaseUserProvider);
                    return Text(currentUser?.email ?? 'No user');
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Assert
          expect(find.text('No user'), findsOneWidget);
        },
      );
    });

    testGroup('Authentication Status Provider Tests', () {
      widgetTestCase(
        'should reflect authentication status correctly',
        TestCategory.widget,
        (tester) async {
          // Arrange
          when(mockAuthRepository.isAuthenticated).thenReturn(true);

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authRepositoryProvider.overrideWithValue(mockAuthRepository),
              ],
              child: TestWrappers.materialApp(
                child: Consumer(
                  builder: (context, ref, child) {
                    final isAuthenticated = ref.watch(isAuthenticatedProvider);
                    return Text(isAuthenticated ? 'Logged In' : 'Logged Out');
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Assert
          expect(find.text('Logged In'), findsOneWidget);
          expect(find.text('Logged Out'), findsNothing);
        },
      );

      widgetTestCase(
        'should update when authentication status changes',
        TestCategory.widget,
        (tester) async {
          // Arrange
          when(mockAuthRepository.isAuthenticated).thenReturn(false);

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authRepositoryProvider.overrideWithValue(mockAuthRepository),
              ],
              child: TestWrappers.materialApp(
                child: Consumer(
                  builder: (context, ref, child) {
                    final isAuthenticated = ref.watch(isAuthenticatedProvider);
                    return Column(
                      children: [
                        Text(isAuthenticated ? 'Logged In' : 'Logged Out'),
                        ElevatedButton(
                          onPressed: () {
                            // Simulate authentication status change
                            when(
                              mockAuthRepository.isAuthenticated,
                            ).thenReturn(true);
                            ref.invalidate(isAuthenticatedProvider);
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Initially logged out
          expect(find.text('Logged Out'), findsOneWidget);

          // Tap login button
          await tester.tap(find.text('Login'));
          await tester.pumpAndSettle();

          // Should now be logged in
          expect(find.text('Logged In'), findsOneWidget);
        },
      );
    });

    testGroup('User ID Provider Tests', () {
      widgetTestCase(
        'should provide current user ID when authenticated',
        TestCategory.widget,
        (tester) async {
          // Arrange
          const userId = 'test-user-123';
          when(mockAuthRepository.currentUserId).thenReturn(userId);

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authRepositoryProvider.overrideWithValue(mockAuthRepository),
              ],
              child: TestWrappers.materialApp(
                child: Consumer(
                  builder: (context, ref, child) {
                    final currentUserId = ref.watch(currentUserIdProvider);
                    return Text(currentUserId ?? 'No ID');
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Assert
          expect(find.text(userId), findsOneWidget);
          expect(find.text('No ID'), findsNothing);
        },
      );
    });

    testGroup('Auth Service Provider Tests', () {
      widgetTestCase(
        'should provide auth service instance',
        TestCategory.widget,
        (tester) async {
          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              child: TestWrappers.materialApp(
                child: Consumer(
                  builder: (context, ref, child) {
                    final authService = ref.watch(authServiceProvider);
                    return Text(
                      authService != null ? 'Service Available' : 'No Service',
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Assert
          expect(find.text('Service Available'), findsOneWidget);
        },
      );
    });

    testGroup('Error Handling Widget Tests', () {
      widgetTestCase(
        'should handle auth provider errors gracefully',
        TestCategory.widget,
        (tester) async {
          // Arrange
          when(
            mockAuthRepository.authStateChanges(),
          ).thenAnswer((_) => Stream.error(Exception('Auth error')));

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authRepositoryProvider.overrideWithValue(mockAuthRepository),
              ],
              child: TestWrappers.materialApp(
                child: Consumer(
                  builder: (context, ref, child) {
                    final authState = ref.watch(authStateProvider);
                    return authState.when(
                      data: (state) => const Text('Data loaded'),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) =>
                          Text('Error occurred: ${error.toString()}'),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Assert
          expect(find.textContaining('Error occurred'), findsOneWidget);
        },
      );

      widgetTestCase(
        'should show loading state during auth operations',
        TestCategory.widget,
        (tester) async {
          // Arrange
          final controller = StreamController<User?>();
          when(
            mockAuthRepository.authStateChanges(),
          ).thenAnswer((_) => controller.stream);

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authRepositoryProvider.overrideWithValue(mockAuthRepository),
              ],
              child: TestWrappers.materialApp(
                child: Consumer(
                  builder: (context, ref, child) {
                    final authState = ref.watch(authStateProvider);
                    return authState.when(
                      data: (state) => const Text('Data loaded'),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    );
                  },
                ),
              ),
            ),
          );

          // Should show loading initially
          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          // Add data to stream
          controller.add(null);
          await tester.pumpAndSettle();

          // Should show data now
          expect(find.text('Data loaded'), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);

          controller.close();
        },
      );
    });

    testGroup('Performance Widget Tests', () {
      widgetTestCase(
        'should rebuild efficiently on auth state changes',
        TestCategory.widget,
        (tester) async {
          // Arrange
          var buildCount = 0;
          final controller = StreamController<User?>();

          when(
            mockAuthRepository.authStateChanges(),
          ).thenAnswer((_) => controller.stream);

          // Act
          await tester.pumpWidget(
            TestWrappers.providerScope(
              overrides: [
                authRepositoryProvider.overrideWithValue(mockAuthRepository),
              ],
              child: TestWrappers.materialApp(
                child: Consumer(
                  builder: (context, ref, child) {
                    buildCount++;
                    final authState = ref.watch(authStateProvider);
                    return authState.when(
                      data: (state) => Text('Build: $buildCount'),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    );
                  },
                ),
              ),
            ),
          );

          // Initial build
          expect(buildCount, equals(1));

          // Add same state - should not rebuild unnecessarily
          controller.add(null);
          await tester.pumpAndSettle();

          // Should have rebuilt due to stream change
          expect(buildCount, equals(2));

          controller.close();
        },
      );
    });
  });
}

/// Mock auth repository provider for testing
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Use override in tests');
});
