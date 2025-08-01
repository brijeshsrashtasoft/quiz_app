import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/shared/widgets/buttons/google_signin_button.dart';
import 'package:quiz_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/failures.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'google_signin_button_test.mocks.dart';

// Mock classes
@GenerateMocks([GoRouter, User])
class MockAuthService extends Mock {
  Future<Result<User>> signInWithGoogle() =>
      (this as dynamic).signInWithGoogle();
}

void main() {
  group('GoogleSignInButton Widget Tests', () {
    late MockGoRouter mockGoRouter;
    late MockAuthService mockAuthService;
    late ProviderContainer container;

    setUp(() {
      mockGoRouter = MockGoRouter();
      mockAuthService = MockAuthService();
      
      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    Widget createTestWidget({
      String? label,
      VoidCallback? onSuccess,
      VoidCallback? onError,
      bool showIcon = true,
      bool isCompact = false,
    }) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              label: label ?? 'Continue with Google',
              onSuccess: onSuccess,
              onError: onError,
              showIcon: showIcon,
              isCompact: isCompact,
            ),
          ),
        ),
      );
    }

    group('UI Rendering', () {
      testWidgets('should display default label when no label provided', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Continue with Google'), findsOneWidget);
      });

      testWidgets('should display custom label when provided', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(label: 'Sign in with Google'));

        // Assert
        expect(find.text('Sign in with Google'), findsOneWidget);
      });

      testWidgets('should show Google icon when showIcon is true', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(showIcon: true));

        // Assert
        expect(find.text('G'), findsOneWidget); // Our placeholder Google icon
      });

      testWidgets('should hide Google icon when showIcon is false', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(showIcon: false));

        // Assert
        expect(find.text('G'), findsNothing);
      });

      testWidgets('should render compact version when isCompact is true', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          label: 'Google',
          isCompact: true,
          showIcon: true,
        ));

        // Assert
        expect(find.text('Google'), findsOneWidget);
        expect(find.text('G'), findsOneWidget);
      });

      testWidgets('should have correct semantics for accessibility', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final semantics = tester.getSemantics(find.byType(GoogleSignInButton));
        expect(semantics.hasFlag(SemanticsFlag.isButton), true);
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), true);
        expect(semantics.label, 'Continue with Google');
      });
    });

    group('User Interactions', () {
      testWidgets('should call signInWithGoogle when tapped', (tester) async {
        // Arrange
        final mockUser = MockUser();
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => Result.success(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byType(GoogleSignInButton));
        await tester.pump();

        // Assert
        verify(mockAuthService.signInWithGoogle()).called(1);
      });

      testWidgets('should show loading indicator during sign-in', (tester) async {
        // Arrange
        final mockUser = MockUser();
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) => Future.delayed(
              const Duration(milliseconds: 100),
              () => Result.success(mockUser),
            ));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byType(GoogleSignInButton));
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Signing in...'), findsOneWidget);

        // Wait for completion
        await tester.pumpAndSettle();
      });

      testWidgets('should call onSuccess callback when sign-in succeeds', (tester) async {
        // Arrange
        final mockUser = MockUser();
        bool onSuccessCalled = false;
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => Result.success(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          onSuccess: () => onSuccessCalled = true,
        ));
        await tester.tap(find.byType(GoogleSignInButton));
        await tester.pumpAndSettle();

        // Assert
        expect(onSuccessCalled, true);
      });

      testWidgets('should call onError callback when sign-in fails', (tester) async {
        // Arrange
        bool onErrorCalled = false;
        const failure = Failure.authFailure(
          message: 'Google sign-in failed',
          code: 'google_signin_error',
        );
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => const Result.failure(failure));

        // Act
        await tester.pumpWidget(createTestWidget(
          onError: () => onErrorCalled = true,
        ));
        await tester.tap(find.byType(GoogleSignInButton));
        await tester.pumpAndSettle();

        // Assert
        expect(onErrorCalled, true);
      });

      testWidgets('should show error snackbar when sign-in fails', (tester) async {
        // Arrange
        const failure = Failure.authFailure(
          message: 'Google sign-in failed',
          code: 'google_signin_error',
        );
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => const Result.failure(failure));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byType(GoogleSignInButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Authentication error: Google sign-in failed'), findsOneWidget);
      });

      testWidgets('should disable button during loading', (tester) async {
        // Arrange
        final mockUser = MockUser();
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) => Future.delayed(
              const Duration(milliseconds: 100),
              () => Result.success(mockUser),
            ));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byType(GoogleSignInButton));
        await tester.pump();

        // Try to tap again during loading
        await tester.tap(find.byType(GoogleSignInButton));
        await tester.pump();

        // Assert - only one call should be made
        await tester.pumpAndSettle();
        verify(mockAuthService.signInWithGoogle()).called(1);
      });

      testWidgets('should handle user cancellation gracefully', (tester) async {
        // Arrange
        const failure = Failure.authFailure(
          message: 'Sign in cancelled',
          code: 'google_signin_cancelled',
        );
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => const Result.failure(failure));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byType(GoogleSignInButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Authentication error: Sign in cancelled'), findsOneWidget);
      });

      testWidgets('should handle network errors with appropriate message', (tester) async {
        // Arrange
        const failure = Failure.networkFailure(
          message: 'No internet connection',
        );
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => const Result.failure(failure));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byType(GoogleSignInButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Network error: No internet connection'), findsOneWidget);
      });
    });

    group('CompactGoogleSignInButton', () {
      testWidgets('should render compact version with correct properties', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: CompactGoogleSignInButton(),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Google'), findsOneWidget);
        expect(find.text('G'), findsOneWidget);
      });

      testWidgets('should call callbacks when provided', (tester) async {
        // Arrange
        bool onSuccessCalled = false;
        bool onErrorCalled = false;
        final mockUser = MockUser();
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => Result.success(mockUser));

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: CompactGoogleSignInButton(
                  onSuccess: () => onSuccessCalled = true,
                  onError: () => onErrorCalled = true,
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(CompactGoogleSignInButton));
        await tester.pumpAndSettle();

        // Assert
        expect(onSuccessCalled, true);
        expect(onErrorCalled, false);
      });
    });

    group('Animation Tests', () {
      testWidgets('should animate scale on tap down and up', (tester) async {
        // Arrange
        final mockUser = MockUser();
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => Result.success(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget());
        
        // Tap down
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(GoogleSignInButton)),
        );
        await tester.pump();

        // Tap up
        await gesture.up();
        await tester.pumpAndSettle();

        // Assert - Animation should complete without errors
        expect(tester.takeException(), isNull);
      });
    });
  });
}