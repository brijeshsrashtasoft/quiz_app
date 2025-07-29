# Firebase Setup

- Replace placeholder Firebase config files with your project credentials
- Required for deployment across all platforms

## Requirements

- **Android**: minSdk 23+, NDK 27.0.12077973 ✅
- **iOS**: 13.0+, CocoaPods required ✅
- **Web**: Firebase JS SDK ✅

## Setup Steps

### 1. Create Firebase Project
- Go to [Firebase Console](https://console.firebase.google.com/)
- Create project: `quiz-app-dev` or `quiz-app-prod`
- Enable Google Analytics

### 2. Enable Services
- **Authentication**: Email/Password + Google Sign-In
- **Firestore**: Create database (test mode)
- **Storage**: Enable file storage
- **Analytics**: Auto-enabled
- **Cloud Functions**: Setup later

### 3. Configure Android
- Add Android app: `com.example.quiz_app`
- Download `google-services.json`
- Replace: `cp ~/Downloads/google-services.json android/app/`

### 4. Configure iOS
- Add iOS app: `com.example.quiz_app`
- Download `GoogleService-Info.plist`
- Replace: `cp ~/Downloads/GoogleService-Info.plist ios/Runner/`

### 5. Configure Web
- Add Web app: "Quiz App Web"
- Copy config object
- Update `lib/core/firebase/firebase_options.dart`

## Security Rules

- Deploy: `firebase deploy --only firestore:rules`
- Users: Read/write own data only
- Quizzes: Read all, write own
- Game sessions: Auth required
- Leaderboards: Read only

## Environment Management

- **Dev**: `quiz-app-dev` project, test rules
- **Prod**: `quiz-app-prod` project, strict rules
- **Config files**: Ignored by git for security
- **Developer setup**: Own Firebase project per dev

## Verification

- Run: `./scripts/quality-check.sh`
- Checks: Config files, requirements, builds

## Common Issues

- **Android JSON errors**: Use valid file from Firebase Console
- **NDK mismatch**: Already configured ✅
- **iOS CocoaPods**: `cd ios && rm -rf Pods && pod install`
- **Connection issues**: Verify config files match project
- **Auth not working**: Enable in Firebase Console

## Next Steps

- Replace placeholder config files
- Test all platforms
- Deploy security rules
- Setup CI/CD (GitHub Actions)

## References

- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [FlutterFire Docs](https://firebase.flutter.dev/)