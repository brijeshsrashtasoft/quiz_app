# US-005: Email Verification

## User Story
As a registered user, I want to verify my email so that I can secure my account.

## Acceptance Criteria
- [ ] Verification email sent automatically after registration
- [ ] Email contains secure verification link
- [ ] Verification status shown in user profile
- [ ] Unverified users see reminder banner
- [ ] Resend verification option available
- [ ] Verification link expires after 7 days
- [ ] Success message after verification
- [ ] Some features restricted until verified
- [ ] Deep link handling for verification
- [ ] Auto-refresh UI after verification
- [ ] Rate limiting on resend (max 3 per hour)
- [ ] Works across all platforms

## Navigation Flow

### Current State
```
No email verification flow implemented
No verification status tracking
No UI indicators for verification state
```

### Required Implementation
```
1. Post-Registration Flow:
   /register → Create account → /register/verify-email
   ├── Show verification prompt
   ├── Email sent automatically
   ├── Resend option
   └── Continue to home (unverified)

2. Verification Link Flow:
   Email link → App deep link
   ├── Validate verification code
   ├── Mark email as verified
   ├── Show success message
   └── Redirect to /home (verified)

3. Unverified User Experience:
   Throughout app (unverified user)
   ├── Reminder banner on key pages
   ├── Restricted from certain features
   ├── Profile shows unverified status
   └── Easy access to resend
```

## Technical Implementation

### 1. Email Verification Page
```dart
// lib/features/authentication/presentation/pages/email_verification_page.dart

class EmailVerificationPage extends ConsumerStatefulWidget {
  final bool isInitialVerification;
  
  const EmailVerificationPage({
    Key? key,
    this.isInitialVerification = true,
  }) : super(key: key);
  
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  Timer? _checkTimer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  
  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }
  
  void _startVerificationCheck() {
    // Check verification status every 3 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          _onVerificationComplete();
        }
      }
    });
  }
  
  void _onVerificationComplete() {
    _checkTimer?.cancel();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email verified successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Update auth state
    ref.read(authStateProvider.notifier).refreshUser();
    
    // Navigate to appropriate page
    if (widget.isInitialVerification) {
      context.go('/onboarding/complete');
    } else {
      context.go('/profile');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        automaticallyImplyLeading: !widget.isInitialVerification,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_unread,
              size: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 32),
            Text(
              'Verify your email',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'We\'ve sent a verification link to:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Check your inbox'),
                      subtitle: Text('Look for an email from Quiz App'),
                    ),
                    ListTile(
                      leading: Icon(Icons.touch_app),
                      title: Text('Click the verification link'),
                      subtitle: Text('This will verify your email'),
                    ),
                    ListTile(
                      leading: Icon(Icons.check_circle),
                      title: Text('You\'re all set!'),
                      subtitle: Text('We\'ll automatically detect when verified'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Resend button
            OutlinedButton.icon(
              onPressed: _resendCooldown > 0 ? null : _resendVerificationEmail,
              icon: const Icon(Icons.refresh),
              label: Text(_resendCooldown > 0
                  ? 'Resend in $_resendCooldown seconds'
                  : 'Resend Verification Email'),
            ),
            
            const SizedBox(height: 16),
            
            // Skip for now (if initial verification)
            if (widget.isInitialVerification)
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Skip for now'),
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _resendVerificationEmail() async {
    // Check rate limiting
    final canResend = await ref
        .read(rateLimitServiceProvider)
        .canResendVerificationEmail();
    
    if (!canResend) {
      _showRateLimitError();
      return;
    }
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(
          ActionCodeSettings(
            url: 'https://yourapp.com/verify-email',
            handleCodeInApp: true,
            iOSBundleId: 'com.yourcompany.quizapp',
            androidPackageName: 'com.yourcompany.quizapp',
          ),
        );
        
        // Start cooldown
        _startResendCooldown();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
          ),
        );
      }
    } catch (e) {
      _showError(e);
    }
  }
  
  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _resendCooldown--);
      
      if (_resendCooldown <= 0) {
        timer.cancel();
      }
    });
  }
  
  @override
  void dispose() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
```

### 2. Verification Status Banner Widget
```dart
// lib/shared/widgets/email_verification_banner.dart

class EmailVerificationBanner extends ConsumerWidget {
  const EmailVerificationBanner({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    // Only show for authenticated, unverified users
    if (user == null || user.emailVerified) {
      return const SizedBox.shrink();
    }
    
    return MaterialBanner(
      backgroundColor: Colors.orange.shade50,
      leading: const Icon(Icons.warning_amber, color: Colors.orange),
      content: const Text(
        'Please verify your email to access all features',
      ),
      actions: [
        TextButton(
          onPressed: () => context.go('/verify-email'),
          child: const Text('Verify Now'),
        ),
      ],
    );
  }
}
```

