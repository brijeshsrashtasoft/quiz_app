import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/network_info.dart';
import '../../core/firebase/firestore_config.dart';
import '../../core/firebase/auth_config.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../../features/authentication/data/datasources/user_firestore_datasource.dart';
import '../../features/authentication/data/models/user_model.dart';
import '../../features/game_session/domain/entities/game_session_entity.dart';
import '../../features/leaderboard/domain/entities/leaderboard_entity.dart';

/// Firebase service providers following CLAUDE.md Riverpod patterns
/// These providers will be implemented by firebase-specialist

/// Network information provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return AuthConfig.instance;
});

/// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirestoreConfig.instance;
});

/// Firebase Storage instance provider
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Current user stream provider
final currentUserProvider = StreamProvider<User?>((ref) {
  return AuthConfig.authStateChanges;
});

/// Current user ID provider
final currentUserIdProvider = Provider<String?>((ref) {
  return AuthConfig.currentUserId;
});

/// Authentication status provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return AuthConfig.isAuthenticated;
});

/// Authentication state provider
final authStateProvider = StateProvider<AuthState>((ref) {
  return AuthState.initial;
});

/// Authentication state enum
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Firestore connection state provider
final firestoreConnectionProvider = FutureProvider<bool>((ref) {
  return FirestoreConfig.checkConnectivity();
});

/// Collection reference providers
final usersCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>((ref) {
      return FirestoreConfig.usersCollection;
    });

final quizzesCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>((ref) {
      return FirestoreConfig.quizzesCollection;
    });

final gameSessionsCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>((ref) {
      return FirestoreConfig.gameSessionsCollection;
    });

final leaderboardsCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>((ref) {
      return FirestoreConfig.leaderboardsCollection;
    });

/// Real-time stream providers for live updates
/// Following CLAUDE.md <200ms latency requirements

/// Stream provider for user data with real-time updates
final userStreamProvider = StreamProvider.family<Result<UserModel>, String>((ref, userId) {
  final dataSource = ref.watch(userDataSourceProvider);
  return dataSource.watchUser(userId);
});

/// Stream provider for game session updates
final gameSessionStreamProvider = 
    StreamProvider.family<Result<GameSessionEntity>, String>((ref, sessionId) {
  return FirestoreConfig.gameSessionsCollection
      .doc(sessionId)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) {
          return Result.failure(
            const Failure.firestoreFailure(
              message: 'Game session not found',
              code: 'session_not_found',
            ),
          );
        }
        
        try {
          final data = snapshot.data()!;
          data['id'] = snapshot.id;
          return Result.success(GameSessionEntity.fromMap(data));
        } catch (e) {
          return Result.failure(
            Failure.firestoreFailure(
              message: 'Failed to parse game session: ${e.toString()}',
              code: 'parse_error',
            ),
          );
        }
      });
});

/// Stream provider for live leaderboard updates
final leaderboardStreamProvider = 
    StreamProvider.family<Result<LeaderboardEntity>, String>((ref, sessionId) {
  return FirestoreConfig.leaderboardsCollection
      .doc(sessionId)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) {
          return Result.failure(
            const Failure.firestoreFailure(
              message: 'Leaderboard not found',
              code: 'leaderboard_not_found',
            ),
          );
        }
        
        try {
          final data = snapshot.data()!;
          data['id'] = snapshot.id;
          return Result.success(LeaderboardEntity.fromMap(data));
        } catch (e) {
          return Result.failure(
            Failure.firestoreFailure(
              message: 'Failed to parse leaderboard: ${e.toString()}',
              code: 'parse_error',
            ),
          );
        }
      });
});

/// Performance-optimized providers with caching
/// Following CLAUDE.md performance requirements

/// Cached user data provider
final cachedUserProvider = FutureProvider.family<Result<UserModel>, String>((ref, userId) async {
  final dataSource = ref.watch(userDataSourceProvider);
  return await dataSource.getUserById(userId);
});

/// Data source providers
final userDataSourceProvider = Provider<UserFirestoreDataSource>((ref) {
  return UserFirestoreDataSource();
});

/// Error integration providers
/// Ensuring Firebase errors integrate with core Failure system

/// Firebase error handler provider
final firebaseErrorHandlerProvider = Provider<FirebaseErrorHandler>((ref) {
  return FirebaseErrorHandler();
});

/// Firebase error handler class
class FirebaseErrorHandler {
  /// Convert Firebase exception to Failure
  Failure handleFirebaseException(dynamic exception) {
    final exceptionString = exception.toString().toLowerCase();
    
    if (exceptionString.contains('permission-denied')) {
      return const Failure.authFailure(
        message: 'Permission denied',
        code: 'permission_denied',
      );
    }
    
    if (exceptionString.contains('not-found')) {
      return const Failure.firestoreFailure(
        message: 'Document not found',
        code: 'not_found',
      );
    }
    
    if (exceptionString.contains('unavailable')) {
      return const Failure.networkFailure(
        message: 'Service unavailable',
      );
    }
    
    if (exceptionString.contains('deadline-exceeded')) {
      return const Failure.networkFailure(
        message: 'Request timeout',
      );
    }
    
    return Failure.firestoreFailure(
      message: 'Firebase operation failed',
      code: 'unknown_firebase_error',
    );
  }
}
