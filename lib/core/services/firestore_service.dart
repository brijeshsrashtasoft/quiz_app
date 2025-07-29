import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  FirebaseFirestore get firestore => _firestore;

  // Generic CRUD operations
  Future<DocumentReference> create(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      _logger.d('Creating document in $collection');
      final docRef = await _firestore.collection(collection).add(data);
      _logger.d('Document created with ID: ${docRef.id}');
      return docRef;
    } catch (e) {
      _logger.e('Error creating document: $e');
      rethrow;
    }
  }

  Future<void> update(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      _logger.d('Updating document $documentId in $collection');
      await _firestore.collection(collection).doc(documentId).update(data);
      _logger.d('Document updated successfully');
    } catch (e) {
      _logger.e('Error updating document: $e');
      rethrow;
    }
  }

  Future<void> delete(String collection, String documentId) async {
    try {
      _logger.d('Deleting document $documentId from $collection');
      await _firestore.collection(collection).doc(documentId).delete();
      _logger.d('Document deleted successfully');
    } catch (e) {
      _logger.e('Error deleting document: $e');
      rethrow;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> get(
    String collection,
    String documentId,
  ) async {
    try {
      _logger.d('Getting document $documentId from $collection');
      final doc = await _firestore.collection(collection).doc(documentId).get();
      _logger.d('Document retrieved successfully');
      return doc;
    } catch (e) {
      _logger.e('Error getting document: $e');
      rethrow;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getStream(
    String collection,
    String documentId,
  ) {
    _logger.d('Setting up stream for document $documentId in $collection');
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWhere(
    String collection, {
    String? field,
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isGreaterThan,
    List<Object?>? whereIn,
    int? limit,
  }) async {
    try {
      _logger.d('Querying collection $collection with conditions');
      Query<Map<String, dynamic>> query = _firestore.collection(collection);

      if (field != null) {
        if (isEqualTo != null) {
          query = query.where(field, isEqualTo: isEqualTo);
        }
        if (isNotEqualTo != null) {
          query = query.where(field, isNotEqualTo: isNotEqualTo);
        }
        if (isLessThan != null) {
          query = query.where(field, isLessThan: isLessThan);
        }
        if (isGreaterThan != null) {
          query = query.where(field, isGreaterThan: isGreaterThan);
        }
        if (whereIn != null) {
          query = query.where(field, whereIn: whereIn);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final result = await query.get();
      _logger.d('Query completed, found ${result.docs.length} documents');
      return result;
    } catch (e) {
      _logger.e('Error querying collection: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getWhereStream(
    String collection, {
    String? field,
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isGreaterThan,
    List<Object?>? whereIn,
    int? limit,
  }) {
    _logger.d('Setting up query stream for collection $collection');
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (field != null) {
      if (isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      if (isNotEqualTo != null) {
        query = query.where(field, isNotEqualTo: isNotEqualTo);
      }
      if (isLessThan != null) {
        query = query.where(field, isLessThan: isLessThan);
      }
      if (isGreaterThan != null) {
        query = query.where(field, isGreaterThan: isGreaterThan);
      }
      if (whereIn != null) {
        query = query.where(field, whereIn: whereIn);
      }
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }
}