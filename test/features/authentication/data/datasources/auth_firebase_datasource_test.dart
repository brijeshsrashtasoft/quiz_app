import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quiz_app/features/authentication/data/datasources/auth_firebase_datasource.dart';
import 'package:quiz_app/core/utils/result.dart';
import 'package:quiz_app/core/errors/exceptions.dart';

import 'auth_firebase_datasource_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth, 
  User, 
  UserCredential, 
  GoogleSignIn, 
  GoogleSignInAccount,
  GoogleSignInAuthentication,
])
void main() {
  group('AuthFirebaseDataSource - Google Sign-In Tests', () {
    late AuthFirebaseDataSource dataSource;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
      
      dataSource = AuthFirebaseDataSource();
    });

    group('signInWithGoogle', () {
      test('should return UserModel when Google sign-in is successful', () async {
        // Arrange
        const email = 'test@gmail.com';
        const displayName = 'Test User';
        const uid = 'test_uid';
        const photoUrl = 'https://example.com/photo.jpg';
        const accessToken = 'mock_access_token';
        const idToken = 'mock_id_token';

        when(mockGoogleSignInAccount.email).thenReturn(email);
        when(mockGoogleSignInAccount.displayName).thenReturn(displayName);
        when(mockGoogleSignInAccount.photoUrl).thenReturn(photoUrl);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuthentication);
        
        when(mockGoogleSignInAuthentication.accessToken).thenReturn(accessToken);
        when(mockGoogleSignInAuthentication.idToken).thenReturn(idToken);
        
        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(displayName);
        when(mockUser.photoURL).thenReturn(photoUrl);
        when(mockUser.metadata).thenReturn(MockUserMetadata());
        
        when(mockUserCredential.user).thenReturn(mockUser);

        // Act
        final result = await dataSource.signInWithGoogle();

        // Assert
        expect(result.isSuccess, true);
        final userModel = result.dataOrNull;
        expect(userModel?.email, email);
        expect(userModel?.name, displayName);
      });

      test('should return failure when user cancels Google sign-in', () async {
        // Arrange - Mock Google sign-in cancellation
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        // Act
        final result = await dataSource.signInWithGoogle();

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull?.message, contains('cancelled'));
      });

      test('should return failure when GoogleSignInAccount authentication fails', () async {
        // Arrange
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenThrow(Exception('Authentication failed'));

        // Act
        final result = await dataSource.signInWithGoogle();

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull?.message, contains('Google sign in'));
      });

      test('should return failure when Firebase Auth credential sign-in fails', () async {
        // Arrange
        const accessToken = 'mock_access_token';
        const idToken = 'mock_id_token';

        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuthentication);
        when(mockGoogleSignInAuthentication.accessToken).thenReturn(accessToken);
        when(mockGoogleSignInAuthentication.idToken).thenReturn(idToken);
        
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenThrow(FirebaseAuthException(code: 'network-request-failed'));

        // Act
        final result = await dataSource.signInWithGoogle();

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull?.message, contains('network-request-failed'));
      });

      test('should return failure when Firebase returns null user', () async {
        // Arrange
        const accessToken = 'mock_access_token';
        const idToken = 'mock_id_token';

        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuthentication);
        when(mockGoogleSignInAuthentication.accessToken).thenReturn(accessToken);
        when(mockGoogleSignInAuthentication.idToken).thenReturn(idToken);
        
        when(mockUserCredential.user).thenReturn(null);
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await dataSource.signInWithGoogle();

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull?.message, contains('no user returned'));
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        when(mockGoogleSignIn.signIn())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.signInWithGoogle();

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull?.message, contains('Network error'));
      });

      test('should handle account disabled errors', () async {
        // Arrange
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuthentication);
        when(mockGoogleSignInAuthentication.accessToken).thenReturn('token');
        when(mockGoogleSignInAuthentication.idToken).thenReturn('id_token');
        
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenThrow(FirebaseAuthException(
              code: 'user-disabled',
              message: 'Account has been disabled',
            ));

        // Act
        final result = await dataSource.signInWithGoogle();

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull?.message, contains('user-disabled'));
      });
    });

    group('signOut with Google', () {
      test('should sign out from both Google and Firebase when Google user exists', () async {
        // Arrange
        when(mockGoogleSignIn.currentUser).thenReturn(mockGoogleSignInAccount);
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // Act
        final result = await dataSource.signOut();

        // Assert
        expect(result.isSuccess, true);
        verify(mockGoogleSignIn.signOut()).called(1);
        verify(mockFirebaseAuth.signOut()).called(1);
      });

      test('should only sign out from Firebase when no Google user', () async {
        // Arrange
        when(mockGoogleSignIn.currentUser).thenReturn(null);
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // Act
        final result = await dataSource.signOut();

        // Assert
        expect(result.isSuccess, true);
        verifyNever(mockGoogleSignIn.signOut());
        verify(mockFirebaseAuth.signOut()).called(1);
      });

      test('should handle Google sign-out errors gracefully', () async {
        // Arrange
        when(mockGoogleSignIn.currentUser).thenReturn(mockGoogleSignInAccount);
        when(mockGoogleSignIn.signOut()).thenThrow(Exception('Google sign-out failed'));
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // Act
        final result = await dataSource.signOut();

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull?.message, contains('sign out'));
      });
    });
  });
}

// Mock UserMetadata for testing
class MockUserMetadata extends Mock implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();
  
  @override
  DateTime? get lastSignInTime => DateTime.now();
}