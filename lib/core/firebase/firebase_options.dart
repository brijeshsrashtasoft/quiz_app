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

  // Firebase configuration for real project - Updated from google-services.json
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBv6bPsLKZ_8Rc2KdDblD2J7aKX3gXus-A',
    appId: '1:130579954244:web:9f0517b27f50a3b8f91a11',
    messagingSenderId: '130579954244',
    projectId: 'quiz-app-1753821039',
    authDomain: 'quiz-app-1753821039.firebaseapp.com',
    storageBucket: 'quiz-app-1753821039.firebasestorage.app',
    measurementId:
        'G-MEAS1234567', // Placeholder - update if web analytics enabled
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBv6bPsLKZ_8Rc2KdDblD2J7aKX3gXus-A',
    appId: '1:130579954244:android:9f0517b27f50a3b8f91a11',
    messagingSenderId: '130579954244',
    projectId: 'quiz-app-1753821039',
    storageBucket: 'quiz-app-1753821039.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBv6bPsLKZ_8Rc2KdDblD2J7aKX3gXus-A',
    appId: '1:130579954244:ios:9f0517b27f50a3b8f91a11',
    messagingSenderId: '130579954244',
    projectId: 'quiz-app-1753821039',
    storageBucket: 'quiz-app-1753821039.firebasestorage.app',
    iosBundleId: 'com.example.quiz-app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBv6bPsLKZ_8Rc2KdDblD2J7aKX3gXus-A',
    appId: '1:130579954244:ios:9f0517b27f50a3b8f91a11',
    messagingSenderId: '130579954244',
    projectId: 'quiz-app-1753821039',
    storageBucket: 'quiz-app-1753821039.firebasestorage.app',
    iosBundleId: 'com.example.quiz-app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBv6bPsLKZ_8Rc2KdDblD2J7aKX3gXus-A',
    appId: '1:130579954244:web:9f0517b27f50a3b8f91a11',
    messagingSenderId: '130579954244',
    projectId: 'quiz-app-1753821039',
    authDomain: 'quiz-app-1753821039.firebaseapp.com',
    storageBucket: 'quiz-app-1753821039.firebasestorage.app',
    measurementId:
        'G-MEAS1234567', // Placeholder - update if web analytics enabled
  );
}
