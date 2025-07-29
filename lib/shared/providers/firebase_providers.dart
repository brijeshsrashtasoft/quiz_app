import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/network_info.dart';
import '../../core/firebase/firestore_config.dart';
import '../../core/firebase/auth_config.dart';

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
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Firestore connection state provider
final firestoreConnectionProvider = FutureProvider<bool>((ref) {
  return FirestoreConfig.checkConnectivity();
});

/// Collection reference providers
final usersCollectionProvider = Provider<CollectionReference<Map<String, dynamic>>>((ref) {
  return FirestoreConfig.usersCollection;
});

final quizzesCollectionProvider = Provider<CollectionReference<Map<String, dynamic>>>((ref) {
  return FirestoreConfig.quizzesCollection;
});

final gameSessionsCollectionProvider = Provider<CollectionReference<Map<String, dynamic>>>((ref) {
  return FirestoreConfig.gameSessionsCollection;
});

final leaderboardsCollectionProvider = Provider<CollectionReference<Map<String, dynamic>>>((ref) {
  return FirestoreConfig.leaderboardsCollection;
});