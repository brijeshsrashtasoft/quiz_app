import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/logger.dart';

/// Batch processor for optimizing Firestore operations
/// Accumulates operations and executes them in batches
class BatchProcessor<T> {
  final Duration batchDelay;
  final int maxBatchSize;
  final Future<void> Function(List<T>) processBatch;
  
  final List<T> _pendingItems = [];
  Timer? _batchTimer;
  bool _isProcessing = false;

  BatchProcessor({
    required this.batchDelay,
    required this.maxBatchSize,
    required this.processBatch,
  });

  /// Add an item to the batch queue
  void add(T item) {
    _pendingItems.add(item);
    
    // Process immediately if batch is full
    if (_pendingItems.length >= maxBatchSize) {
      _processPendingBatch();
    } else {
      // Schedule batch processing after delay
      _scheduleBatchProcessing();
    }
  }

  /// Add multiple items to the batch queue
  void addAll(List<T> items) {
    _pendingItems.addAll(items);
    
    // Process in chunks if necessary
    while (_pendingItems.length >= maxBatchSize) {
      _processPendingBatch();
    }
    
    // Schedule processing for remaining items
    if (_pendingItems.isNotEmpty) {
      _scheduleBatchProcessing();
    }
  }

  void _scheduleBatchProcessing() {
    _batchTimer?.cancel();
    _batchTimer = Timer(batchDelay, _processPendingBatch);
  }

  Future<void> _processPendingBatch() async {
    if (_isProcessing || _pendingItems.isEmpty) return;
    
    _batchTimer?.cancel();
    _isProcessing = true;
    
    try {
      // Take up to maxBatchSize items
      final batch = _pendingItems.take(maxBatchSize).toList();
      _pendingItems.removeRange(0, batch.length);
      
      await processBatch(batch);
      
      // Process remaining items if any
      if (_pendingItems.isNotEmpty) {
        _scheduleBatchProcessing();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Batch processing failed', e, stackTrace);
    } finally {
      _isProcessing = false;
    }
  }

  /// Force process all pending items immediately
  Future<void> flush() async {
    _batchTimer?.cancel();
    while (_pendingItems.isNotEmpty) {
      await _processPendingBatch();
    }
  }

  /// Dispose of the batch processor
  void dispose() {
    _batchTimer?.cancel();
    _pendingItems.clear();
  }
}

/// Firestore batch writer for optimized write operations
class FirestoreBatchWriter {
  static const int _maxBatchSize = 500; // Firestore limit
  final FirebaseFirestore _firestore;
  WriteBatch? _currentBatch;
  int _operationCount = 0;
  final List<Future<void>> _pendingCommits = [];

  FirestoreBatchWriter({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Add a set operation to the batch
  void set(DocumentReference doc, Map<String, dynamic> data, [SetOptions? options]) {
    _ensureBatch();
    if (options != null) {
      _currentBatch!.set(doc, data, options);
    } else {
      _currentBatch!.set(doc, data);
    }
    _incrementOperationCount();
  }

  /// Add an update operation to the batch
  void update(DocumentReference doc, Map<String, dynamic> data) {
    _ensureBatch();
    _currentBatch!.update(doc, data);
    _incrementOperationCount();
  }

  /// Add a delete operation to the batch
  void delete(DocumentReference doc) {
    _ensureBatch();
    _currentBatch!.delete(doc);
    _incrementOperationCount();
  }

  void _ensureBatch() {
    _currentBatch ??= _firestore.batch();
  }

  void _incrementOperationCount() {
    _operationCount++;
    if (_operationCount >= _maxBatchSize) {
      _commitCurrentBatch();
    }
  }

  void _commitCurrentBatch() {
    if (_currentBatch != null && _operationCount > 0) {
      final commit = _currentBatch!.commit();
      _pendingCommits.add(commit);
      _currentBatch = null;
      _operationCount = 0;
    }
  }

  /// Commit all pending operations
  Future<void> commit() async {
    _commitCurrentBatch();
    await Future.wait(_pendingCommits);
    _pendingCommits.clear();
  }
}