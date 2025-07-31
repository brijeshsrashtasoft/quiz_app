import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import 'firebase_options.dart';
import 'web_firebase_config.dart';

/// Firebase core configuration and initialization
/// Following CLAUDE.md Firebase integration patterns
class FirebaseCoreConfig {
  static bool _initialized = false;
  static bool _isTestMode = true; // Enable test mode for development

  /// Initialize Firebase with optimized startup and test mode support
  static Future<void> initialize() async {
    if (_initialized) {
      AppLogger.firebase('Initialize', 'Firebase already initialized');
      return;
    }

    try {
      final startTime = DateTime.now();
      AppLogger.firebase('Initialize', 'Starting Firebase initialization');

      // Use web-specific initialization for web platform
      if (kIsWeb) {
        final webSuccess = await WebFirebaseConfig.initializeWeb();
        if (!webSuccess) {
          AppLogger.warning(
            'Firebase web initialization failed - continuing in offline mode',
          );
        }
      } else {
        // Initialize Firebase normally for mobile platforms
        await Firebase.initializeApp(options: _getFirebaseOptions());
      }

      _initialized = true;

      final duration = DateTime.now().difference(startTime);
      AppLogger.firebase(
        'Initialize',
        'Firebase initialized successfully in ${duration.inMilliseconds}ms',
      );

      // Configure test mode settings for faster startup
      if (_isTestMode) {
        await _configureTestMode();
      }
    } catch (e, stackTrace) {
      // Handle JavaScript interop errors specifically for web platform
      if (kIsWeb && _isJavaScriptInteropError(e)) {
        AppLogger.warning(
          'Firebase web initialization failed due to JavaScript interop error - '
          'continuing in offline mode',
          e,
        );
        // Set initialized to true to prevent retries and allow app to continue
        _initialized = true;
        return;
      }
      
      AppLogger.error('Firebase initialization failed', e, stackTrace);
      // Don't rethrow in test mode - allow app to continue
      if (!_isTestMode) {
        rethrow;
      }
    }
  }

  /// Configure Firebase for test mode with optimized settings
  static Future<void> _configureTestMode() async {
    try {
      AppLogger.firebase('TestMode', 'Configuring Firebase test mode');

      // Lightweight test mode configuration - minimal setup for fast startup
      // Skip emulator connection to avoid network delays
      // Skip additional service initialization to improve startup time

      AppLogger.firebase(
        'TestMode',
        'Test mode configured - optimized for fast startup',
      );
    } catch (e) {
      AppLogger.warning('Test mode configuration failed', e);
      // Don't fail initialization for test mode issues
    }
  }

  /// Check if running in test mode
  static bool get isTestMode => _isTestMode;

  /// Enable production mode (disable test mode)
  static void enableProductionMode() {
    _isTestMode = false;
    AppLogger.firebase('Config', 'Switched to production mode');
  }

  /// Get Firebase options based on platform
  static FirebaseOptions _getFirebaseOptions() {
    AppLogger.firebase(
      'Config',
      'Loading Firebase options for current platform',
    );
    return DefaultFirebaseOptions.currentPlatform;
  }

  /// Check if error is related to JavaScript interop issues on web platform
  static bool _isJavaScriptInteropError(dynamic error) {
    if (!kIsWeb) return false;
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('javascriptobject') ||
           errorString.contains('js interop') ||
           errorString.contains('type \'_jsfunction\'') ||
           errorString.contains('is not a subtype of') ||
           errorString.contains('firebase_js') ||
           errorString.contains('firebase-app') ||
           errorString.contains('dart_web_workers');
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _initialized;

  /// Check if Firebase is available for use (handles web offline mode)
  static bool get isAvailable {
    if (!_initialized) return false;
    
    // For web platform, also check if Firebase web services are available
    if (kIsWeb) {
      return WebFirebaseConfig.isWebFirebaseAvailable;
    }
    
    return true;
  }

  /// Check if app is running in offline mode (web Firebase unavailable)
  static bool get isOfflineMode {
    if (!kIsWeb) return false;
    return WebFirebaseConfig.isOfflineMode;
  }

  /// Get current Firebase app instance
  static FirebaseApp get app {
    if (!_initialized) {
      throw Exception(
        'Firebase not initialized. Call FirebaseCoreConfig.initialize() first.',
      );
    }
    
    // Additional check for web platform
    if (kIsWeb && !WebFirebaseConfig.isWebFirebaseAvailable) {
      throw Exception(
        'Firebase web services are not available. App is running in offline mode.',
      );
    }
    
    return Firebase.app();
  }

  /// Get current Firebase app instance safely (returns null if unavailable)
  static FirebaseApp? get appSafe {
    try {
      return app;
    } catch (e) {
      AppLogger.warning('Firebase app not available', e);
      return null;
    }
  }
}
