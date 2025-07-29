# Firebase Configuration Setup

This document explains how to configure Firebase for the Quiz App project across all platforms.

## Overview

The project currently uses **placeholder Firebase configuration files** that must be replaced with your own Firebase project credentials before deployment.

## Platform Requirements

### Android Requirements
- **minSdkVersion**: 23 or higher (already configured)
- **NDK Version**: 27.0.12077973 (already configured)
- **Google Services Plugin**: Enabled (already configured)

### iOS Requirements  
- **Deployment Target**: iOS 13.0 or higher (already configured)
- **CocoaPods**: Required for Firebase dependencies

## Setup Steps

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name (e.g., "quiz-app-production" or "quiz-app-dev")
4. Enable Google Analytics (recommended)
5. Complete project creation

### 2. Enable Required Firebase Services

In your Firebase project console, enable:

- **Authentication**: Go to Authentication > Sign-in method
  - Enable Email/Password
  - Enable Google Sign-In (optional)
- **Firestore Database**: Go to Firestore Database > Create database
  - Start in test mode initially
  - Choose your preferred region
- **Storage**: Go to Storage > Get started
- **Analytics**: Should be enabled by default
- **Cloud Functions**: Go to Functions (will be set up later)

### 3. Configure Android App

1. In Firebase Console, click "Add app" → Android
2. Enter Android package name: `com.example.quiz_app`
3. Download `google-services.json`
4. **Replace** the placeholder file:
   ```bash
   # Replace the placeholder with your actual configuration
   cp ~/Downloads/google-services.json android/app/google-services.json
   ```

### 4. Configure iOS App

1. In Firebase Console, click "Add app" → iOS
2. Enter iOS bundle ID: `com.example.quiz_app`
3. Download `GoogleService-Info.plist`
4. **Replace** the placeholder file:
   ```bash
   # Replace the placeholder with your actual configuration
   cp ~/Downloads/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
   ```

### 5. Configure Web App (Optional)

1. In Firebase Console, click "Add app" → Web
2. Enter app nickname: "Quiz App Web"
3. Copy the Firebase config object
4. Update `lib/core/firebase/firebase_options.dart` with your web configuration

## Security Rules

The project includes basic Firestore security rules in `firestore.rules`. Deploy them:

```bash
firebase deploy --only firestore:rules
```

### Basic Rules Structure:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Quiz rules (implement based on your requirements)
    match /quizzes/{quizId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.createdBy;
    }
    
    // Game session rules
    match /game_sessions/{sessionId} {
      allow read, write: if request.auth != null;
    }
    
    // Leaderboard rules
    match /leaderboards/{sessionId} {
      allow read: if request.auth != null;
    }
  }
}
```

## Environment Management

### Development vs Production

For proper environment separation:

1. **Development Environment**:
   - Create `quiz-app-dev` Firebase project
   - Use development configuration files
   - Test mode Firestore rules

2. **Production Environment**:
   - Create `quiz-app-prod` Firebase project  
   - Use production configuration files
   - Strict Firestore security rules

### Configuration File Management

**Important**: Configuration files are ignored by git for security:

```bash
# These files are in .gitignore
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

**For Development**:
- Each developer should have their own Firebase project
- Replace placeholder files with personal project configurations
- Never commit actual configuration files

## Verification

After configuration, verify your setup:

```bash
# Run platform verification
./scripts/quality-check.sh

# This will verify:
# - Firebase configuration files exist
# - Platform requirements are met
# - All platforms build successfully
```

## Common Issues & Solutions

### Android Build Failures

**Issue**: `google-services.json` parsing errors
**Solution**: Ensure the file is valid JSON from Firebase Console

**Issue**: NDK version mismatch  
**Solution**: File is already configured with correct NDK version

**Issue**: minSdk compatibility  
**Solution**: Already set to minSdk 23 for Firebase compatibility

### iOS Build Failures

**Issue**: CocoaPods dependency resolution
**Solution**: 
```bash
cd ios
rm -rf Pods
pod install
```

**Issue**: iOS deployment target too low
**Solution**: Already configured for iOS 13.0+

### Firebase Connection Issues

**Issue**: Firebase not connecting
**Solution**: Verify configuration files match your Firebase project exactly

**Issue**: Authentication not working
**Solution**: Check that Authentication is enabled in Firebase Console

## Next Steps

1. Replace placeholder configuration files with your Firebase project files
2. Test the app on all platforms
3. Deploy Firestore security rules
4. Set up Firebase hosting for web deployment (optional)
5. Configure CI/CD with Firebase (see GitHub Actions workflow)

## References

- [Firebase Flutter Setup Guide](https://firebase.google.com/docs/flutter/setup)
- [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [FlutterFire Documentation](https://firebase.flutter.dev/)