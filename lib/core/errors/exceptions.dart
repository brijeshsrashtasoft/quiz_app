/// Custom exceptions for error handling in data layer.
/// Following CLAUDE.md Clean Architecture patterns.
library;

class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException({required this.message, this.code});

  @override
  String toString() =>
      'ServerException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

class FirestoreException implements Exception {
  final String message;
  final String? code;

  const FirestoreException({required this.message, this.code});

  @override
  String toString() =>
      'FirestoreException: $message${code != null ? ' (Code: $code)' : ''}';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationException({required this.message, this.fieldErrors});

  @override
  String toString() => 'ValidationException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Data source specific exception with type support
class DataSourceException implements Exception {
  final String message;
  final String? code;
  final DataSourceExceptionType type;

  const DataSourceException.server({required this.message, this.code})
    : type = DataSourceExceptionType.server;

  const DataSourceException.network({required this.message, this.code})
    : type = DataSourceExceptionType.network;

  const DataSourceException.auth({required this.message, this.code})
    : type = DataSourceExceptionType.auth;

  const DataSourceException.cache({required this.message, this.code})
    : type = DataSourceExceptionType.cache;

  @override
  String toString() =>
      'DataSourceException: $message${code != null ? ' (Code: $code)' : ''}';
}

enum DataSourceExceptionType { server, network, auth, cache }
