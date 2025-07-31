# US-002: Google Sign-In

## User Story
As a user, I want to sign in with Google so that I can quickly access my account without remembering another password.

## Acceptance Criteria
- [ ] Google Sign-In button visible on login page
- [ ] Google Sign-In button visible on register page
- [ ] Google Sign-In available on home page for unauthenticated users
- [ ] Native Google sign-in flow on mobile (iOS/Android)
- [ ] Web OAuth flow for web platform
- [ ] Creates user profile if first time
- [ ] Links to existing profile if email matches
- [ ] Handles cancelled sign-in gracefully
- [ ] Shows appropriate error messages
- [ ] Loading state during authentication
- [ ] Redirects to home after successful sign-in
- [ ] Profile photo and display name populated from Google

## Navigation Flow

### Current State
```
Google Sign-In button exists in LoginPage but flow not complete
No integration with main navigation flow
```

### Required Implementation
```
1. Entry Points:
   - /home → "Sign in with Google" → Google OAuth → /home (authenticated)
   - /login → Google button → Google OAuth → /home (authenticated)
   - /register → Google button → Google OAuth → /home (authenticated)
   - /game/join → Post-game prompt → Google OAuth → /home (authenticated)

2. Google Sign-In Flow:
   Trigger Google Auth
   ├── Show native picker (mobile) or popup (web)
   ├── User selects account
   ├── Receive Google credentials
   ├── Sign in to Firebase Auth
   ├── Check if user exists in Firestore
   │   ├── Yes: Update last login
   │   └── No: Create profile from Google data
   └── Navigate to /home (authenticated)

3. Error Handling:
   - User cancels → Stay on current page
   - Network error → Show retry option
   - Account disabled → Show contact support
```

## Technical Implementation

### 1. Configure Google Sign-In
```dart
// lib/core/config/google_signin_config.dart

class GoogleSignInConfig {
  // Web Client ID from Firebase Console
  static const webClientId = 'YOUR_WEB_CLIENT_ID';
  
  // iOS URL Scheme (Info.plist)
  static const iosUrlScheme = 'com.googleusercontent.apps.YOUR_IOS_CLIENT_ID';
}
```

### 2. Update Authentication Repository
```dart
// lib/features/authentication/data/repositories/authentication_repository_impl.dart

Future<Either<Failure, User>> signInWithGoogle() async {
  try {
    // Platform-specific sign-in
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      return const Left(AuthFailure.cancelled());
    }
    
    final GoogleSignInAuthentication googleAuth = 
        await googleUser.authentication;
    
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;
    
    // Create or update user profile
    await _createOrUpdateGoogleProfile(user, googleUser);
    
    return Right(user);
  } catch (e) {
    return Left(AuthFailure.fromException(e));
  }
}

Future<void> _createOrUpdateGoogleProfile(
  User firebaseUser,
  GoogleSignInAccount googleUser,
) async {
  final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
  final snapshot = await userDoc.get();
  
  if (!snapshot.exists) {
    // Create new profile
    final profile = UserProfile(
      uid: firebaseUser.uid,
      email: googleUser.email,
      displayName: googleUser.displayName ?? 'User',
      photoUrl: googleUser.photoUrl,
      authProvider: 'google',
      createdAt: FieldValue.serverTimestamp(),
      stats: UserStats.initial(),
      preferences: UserPreferences.defaults(),
    );
    
    await userDoc.set(profile.toJson());
  } else {
    // Update last login
    await userDoc.update({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'photoUrl': googleUser.photoUrl,
    });
  }
}
```

### 3. Platform-Specific Setup

#### Web Configuration
```html
<!-- web/index.html -->
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

#### iOS Configuration
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

#### Android Configuration
```xml
<!-- android/app/src/main/res/values/strings.xml -->
<string name="default_web_client_id">YOUR_WEB_CLIENT_ID</string>
```

### 4. Update UI Components
```dart
// lib/shared/widgets/google_signin_button.dart

