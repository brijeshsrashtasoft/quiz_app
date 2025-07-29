/// Custom exceptions for error handling in data layer.
/// Following CLAUDE.md Clean Architecture patterns.
library;

class ServerException implements Exception {
  final String message;
  final String? code;
  
  const ServerException({
    required this.message,
    this.code,
  });
  
  @override
  String toString() => 'ServerException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException({
    required this.message,
  });
  
  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;
  
  const AuthException({
    required this.message,
    this.code,
  });
  
  @override
  String toString() => 'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

class FirestoreException implements Exception {
  final String message;
  final String? code;
  
  const FirestoreException({
    required this.message,
    this.code,
  });
  
  @override
  String toString() => 'FirestoreException: $message${code != null ? ' (Code: $code)' : ''}';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;
  
  const ValidationException({
    required this.message,
    this.fieldErrors,
  });
  
  @override
  String toString() => 'ValidationException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException({
    required this.message,
  });
  
  @override
  String toString() => 'CacheException: $message';
}