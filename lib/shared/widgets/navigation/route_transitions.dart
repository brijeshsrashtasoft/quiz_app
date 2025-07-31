import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_colors.dart';

/// Custom route transitions following Kahoot-style animations
/// Reference: docs/ui_guideline.md - Animations & Interactions section
class RouteTransitions {
  RouteTransitions._();

  /// Slide transition from right (default Material transition)
  static CustomTransitionPage<T> slideFromRight<T extends Object?>(
    GoRouterState state,
    Widget child, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = AppAnimations.easeInOut;

        final slideTween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: slideTween.animate(curvedAnimation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// Slide transition from bottom (for modals and sheets)
  static CustomTransitionPage<T> slideFromBottom<T extends Object?>(
    GoRouterState state,
    Widget child, {
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = AppAnimations.easeOut;

        final slideTween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: slideTween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  /// Fade transition for seamless navigation
  static CustomTransitionPage<T> fade<T extends Object?>(
    GoRouterState state,
    Widget child, {
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: AppAnimations.easeInOut,
          ),
          child: child,
        );
      },
    );
  }

  /// Scale transition for game-related pages
  static CustomTransitionPage<T> scaleFromCenter<T extends Object?>(
    GoRouterState state,
    Widget child, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = AppAnimations.bounce;

        final scaleTween = Tween(begin: 0.8, end: 1.0);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return ScaleTransition(
          scale: scaleTween.animate(curvedAnimation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// Iris out transition for game over screens
  static CustomTransitionPage<T> irisOut<T extends Object?>(
    GoRouterState state,
    Widget child, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ClipPath(
          clipper: _CircularClipper(animation.value),
          child: child,
        );
      },
    );
  }

  /// Loading overlay transition for navigation states
  static Widget buildLoadingTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Stack(
      children: [
        child,
        if (animation.status == AnimationStatus.forward ||
            animation.status == AnimationStatus.reverse)
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final opacity = animation.status == AnimationStatus.forward
                  ? 1.0 - animation.value
                  : animation.value;

              if (opacity <= 0.0) return const SizedBox.shrink();

              return Positioned.fill(
                child: Container(
                  color: AppColors.charcoal.withValues(alpha: opacity * 0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowDark,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.vibrantPurple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading...',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.charcoal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  /// Error transition for failed navigations
  static Widget buildErrorTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    String? error,
  ) {
    return Stack(
      children: [
        child,
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Positioned.fill(
              child: Container(
                color: AppColors.error.withValues(alpha: 0.1),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Navigation Error',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            error,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Custom circular clipper for iris out effect
class _CircularClipper extends CustomClipper<Path> {
  final double progress;

  _CircularClipper(this.progress);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width > size.height ? size.width : size.height) / 2;
    final radius = maxRadius * progress;

    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is _CircularClipper && oldClipper.progress != progress;
  }
}

/// Route transition builder extensions for common patterns
extension RouteTransitionBuilders on GoRouter {
  /// Build slide transition for route
  static Widget buildSlideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    Offset? begin,
    Offset? end,
    Curve? curve,
  }) {
    final slideBegin = begin ?? const Offset(1.0, 0.0);
    final slideEnd = end ?? Offset.zero;
    final slideCurve = curve ?? AppAnimations.easeInOut;

    final slideTween = Tween(begin: slideBegin, end: slideEnd);
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: slideCurve,
    );

    return SlideTransition(
      position: slideTween.animate(curvedAnimation),
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  /// Build scale transition for route
  static Widget buildScaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    double? beginScale,
    double? endScale,
    Curve? curve,
  }) {
    final scaleBegin = beginScale ?? 0.8;
    final scaleEnd = endScale ?? 1.0;
    final scaleCurve = curve ?? AppAnimations.bounce;

    final scaleTween = Tween(begin: scaleBegin, end: scaleEnd);
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: scaleCurve,
    );

    return ScaleTransition(
      scale: scaleTween.animate(curvedAnimation),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
