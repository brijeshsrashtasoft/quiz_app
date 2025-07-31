import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration options for all platforms
/// This file should be updated with actual Firebase project configuration
/// Generated with `flutterfire configure` command
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Test mode Firebase configuration for development
  // Replace with actual Firebase project configuration in production
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyTestKeyForWebPlatform123456789',
    appId: '1:123456789:web:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'quiz-app-test-project',
    authDomain: 'quiz-app-test-project.firebaseapp.com',
    storageBucket: 'quiz-app-test-project.appspot.com',
    measurementId: 'G-TEST123456',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyTestKeyForAndroidPlatform123456789',
    appId: '1:123456789:android:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'quiz-app-test-project',
    storageBucket: 'quiz-app-test-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyTestKeyForIOSPlatform123456789',
    appId: '1:123456789:ios:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'quiz-app-test-project',
    storageBucket: 'quiz-app-test-project.appspot.com',
    iosBundleId: 'com.example.quizApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyTestKeyForMacOSPlatform123456789',
    appId: '1:123456789:ios:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'quiz-app-test-project',
    storageBucket: 'quiz-app-test-project.appspot.com',
    iosBundleId: 'com.example.quizApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyTestKeyForWindowsPlatform123456789',
    appId: '1:123456789:web:windowsabcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'quiz-app-test-project',
    authDomain: 'quiz-app-test-project.firebaseapp.com',
    storageBucket: 'quiz-app-test-project.appspot.com',
    measurementId: 'G-TESTWIN123',
  );
}
