import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import 'firebase_options.dart';

/// Web-specific Firebase configuration to handle JavaScript interop issues
/// Following CLAUDE.md Firebase integration patterns
class WebFirebaseConfig {
  static bool _webInitialized = false;
  static bool _webErrorOccurred = false;
  static String? _lastWebError;

  /// Initialize Firebase for web platform with enhanced error handling
  static Future<bool> initializeWeb() async {
    if (!kIsWeb) {
      throw UnsupportedError(
        'WebFirebaseConfig can only be used on web platform',
      );
    }

    if (_webInitialized) {
      AppLogger.firebase('WebInit', 'Firebase web already initialized');
      return true;
    }

    try {
      AppLogger.firebase(
        'WebInit',
        'Starting web-specific Firebase initialization',
      );

      // Try to initialize Firebase with web-specific handling
      await _attemptWebInitialization();

      _webInitialized = true;
      _webErrorOccurred = false;
      _lastWebError = null;

      AppLogger.firebase(
        'WebInit',
        'Firebase web initialization completed successfully',
      );
      return true;
    } catch (e, stackTrace) {
      _webErrorOccurred = true;
      _lastWebError = e.toString();

      // Handle specific web Firebase errors gracefully
      if (_isFirebaseWebCompatibilityError(e)) {
        AppLogger.warning(
          'Firebase web compatibility issue detected - '
          'app will continue in offline mode. Error: ${e.toString()}',
        );

        // Mark as initialized to prevent retry loops
        _webInitialized = true;
        return false; // Return false to indicate offline mode
      }

      AppLogger.error('Firebase web initialization failed', e, stackTrace);
      return false;
    }
  }

  /// Attempt Firebase web initialization with retry logic
  static Future<void> _attemptWebInitialization() async {
    const maxRetries = 3;
    const baseDelay = Duration(milliseconds: 500);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        AppLogger.firebase(
          'WebInit',
          'Initialization attempt $attempt/$maxRetries',
        );

        // Initialize Firebase with web options (now using real project config)
        await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

        AppLogger.firebase(
          'WebInit',
          'Firebase web initialized on attempt $attempt',
        );
        return;
      } catch (e) {
        if (attempt == maxRetries) {
          rethrow; // Rethrow on final attempt
        }

        AppLogger.warning(
          'Firebase web initialization attempt $attempt failed, retrying...',
          e,
        );

        // Exponential backoff
        final delay = Duration(
          milliseconds: baseDelay.inMilliseconds * (attempt * 2),
        );
        await Future.delayed(delay);
      }
    }
  }

  /// Check if error is a known Firebase web compatibility issue
  static bool _isFirebaseWebCompatibilityError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Common Firebase web JavaScript interop errors
    return errorString.contains('javascriptobject') ||
        errorString.contains('_jsfunction') ||
        errorString.contains('firebase_js') ||
        errorString.contains('firebase-app') ||
        errorString.contains('firebase_core_web') ||
        errorString.contains('dart:js_interop') ||
        errorString.contains('dart:js_util') ||
        errorString.contains('web workers') ||
        errorString.contains('document is not defined') ||
        errorString.contains('window is not defined') ||
        errorString.contains('navigator is not defined');
  }

  /// Check if web Firebase is available and working
  static bool get isWebFirebaseAvailable {
    return kIsWeb && _webInitialized && !_webErrorOccurred;
  }

  /// Check if web Firebase encountered an error but app can continue
  static bool get isOfflineMode {
    return kIsWeb && _webInitialized && _webErrorOccurred;
  }

  /// Get the last web Firebase error for debugging
  static String? get lastWebError => _lastWebError;

  /// Reset web Firebase state (for testing or retry scenarios)
  static void resetWebState() {
    _webInitialized = false;
    _webErrorOccurred = false;
    _lastWebError = null;
    AppLogger.firebase('WebInit', 'Web Firebase state reset');
  }

  /// Check if current environment supports Firebase web features
  static bool get supportsWebFeatures {
    if (!kIsWeb) return false;

    try {
      // Basic web environment checks
      return true; // Simplified check - in real app, check for required APIs
    } catch (e) {
      AppLogger.warning('Web environment compatibility check failed', e);
      return false;
    }
  }
}
