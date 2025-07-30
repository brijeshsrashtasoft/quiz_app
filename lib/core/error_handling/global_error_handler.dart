import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'error_service.dart';
import '../utils/logger.dart';

/// Global error handler for capturing all uncaught errors in the app
/// Following CLAUDE.md Clean Architecture patterns
class GlobalErrorHandler {
  static GlobalErrorHandler? _instance;
  static GlobalErrorHandler get instance => _instance ??= GlobalErrorHandler._();
  
  late final ErrorService _errorService;
  
  GlobalErrorHandler._() {
    _errorService = ErrorService.instance;
  }
  
  factory GlobalErrorHandler({ErrorService? errorService}) {
    if (_instance == null) {
      _instance = GlobalErrorHandler._();
      if (errorService != null) {
        _instance!._errorService = errorService;
      }
    }
    return _instance!;
  }

  /// Initialize global error handling
  void initialize() {
    // Set up Flutter framework error handler
    FlutterError.onError = _handleFlutterError;
    
    // Set up platform dispatcher error handler for errors outside Flutter
    PlatformDispatcher.instance.onError = _handlePlatformError;
    
    AppLogger.info('Global error handler initialized');
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    // Extract context information
    final context = _buildFlutterErrorContext(details);
    
    // Log the error with full context
    AppLogger.error(
      'Flutter Error: ${details.exception}',
      details.exception,
      details.stack,
    );
    
    // Handle through error service
    _errorService.handleError(
      details.exception,
      details.stack ?? StackTrace.current,
      context: context,
      additionalInfo: {
        'library': details.library,
        'information_collector': details.informationCollector?.toString(),
      },
    );
  }

  /// Handle platform-level errors
  bool _handlePlatformError(Object error, StackTrace stackTrace) {
    AppLogger.error('Platform Error: $error', error, stackTrace);
    
    _errorService.handleError(
      error,
      stackTrace,
      context: 'Platform Error',
    );
    
    // Return true to indicate error was handled
    return true;
  }

  /// Build context string from FlutterErrorDetails
  String _buildFlutterErrorContext(FlutterErrorDetails details) {
    final buffer = StringBuffer('Flutter Error');
    
    if (details.library != null) {
      buffer.write(' - ${details.library}');
    }
    
    if (details.context != null) {
      buffer.write(': ${details.context}');
    }
    
    return buffer.toString();
  }

  /// Run code in a guarded zone that catches errors
  Future<T?> runInErrorZone<T>(Future<T> Function() computation) async {
    final completer = Completer<T?>();
    
    runZonedGuarded<void>(
      () async {
        try {
          final result = await computation();
          completer.complete(result);
        } catch (error, stackTrace) {
          _errorService.handleError(
            error,
            stackTrace,
            context: 'Zone Error',
          );
          completer.complete(null);
        }
      },
      (error, stackTrace) {
        _errorService.handleError(
          error,
          stackTrace,
          context: 'Zone Error',
        );
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
    );
    
    return completer.future;
  }

  /// Manually report an error
  void reportError(
    dynamic error,
    StackTrace stackTrace, {
    String? context,
    Map<String, dynamic>? additionalInfo,
    BuildContext? buildContext,
  }) {
    _errorService.handleError(
      error,
      stackTrace,
      context: context,
      additionalInfo: additionalInfo,
      buildContext: buildContext,
    );
  }

  /// Report error with automatic context detection
  void reportErrorWithContext(
    dynamic error,
    StackTrace stackTrace,
    BuildContext? context, {
    Map<String, dynamic>? additionalInfo,
  }) {
    String? contextInfo;
    
    if (context != null) {
      // Try to extract route information for context
      final route = ModalRoute.of(context);
      if (route != null && route.settings.name != null) {
        contextInfo = 'Route: ${route.settings.name}';
      }
    }
    
    reportError(
      error,
      stackTrace,
      context: contextInfo,
      additionalInfo: additionalInfo,
      buildContext: context,
    );
  }

  /// Handle specific error types with enhanced context
  void reportFirestoreError(
    dynamic error,
    StackTrace stackTrace,
    String operation, {
    Map<String, dynamic>? metadata,
    BuildContext? buildContext,
  }) {
    _errorService.handleFirestoreError(
      error,
      stackTrace,
      operation: operation,
      metadata: metadata,
      buildContext: buildContext,
    );
  }

  void reportAuthError(
    dynamic error,
    StackTrace stackTrace,
    String operation, {
    String? userId,
    BuildContext? buildContext,
  }) {
    _errorService.handleAuthError(
      error,
      stackTrace,
      operation: operation,
      userId: userId,
      buildContext: buildContext,
    );
  }

  void reportNetworkError(
    dynamic error,
    StackTrace stackTrace,
    String endpoint, {
    String? requestId,
    BuildContext? buildContext,
  }) {
    _errorService.handleNetworkError(
      error,
      stackTrace,
      endpoint: endpoint,
      requestId: requestId,
      buildContext: buildContext,
    );
  }
}