class GoogleSignInButton extends ConsumerWidget {
  final VoidCallback? onSuccess;
  final String label;
  
  const GoogleSignInButton({
    Key? key,
    this.onSuccess,
    this.label = 'Sign in with Google',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return ElevatedButton.icon(
      onPressed: authState.isLoading
          ? null
          : () => _handleGoogleSignIn(context, ref),
      icon: Image.asset(
        'assets/icons/google_logo.png',
        height: 20,
      ),
      label: authState.isLoading
          ? const CircularProgressIndicator()
          : Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
  
  Future<void> _handleGoogleSignIn(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await ref
        .read(authStateProvider.notifier)
        .signInWithGoogle();
    
    result.fold(
      (failure) => _showError(context, failure),
      (_) {
        onSuccess?.call();
        context.go('/home');
      },
    );
  }
}
```

### 5. Update Pages
```dart
// lib/features/authentication/presentation/pages/login_page.dart

// Add Google Sign-In button
GoogleSignInButton(
  label: 'Sign in with Google',
  onSuccess: () => context.go('/home'),
),

const SizedBox(height: 16),
Row(
  children: const [
    Expanded(child: Divider()),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text('OR'),
    ),
    Expanded(child: Divider()),
  ],
),
const SizedBox(height: 16),
```

## Error Handling

### Google Sign-In Errors
```dart
enum GoogleSignInError {
  cancelled('Sign in cancelled'),
  networkError('Network error. Please check your connection'),
  accountDisabled('This account has been disabled'),
  emailAlreadyInUse('Email already associated with another account'),
  unknown('Sign in failed. Please try again');
  
  final String message;
  const GoogleSignInError(this.message);
}

// Handle platform-specific errors
String getErrorMessage(dynamic error) {
  if (error is PlatformException) {
    switch (error.code) {
      case 'sign_in_canceled':
        return GoogleSignInError.cancelled.message;
      case 'network_error':
        return GoogleSignInError.networkError.message;
      case 'sign_in_failed':
        return GoogleSignInError.unknown.message;
    }
  }
  return GoogleSignInError.unknown.message;
}
```

## Account Linking

### Email Conflict Resolution
```dart
// When Google email matches existing email/password account
Future<void> _handleEmailConflict(String email) async {
  final methods = await _auth.fetchSignInMethodsForEmail(email);
  
  if (methods.contains('password')) {
    // Prompt user to sign in with password first
    // Then link Google account
    showDialog(
      context: context,
      builder: (_) => LinkAccountDialog(
        email: email,
        provider: 'Google',
      ),
    );
  }
}
```

## Testing Requirements

### Unit Tests
- [ ] Google sign-in success flow
- [ ] Google sign-in cancellation
- [ ] Profile creation for new users
- [ ] Profile update for existing users
- [ ] Error handling

### Integration Tests
- [ ] Complete Google sign-in flow
- [ ] Firebase Auth integration
- [ ] Firestore profile management
- [ ] Navigation after sign-in

### Platform Tests
- [ ] Web OAuth flow works
- [ ] iOS native picker works
- [ ] Android native picker works
- [ ] Deep linking returns to app

## Dependencies
- google_sign_in: ^6.1.0
- Firebase Auth with Google provider enabled
- OAuth 2.0 client IDs configured
- Platform-specific configurations

## Security Considerations
- [ ] Client IDs properly restricted
- [ ] Web origins whitelisted
- [ ] Bundle IDs verified
- [ ] No secrets in client code

## Related Issues
- Related: US-001 (Email sign up)
- Related: US-003 (Guest play)
- Blocks: Profile completion flow

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Platform-specific configs complete
- [ ] Unit tests passing (>90% coverage)
- [ ] Integration tests passing
- [ ] Manual testing on all platforms
- [ ] Code reviewed and approved
- [ ] No security vulnerabilities
- [ ] Documentation updated