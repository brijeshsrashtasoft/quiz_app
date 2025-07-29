import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';
import 'firebase_options.dart';

/// Firebase core configuration and initialization
/// Following CLAUDE.md Firebase integration patterns
class FirebaseCoreConfig {
  static bool _initialized = false;
  
  /// Initialize Firebase with proper error handling
  static Future<void> initialize() async {
    if (_initialized) {
      AppLogger.firebase('Initialize', 'Firebase already initialized');
      return;
    }
    
    try {
      AppLogger.firebase('Initialize', 'Starting Firebase initialization');
      
      await Firebase.initializeApp(
        options: _getFirebaseOptions(),
      );
      
      _initialized = true;
      AppLogger.firebase('Initialize', 'Firebase initialized successfully');
      
      if (kDebugMode) {
        // Enable Firebase emulator in debug mode if needed
        await _configureEmulators();
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Firebase initialization failed', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get Firebase options based on platform
  static FirebaseOptions _getFirebaseOptions() {
    AppLogger.firebase('Config', 'Loading Firebase options for current platform');
    return DefaultFirebaseOptions.currentPlatform;
  }
  
  /// Configure Firebase emulators for development
  static Future<void> _configureEmulators() async {
    try {
      AppLogger.firebase('Emulator', 'Configuring Firebase emulators for development');
      
      // Configure Firestore emulator
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      AppLogger.firebase('Emulator', 'Firestore emulator configured on localhost:8080');
      
      // Configure Auth emulator
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      AppLogger.firebase('Emulator', 'Auth emulator configured on localhost:9099');
      
    } catch (e) {
      AppLogger.warning('Failed to configure Firebase emulators', e);
      // Don't rethrow - emulator configuration is optional
    }
  }
  
  /// Check if Firebase is initialized
  static bool get isInitialized => _initialized;
  
  /// Get current Firebase app instance
  static FirebaseApp get app {
    if (!_initialized) {
      throw Exception('Firebase not initialized. Call FirebaseCoreConfig.initialize() first.');
    }
    return Firebase.app();
  }
}