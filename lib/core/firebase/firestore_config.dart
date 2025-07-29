import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../constants/firebase_constants.dart';
import '../utils/logger.dart';
import '../errors/exceptions.dart';

/// Firestore database configuration and utilities
/// Following CLAUDE.md Firestore integration patterns
class FirestoreConfig {
  static FirebaseFirestore? _instance;

  /// Get Firestore instance with configuration
  static FirebaseFirestore get instance {
    _instance ??= _configureFirestore();
    return _instance!;
  }

  /// Configure Firestore settings
  static FirebaseFirestore _configureFirestore() {
    final firestore = FirebaseFirestore.instance;

    try {
      // Configure Firestore settings for optimal performance
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        ignoreUndefinedProperties: false,
      );

      AppLogger.firebase(
        'Firestore',
        'Firestore configured with persistence enabled',
      );

      if (kDebugMode) {
        // Enable additional logging in debug mode
        FirebaseFirestore.setLoggingEnabled(true);
        AppLogger.firebase(
          'Firestore',
          'Firestore logging enabled for debug mode',
        );
      }

      return firestore;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to configure Firestore', e, stackTrace);
      throw FirestoreException(
        message: 'Failed to configure Firestore database',
        code: 'firestore_config_error',
      );
    }
  }

  /// Get collection reference with error handling
  static CollectionReference<Map<String, dynamic>> getCollection(
    String collectionName,
  ) {
    try {
      final collection = instance.collection(collectionName);
      AppLogger.firebase('Firestore', 'Accessing collection: $collectionName');
      return collection;
    } catch (e) {
      AppLogger.error('Failed to access collection: $collectionName', e);
      throw FirestoreException(
        message: 'Failed to access collection: $collectionName',
        code: 'collection_access_error',
      );
    }
  }

  /// Get document reference with error handling
  static DocumentReference<Map<String, dynamic>> getDocument(
    String collectionName,
    String documentId,
  ) {
    try {
      final document = instance.collection(collectionName).doc(documentId);
      AppLogger.firebase(
        'Firestore',
        'Accessing document: $collectionName/$documentId',
      );
      return document;
    } catch (e) {
      AppLogger.error(
        'Failed to access document: $collectionName/$documentId',
        e,
      );
      throw FirestoreException(
        message: 'Failed to access document: $collectionName/$documentId',
        code: 'document_access_error',
      );
    }
  }

  /// Predefined collection references for the quiz app
  static CollectionReference<Map<String, dynamic>> get usersCollection =>
      getCollection(FirebaseConstants.usersCollection);

  static CollectionReference<Map<String, dynamic>> get quizzesCollection =>
      getCollection(FirebaseConstants.quizzesCollection);

  static CollectionReference<Map<String, dynamic>> get gameSessionsCollection =>
      getCollection(FirebaseConstants.gameSessionsCollection);

  static CollectionReference<Map<String, dynamic>> get leaderboardsCollection =>
      getCollection(FirebaseConstants.leaderboardsCollection);

  /// Batch write operations for atomic updates
  static WriteBatch getBatch() {
    return instance.batch();
  }

  /// Transaction operations for consistent reads/writes
  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      final startTime = DateTime.now();

      final result = await instance.runTransaction(updateFunction);

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firestore Transaction', duration);

      return result;
    } catch (e) {
      AppLogger.error('Firestore transaction failed', e);
      throw FirestoreException(
        message: 'Transaction failed: ${e.toString()}',
        code: 'transaction_error',
      );
    }
  }

  /// Check Firestore connectivity
  static Future<bool> checkConnectivity() async {
    try {
      final startTime = DateTime.now();

      // Attempt to read from a system collection
      await instance
          .collection('_firestore_connectivity_check')
          .limit(1)
          .get(const GetOptions(source: Source.server));

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Firestore Connectivity Check', duration);

      return true;
    } catch (e) {
      AppLogger.warning('Firestore connectivity check failed', e);
      return false;
    }
  }

  /// Enable offline persistence (already configured in settings)
  static Future<void> enableOfflinePersistence() async {
    try {
      // Persistence is already enabled in _configureFirestore settings
      AppLogger.firebase(
        'Firestore',
        'Offline persistence already configured in settings',
      );
    } catch (e) {
      AppLogger.warning('Failed to enable offline persistence', e);
      // Don't throw - offline persistence is optional
    }
  }

  /// Clear offline cache
  static Future<void> clearCache() async {
    try {
      await instance.clearPersistence();
      AppLogger.firebase('Firestore', 'Offline cache cleared');
    } catch (e) {
      AppLogger.error('Failed to clear offline cache', e);
      throw FirestoreException(
        message: 'Failed to clear offline cache',
        code: 'cache_clear_error',
      );
    }
  }
}
