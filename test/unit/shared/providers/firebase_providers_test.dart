import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:quiz_app/shared/providers/firebase_providers.dart';
import 'package:quiz_app/core/network/network_info.dart';

// Generate mocks for testing providers
@GenerateMocks([
  NetworkInfo,
  FirebaseAuth,
  FirebaseFirestore,
  User,
])
import 'firebase_providers_test.mocks.dart';

void main() {
  group('Firebase Providers', () {
    late ProviderContainer container;
    late MockNetworkInfo mockNetworkInfo;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;

    setUp(() {
      mockNetworkInfo = MockNetworkInfo();
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      
      container = ProviderContainer(
        overrides: [
          // Override providers with mocks for testing
          networkInfoProvider.overrideWithValue(mockNetworkInfo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('networkInfoProvider', () {
      test('should provide NetworkInfo instance', () {
        // Act
        final networkInfo = container.read(networkInfoProvider);
        
        // Assert
        expect(networkInfo, isA<NetworkInfo>());
      });
    });

    group('firebaseAuthProvider', () {
      test('should provide FirebaseAuth instance', () {
        // Act
        final auth = container.read(firebaseAuthProvider);
        
        // Assert
        expect(auth, isA<FirebaseAuth>());
      });
    });

    group('firestoreProvider', () {
      test('should provide FirebaseFirestore instance', () {
        // Act
        final firestore = container.read(firestoreProvider);
        
        // Assert
        expect(firestore, isA<FirebaseFirestore>());
      });
    });

    group('currentUserProvider', () {
      test('should provide user stream', () {
        // Act
        final userAsync = container.read(currentUserProvider);
        
        // Assert
        expect(userAsync, isA<AsyncValue<User?>>());
      });
    });

    group('currentUserIdProvider', () {
      test('should provide current user ID', () {
        // Act
        final userId = container.read(currentUserIdProvider);
        
        // Assert
        expect(userId, isA<String?>());
      });
    });

    group('isAuthenticatedProvider', () {
      test('should provide authentication status', () {
        // Act
        final isAuthenticated = container.read(isAuthenticatedProvider);
        
        // Assert
        expect(isAuthenticated, isA<bool>());
      });
    });

    group('authStateProvider', () {
      test('should provide initial auth state', () {
        // Act
        final authState = container.read(authStateProvider);
        
        // Assert
        expect(authState, equals(AuthState.initial));
        expect(authState, isA<AuthState>());
      });

      test('should allow state updates', () {
        // Act
        container.read(authStateProvider.notifier).state = AuthState.loading;
        final authState = container.read(authStateProvider);
        
        // Assert
        expect(authState, equals(AuthState.loading));
      });
    });

    group('firestoreConnectionProvider', () {
      test('should provide connectivity status', () async {
        // Act
        final connectivityFuture = container.read(firestoreConnectionProvider.future);
        
        // Assert
        expect(connectivityFuture, isA<Future<bool>>());
        
        // Wait for the future to complete
        final connectivity = await connectivityFuture;
        expect(connectivity, isA<bool>());
      });
    });

    group('collection providers', () {
      test('usersCollectionProvider should provide users collection', () {
        // Act
        final usersCollection = container.read(usersCollectionProvider);
        
        // Assert
        expect(usersCollection, isA<CollectionReference<Map<String, dynamic>>>());
      });

      test('quizzesCollectionProvider should provide quizzes collection', () {
        // Act
        final quizzesCollection = container.read(quizzesCollectionProvider);
        
        // Assert
        expect(quizzesCollection, isA<CollectionReference<Map<String, dynamic>>>());
      });

      test('gameSessionsCollectionProvider should provide game sessions collection', () {
        // Act
        final gameSessionsCollection = container.read(gameSessionsCollectionProvider);
        
        // Assert
        expect(gameSessionsCollection, isA<CollectionReference<Map<String, dynamic>>>());
      });

      test('leaderboardsCollectionProvider should provide leaderboards collection', () {
        // Act
        final leaderboardsCollection = container.read(leaderboardsCollectionProvider);
        
        // Assert
        expect(leaderboardsCollection, isA<CollectionReference<Map<String, dynamic>>>());
      });
    });
  });

  group('AuthState enum', () {
    test('should have all required states', () {
      // Assert
      expect(AuthState.values, contains(AuthState.initial));
      expect(AuthState.values, contains(AuthState.loading));
      expect(AuthState.values, contains(AuthState.authenticated));
      expect(AuthState.values, contains(AuthState.unauthenticated));
      expect(AuthState.values, contains(AuthState.error));
    });

    test('should have correct number of states', () {
      expect(AuthState.values.length, equals(5));
    });
  });

  group('Provider integration', () {
    test('should work together in provider ecosystem', () {
      // Test that providers work together without conflicts
      final container = ProviderContainer();
      
      // Act - Read multiple providers
      final networkInfo = container.read(networkInfoProvider);
      final auth = container.read(firebaseAuthProvider);
      final firestore = container.read(firestoreProvider);
      final authState = container.read(authStateProvider);
      
      // Assert
      expect(networkInfo, isNotNull);
      expect(auth, isNotNull);
      expect(firestore, isNotNull);
      expect(authState, isNotNull);
      
      container.dispose();
    });

    test('should handle provider dependencies correctly', () {
      final container = ProviderContainer();
      
      // Test reading providers that depend on other providers
      expect(() => container.read(usersCollectionProvider), returnsNormally);
      expect(() => container.read(currentUserIdProvider), returnsNormally);
      expect(() => container.read(isAuthenticatedProvider), returnsNormally);
      
      container.dispose();
    });
  });

  group('Provider lifecycle', () {
    test('should dispose providers correctly', () {
      final container = ProviderContainer();
      
      // Read some providers
      container.read(networkInfoProvider);
      container.read(authStateProvider);
      
      // Dispose should not throw
      expect(() => container.dispose(), returnsNormally);
    });

    test('should handle provider updates', () {
      final container = ProviderContainer();
      
      // Initial state
      expect(container.read(authStateProvider), equals(AuthState.initial));
      
      // Update state
      container.read(authStateProvider.notifier).state = AuthState.authenticated;
      expect(container.read(authStateProvider), equals(AuthState.authenticated));
      
      // Update again
      container.read(authStateProvider.notifier).state = AuthState.error;
      expect(container.read(authStateProvider), equals(AuthState.error));
      
      container.dispose();
    });
  });
}