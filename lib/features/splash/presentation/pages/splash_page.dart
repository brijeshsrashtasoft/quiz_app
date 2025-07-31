import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../../authentication/domain/entities/auth_state.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

/// Splash screen that handles initial authentication check and navigation
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Start authentication check after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthenticationStatus();
    });
  }

  Future<void> _checkAuthenticationStatus() async {
    // Give splash screen minimum display time for smooth UX
    // Removed delay for faster startup

    if (!mounted) return;

    // Watch auth state and navigate accordingly
    ref
        .read(authStateProvider.future)
        .then((authState) {
          if (!mounted) return;

          if (authState.isAuthenticated) {
            // User is authenticated, go to home
            context.go(RouteConstants.home);
          } else {
            // User is not authenticated, go to login
            context.go(RouteConstants.login);
          }
        })
        .catchError((error) {
          // On error, default to login
          if (mounted) {
            context.go(RouteConstants.login);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.vibrantPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 120, color: AppColors.pureWhite),
            const SizedBox(height: AppSpacing.spacingL),
            Text(
              'Quiz App',
              style: AppTextStyles.gameTitle.copyWith(
                color: AppColors.pureWhite,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.pureWhite),
            ),
            const SizedBox(height: AppSpacing.spacingXL),
            Text(
              'Loading...',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.pureWhite.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