### 3. Feature Restrictions for Unverified Users
```dart
// lib/core/guards/verification_guard.dart

class VerificationGuard {
  static const _restrictedRoutes = [
    '/quiz-creation',
    '/game/host',
    '/profile/edit',
  ];
  
  static bool requiresVerification(String path) {
    return _restrictedRoutes.any((route) => path.startsWith(route));
  }
  
  static String? checkVerification(BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null && 
        !user.emailVerified && 
        requiresVerification(state.fullPath ?? '')) {
      // Show message and redirect
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please verify your email to access this feature'),
          action: SnackBarAction(
            label: 'Verify',
            onPressed: () => context.go('/verify-email'),
          ),
        ),
      );
      
      return '/home';
    }
    
    return null;
  }
}
```

### 4. Deep Link Handler for Verification
```dart
// lib/core/navigation/deep_link_handler.dart

static Future<String?> handleEmailVerificationLink(Uri uri) async {
  final code = uri.queryParameters['oobCode'];
  final mode = uri.queryParameters['mode'];
  
  if (mode == 'verifyEmail' && code != null) {
    try {
      // Apply the verification code
      await FirebaseAuth.instance.applyActionCode(code);
      
      // Reload user to get updated verification status
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      
      return '/verify-email/success';
    } catch (e) {
      return '/verify-email/error?message=${Uri.encodeComponent(e.toString())}';
    }
  }
  
  return null;
}
```

### 5. Update User Profile Display
```dart
// lib/features/profile/presentation/widgets/profile_header.dart

class ProfileHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(userProfileProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar and name
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              profile?.displayName ?? 'User',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            // Verification status
            const SizedBox(height: 8),
            if (user != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    user.emailVerified
                        ? Icons.verified_user
                        : Icons.warning_amber,
                    size: 16,
                    color: user.emailVerified
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.emailVerified
                        ? 'Verified'
                        : 'Unverified',
                    style: TextStyle(
                      color: user.emailVerified
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!user.emailVerified) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => context.go('/verify-email'),
                      child: const Text('Verify'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
```

### 6. Auto-Refresh Auth State
```dart
// lib/features/authentication/application/auth_state_notifier.dart

class AuthStateNotifier extends StateNotifier<AuthState> {
  StreamSubscription? _authStateSubscription;
  Timer? _verificationCheckTimer;
  
  void startVerificationCheck() {
    _verificationCheckTimer?.cancel();
    
    _verificationCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        final user = _auth.currentUser;
        if (user != null && !user.emailVerified) {
          await user.reload();
          if (user.emailVerified) {
            state = AuthState.authenticated(user);
            _verificationCheckTimer?.cancel();
          }
        }
      },
    );
  }
  
  Future<void> refreshUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      state = AuthState.authenticated(_auth.currentUser!);
    }
  }
}
```

### 7. Rate Limiting for Resend
```dart
// lib/features/authentication/data/services/rate_limit_service.dart

Future<bool> canResendVerificationEmail() async {
  const key = 'verification_resend_attempts';
  const maxAttempts = 3;
  const windowMinutes = 60;
  
  final attempts = _getAttempts(key);
  final recentAttempts = attempts.where((attempt) {
    final attemptTime = DateTime.parse(attempt['timestamp']);
    return DateTime.now().difference(attemptTime).inMinutes < windowMinutes;
  }).toList();
  
  return recentAttempts.length < maxAttempts;
}
```

## Email Template

### Verification Email
```html
Subject: Verify your Quiz App email

Welcome to Quiz App!

Please verify your email address by clicking the button below:

[Verify Email Button]

This link will expire in 7 days. After verifying, you'll have access to:
• Create and host quizzes
• Track your progress
• Compete on global leaderboards

If you're having trouble with the button, copy and paste this link:
{{verification_link}}

Thanks,
The Quiz App Team
```

## Restricted Features Matrix

| Feature | Unverified | Verified |
|---------|-----------|----------|
| Join games | ✅ | ✅ |
| View leaderboards | ✅ | ✅ |
| Basic profile | ✅ | ✅ |
| Create quizzes | ❌ | ✅ |
| Host games | ❌ | ✅ |
| Edit profile | Limited | ✅ |
| View full history | ❌ | ✅ |
| Export data | ❌ | ✅ |

## Testing Requirements

### Unit Tests
- [ ] Verification status checking
- [ ] Rate limiting logic
- [ ] Deep link parsing
- [ ] Feature restriction logic

### Integration Tests
- [ ] Send verification email
- [ ] Handle verification link
- [ ] Auto-refresh after verification
- [ ] Banner display logic
- [ ] Resend with cooldown

### E2E Tests
- [ ] Complete verification flow
- [ ] Deep link on all platforms
- [ ] UI updates after verification
- [ ] Feature restrictions enforced

## Security Considerations
- Verification links expire after 7 days
- Single-use verification codes
- Rate limiting on resend attempts
- No sensitive data in verification links

## Related Issues
- Depends on: US-001 (Email sign up)
- Related: US-004 (Password reset)
- Blocks: Quiz creation features
- Enhances: Account security

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Email template configured
- [ ] Deep linking working on all platforms
- [ ] Auto-refresh implemented
- [ ] Unit tests passing (>90% coverage)
- [ ] Integration tests passing
- [ ] Manual testing completed
- [ ] Code reviewed and approved
- [ ] Security review passed