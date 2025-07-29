import '../errors/exceptions.dart';

/// Base data source interface following Clean Architecture patterns
/// Referenced from CLAUDE.md data layer implementation
abstract class BaseRemoteDataSource {
  /// Handle remote data source operations with proper exception handling
  Future<T> handleRemoteOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      throw _mapToDataSourceException(e);
    }
  }

  /// Map generic exceptions to data source specific exceptions
  DataSourceException _mapToDataSourceException(dynamic exception) {
    // Default to server exception, can be overridden in implementations
    return const DataSourceException.server(
      message: 'Remote data source operation failed',
    );
  }
}

/// Base local data source interface
abstract class BaseLocalDataSource {
  /// Handle local data source operations with proper exception handling
  Future<T> handleLocalOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      throw const DataSourceException.cache(
        message: 'Local data source operation failed',
      );
    }
  }
}

/// Base Firebase data source with Firestore-specific operations
/// Following CLAUDE.md Firebase integration patterns
abstract class BaseFirebaseDataSource extends BaseRemoteDataSource {
  @override
  DataSourceException _mapToDataSourceException(dynamic exception) {
    // Map Firebase-specific exceptions
    if (exception.toString().contains('permission-denied')) {
      return const DataSourceException.auth(
        message: 'Permission denied for Firestore operation',
      );
    }

    if (exception.toString().contains('unavailable')) {
      return const DataSourceException.network(
        message: 'Firestore service unavailable',
      );
    }

    return const DataSourceException.server(
      message: 'Firestore operation failed',
    );
  }
}
