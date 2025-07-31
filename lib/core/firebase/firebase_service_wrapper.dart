import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import 'firebase_core_config.dart';
import 'web_firebase_config.dart';

/// Firebase service wrapper that handles web JavaScript interop issues gracefully
/// Following CLAUDE.md Firebase integration patterns
class FirebaseServiceWrapper {
  static FirebaseServiceWrapper? _instance;
  static FirebaseServiceWrapper get instance => _instance ??= FirebaseServiceWrapper._();

  FirebaseServiceWrapper._();

  /// Get Firebase Auth instance safely
  FirebaseAuth? get auth {
    try {
      if (!FirebaseCoreConfig.isAvailable) {
        AppLogger.warning('Firebase Auth not available - offline mode');
        return null;
      }
      return FirebaseAuth.instance;
    } catch (e) {
      AppLogger.warning('Firebase Auth access failed', e);
      return null;
    }
  }

  /// Get Firestore instance safely
  FirebaseFirestore? get firestore {
    try {
      if (!FirebaseCoreConfig.isAvailable) {
        AppLogger.warning('Firestore not available - offline mode');
        return null;
      }
      return FirebaseFirestore.instance;
    } catch (e) {
      AppLogger.warning('Firestore access failed', e);
      return null;
    }
  }

  /// Get Firebase Storage instance safely
  FirebaseStorage? get storage {
    try {
      if (!FirebaseCoreConfig.isAvailable) {
        AppLogger.warning('Firebase Storage not available - offline mode');
        return null;
      }
      return FirebaseStorage.instance;
    } catch (e) {
      AppLogger.warning('Firebase Storage access failed', e);
      return null;
    }
  }

  /// Check if Firebase services are available
  bool get isAvailable => FirebaseCoreConfig.isAvailable;

  /// Check if running in offline mode
  bool get isOfflineMode => FirebaseCoreConfig.isOfflineMode;

  /// Execute Firebase operation with error handling
  Future<T?> executeFirebaseOperation<T>(
    Future<T> Function() operation, {
    String operationName = 'Firebase Operation',
    T? fallbackValue,
  }) async {
    try {
      if (!isAvailable) {
        AppLogger.warning('$operationName skipped - Firebase not available');
        return fallbackValue;
      }

      return await operation();
    } catch (e, stackTrace) {
      if (kIsWeb && _isWebFirebaseError(e)) {
        AppLogger.warning(
          '$operationName failed due to web Firebase error - using fallback',
          e,
        );
        return fallbackValue;
      }

      AppLogger.error('$operationName failed', e, stackTrace);
      return fallbackValue;
    }
  }

  /// Execute Firestore operation with error handling
  Future<T?> executeFirestoreOperation<T>(
    Future<T> Function(FirebaseFirestore firestore) operation, {
    String operationName = 'Firestore Operation',
    T? fallbackValue,
  }) async {
    final firestoreInstance = firestore;
    if (firestoreInstance == null) {
      AppLogger.warning('$operationName skipped - Firestore not available');
      return fallbackValue;
    }

    return executeFirebaseOperation(
      () => operation(firestoreInstance),
      operationName: operationName,
      fallbackValue: fallbackValue,
    );
  }

  /// Execute Auth operation with error handling
  Future<T?> executeAuthOperation<T>(
    Future<T> Function(FirebaseAuth auth) operation, {
    String operationName = 'Auth Operation',
    T? fallbackValue,
  }) async {
    final authInstance = auth;
    if (authInstance == null) {
      AppLogger.warning('$operationName skipped - Firebase Auth not available');
      return fallbackValue;
    }

    return executeFirebaseOperation(
      () => operation(authInstance),
      operationName: operationName,
      fallbackValue: fallbackValue,
    );
  }

  /// Execute Storage operation with error handling
  Future<T?> executeStorageOperation<T>(
    Future<T> Function(FirebaseStorage storage) operation, {
    String operationName = 'Storage Operation',
    T? fallbackValue,
  }) async {
    final storageInstance = storage;
    if (storageInstance == null) {
      AppLogger.warning('$operationName skipped - Firebase Storage not available');
      return fallbackValue;
    }

    return executeFirebaseOperation(
      () => operation(storageInstance),
      operationName: operationName,
      fallbackValue: fallbackValue,
    );
  }

  /// Check if error is a web Firebase JavaScript interop error
  bool _isWebFirebaseError(dynamic error) {
    if (!kIsWeb) return false;

    final errorString = error.toString().toLowerCase();
    return errorString.contains('javascriptobject') ||
           errorString.contains('firebase_js') ||
           errorString.contains('firebase_core_web') ||
           errorString.contains('js interop') ||
           errorString.contains('dart:js_util') ||
           errorString.contains('_jsfunction');
  }

  /// Get current user safely
  User? get currentUser {
    try {
      return auth?.currentUser;
    } catch (e) {
      AppLogger.warning('Failed to get current user', e);
      return null;
    }
  }

  /// Check if user is signed in
  bool get isSignedIn {
    try {
      return currentUser != null;
    } catch (e) {
      AppLogger.warning('Failed to check sign-in status', e);
      return false;
    }
  }

  /// Stream of auth state changes (safely)
  Stream<User?> get authStateChanges {
    try {
      return auth?.authStateChanges() ?? Stream.value(null);
    } catch (e) {
      AppLogger.warning('Failed to get auth state changes stream', e);
      return Stream.value(null);
    }
  }

  /// Show Firebase status information
  String getFirebaseStatus() {
    final buffer = StringBuffer();
    buffer.writeln('Firebase Status:');
    buffer.writeln('- Initialized: ${FirebaseCoreConfig.isInitialized}');
    buffer.writeln('- Available: ${FirebaseCoreConfig.isAvailable}');
    
    if (kIsWeb) {
      buffer.writeln('- Web Firebase Available: ${WebFirebaseConfig.isWebFirebaseAvailable}');
      buffer.writeln('- Offline Mode: ${WebFirebaseConfig.isOfflineMode}');
      
      final lastError = WebFirebaseConfig.lastWebError;
      if (lastError != null) {
        buffer.writeln('- Last Web Error: $lastError');
      }
    }
    
    buffer.writeln('- Auth Available: ${auth != null}');
    buffer.writeln('- Firestore Available: ${firestore != null}');
    buffer.writeln('- Storage Available: ${storage != null}');
    buffer.writeln('- User Signed In: $isSignedIn');
    
    return buffer.toString();
  }
}