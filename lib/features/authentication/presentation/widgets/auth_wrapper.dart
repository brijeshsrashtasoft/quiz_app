import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../../../../core/navigation/route_constants.dart';
import '../providers/auth_providers.dart';

/// Authentication wrapper widget that handles app-level authentication state
/// Routes users to appropriate screens based on authentication status
/// Following Kahoot-style engaging UI design
class AuthWrapperWidget extends ConsumerWidget {
  final Widget authenticatedChild;
  final Widget? unauthenticatedChild;
  final bool showSplashScreen;
  final Duration splashDuration;

  const AuthWrapperWidget({
    super.key,
    required this.authenticatedChild,
    this.unauthenticatedChild,
    this.showSplashScreen = true,
    this.splashDuration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => showSplashScreen
          ? const AuthSplashScreen()
          : const AuthLoadingScreen(),
      error: (error, stackTrace) => AuthErrorScreen(
        error: error.toString(),
        onRetry: () => ref.invalidate(authStateProvider),
      ),
      data: (state) {
        if (state.isLoading) {
          return showSplashScreen
              ? const AuthSplashScreen()
              : const AuthLoadingScreen();
        }

        if (state.hasError) {
          return AuthErrorScreen(
            error: state.errorMessage ?? 'Authentication error occurred',
            onRetry: () => ref.invalidate(authStateProvider),
          );
        }

        if (state.isAuthenticated) {
          return authenticatedChild;
        }

        // User is not authenticated
        return unauthenticatedChild ?? const AuthRedirectScreen();
      },
    );
  }
}

/// Splash screen with app branding shown during authentication loading
class AuthSplashScreen extends StatefulWidget {
  const AuthSplashScreen({super.key});

  @override
  State<AuthSplashScreen> createState() => _AuthSplashScreenState();
}

class _AuthSplashScreenState extends State<AuthSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Logo animation
    _logoController = AnimationController(
      duration: AppAnimations.longAnimation,
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: AppAnimations.bounce),
    );

    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: AppAnimations.elastic),
    );

    // Pulse animation for loading indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _logoController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.vibrantPurple,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Transform.rotate(
                        angle: _logoRotation.value,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.pureWhite.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.quiz,
                            size: 80,
                            color: AppColors.vibrantPurple,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.spacingXL),

                // App Name
                Text(
                  'Quiz Master',
                  style: AppTextStyles.gameTitle.copyWith(
                    color: AppColors.pureWhite,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppSpacing.spacingS),

                // Tagline
                Text(
                  'Challenge Your Mind',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.pureWhite.withValues(alpha: 0.8),
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: AppSpacing.spacingXXL),

                // Pulsing Loading Indicator
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseScale.value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.pureWhite,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.spacingL),

                // Loading Text
                Text(
                  'Loading your quiz experience...',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.pureWhite.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple loading screen for quick authentication checks
class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingPageLayout(
      message: 'Checking authentication...',
      backgroundColor: AppColors.offWhite,
      spinnerColor: AppColors.vibrantPurple,
    );
  }
}

/// Error screen shown when authentication fails
class AuthErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const AuthErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorPageLayout(
      title: 'Authentication Error',
      message: error,
      onRetry: onRetry,
      retryButtonText: 'Try Again',
      icon: Icons.security,
    );
  }
}

/// Redirect screen that navigates to login when user is not authenticated
class AuthRedirectScreen extends StatefulWidget {
  const AuthRedirectScreen({super.key});

  @override
  State<AuthRedirectScreen> createState() => _AuthRedirectScreenState();
}

class _AuthRedirectScreenState extends State<AuthRedirectScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(RouteConstants.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const AuthLoadingScreen();
  }
}

/// Authentication state listener that performs actions based on auth changes
class AuthStateListener extends ConsumerWidget {
  final Widget child;
  final void Function(AuthState previousState, AuthState currentState)?
  onAuthStateChanged;

  const AuthStateListener({
    super.key,
    required this.child,
    this.onAuthStateChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      final previousState = previous?.value;
      final currentState = next.value;

      if (previousState != null && currentState != null) {
        onAuthStateChanged?.call(previousState, currentState);

        // Handle automatic navigation based on auth state changes
        if (previousState.isUnauthenticated && currentState.isAuthenticated) {
          // User just signed in
          context.go(RouteConstants.home);
        } else if (previousState.isAuthenticated &&
            currentState.isUnauthenticated) {
          // User just signed out
          context.go(RouteConstants.login);
        }
      }
    });

    return child;
  }
}

/// Authenticated route guard that shows login screen if user is not authenticated
class AuthenticatedRoute extends ConsumerWidget {
  final Widget child;
  final bool requireEmailVerification;

  const AuthenticatedRoute({
    super.key,
    required this.child,
    this.requireEmailVerification = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const AuthLoadingScreen(),
      error: (error, stackTrace) => AuthErrorScreen(
        error: error.toString(),
        onRetry: () => ref.invalidate(authStateProvider),
      ),
      data: (state) {
        if (state.isLoading) {
          return const AuthLoadingScreen();
        }

        if (!state.isAuthenticated) {
          return const AuthRedirectScreen();
        }

        // Check email verification if required
        if (requireEmailVerification &&
            state.firebaseUser != null &&
            !state.firebaseUser!.emailVerified) {
          return const EmailVerificationScreen();
        }

        return child;
      },
    );
  }
}

/// Email verification screen for users who need to verify their email
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isResending = false;

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);

    try {
      final user = ref.read(currentFirebaseUserProvider);
      await user?.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Check your inbox.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send verification email: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    final user = ref.read(currentFirebaseUserProvider);
    await user?.reload();
    ref.invalidate(authStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentFirebaseUserProvider);

    return AppScaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPaddingAll,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email verification icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.mark_email_unread,
                    size: 60,
                    color: AppColors.warning,
                  ),
                ),

                const SizedBox(height: AppSpacing.spacingXL),

                // Title
                Text(
                  'Verify Your Email',
                  style: AppTextStyles.sectionHeader.copyWith(
                    color: AppColors.charcoal,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.spacingM),

                // Message
                Text(
                  'We\'ve sent a verification email to:\n${user?.email ?? 'your email address'}',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.coolGray,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.spacingL),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 20),
                      const SizedBox(width: AppSpacing.spacingS),
                      Expanded(
                        child: Text(
                          'Click the link in your email to verify your account, then return here.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.spacingXL),

                // Check verification button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _checkVerificationStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vibrantPurple,
                      foregroundColor: AppColors.pureWhite,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.spacingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('I\'ve Verified My Email'),
                  ),
                ),

                const SizedBox(height: AppSpacing.spacingM),

                // Resend email button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isResending ? null : _resendVerificationEmail,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.vibrantPurple,
                      side: const BorderSide(color: AppColors.vibrantPurple),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.spacingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isResending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.vibrantPurple,
                              ),
                            ),
                          )
                        : const Text('Resend Verification Email'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
