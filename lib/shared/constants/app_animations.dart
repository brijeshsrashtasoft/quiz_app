import 'package:flutter/material.dart';

/// Animation constants and configurations following Kahoot-style interactions
/// Reference: docs/ui_guideline.md - Animations & Interactions section
class AppAnimations {
  AppAnimations._();

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  static const Duration extraLongAnimation = Duration(milliseconds: 800);

  // Micro-interaction durations
  static const Duration buttonTapDuration = Duration(milliseconds: 200);
  static const Duration correctAnswerDuration = Duration(milliseconds: 500);
  static const Duration wrongAnswerDuration = Duration(milliseconds: 500);
  static const Duration newQuestionDuration = Duration(milliseconds: 300);
  static const Duration scoreUpdateDuration = Duration(milliseconds: 800);
  static const Duration achievementDuration = Duration(milliseconds: 600);
  static const Duration timerWarningDuration = Duration(milliseconds: 1000);

  // Screen transition durations
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration gameStartDuration = Duration(milliseconds: 400);
  static const Duration gameOverDuration = Duration(milliseconds: 500);
  static const Duration leaderboardDuration = Duration(milliseconds: 350);

  // Animation Curves
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve elastic = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve spring = Curves.fastOutSlowIn;
  static const Curve linear = Curves.linear;

  // Micro-interaction curves
  static const Curve buttonTapCurve = easeOut;
  static const Curve correctAnswerCurve = elastic;
  static const Curve wrongAnswerCurve = spring;
  static const Curve newQuestionCurve = easeInOut;
  static const Curve scoreUpdateCurve = easeOut;
  static const Curve achievementCurve = bounce;
  static const Curve timerWarningCurve = linear;

  // Scale Animation Values
  static const double buttonPressScale = 0.95; // Scale down 5% on press
  static const double pulseScaleMin = 0.98; // Minimum pulse scale
  static const double pulseScaleMax = 1.02; // Maximum pulse scale
  static const double achievementScale = 1.1; // Achievement popup scale
  static const double confettiScale = 1.2; // Confetti burst scale

  // Slide Animation Distances
  static const double slideDistance = 300.0; // Default slide distance
  static const double microSlideDistance = 8.0; // Small shake/slide distance
  static const double questionSlideDistance =
      400.0; // Question transition slide

  // Rotation Animation Values
  static const double shakeRotation = 5.0; // Degrees for shake animation
  static const double spinRotation = 360.0; // Full spin rotation
  static const double tiltRotation = 2.0; // Subtle tilt animation

  // Opacity Animation Values
  static const double fadeInStart = 0.0;
  static const double fadeInEnd = 1.0;
  static const double fadeOutStart = 1.0;
  static const double fadeOutEnd = 0.0;
  static const double dimmedOpacity = 0.5; // Dimmed state opacity
  static const double disabledOpacity = 0.6; // Disabled state opacity

  // Stagger Animation Delays
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration listItemStagger = Duration(milliseconds: 100);
  static const Duration leaderboardStagger = Duration(milliseconds: 80);

  // Animation Controllers Configuration
  static const double animationControllerLowerBound = 0.0;
  static const double animationControllerUpperBound = 1.0;

  // Pre-configured Animation Tweens
  static final Tween<double> scaleTween = Tween<double>(
    begin: 1.0,
    end: buttonPressScale,
  );

  static final Tween<double> fadeInTween = Tween<double>(
    begin: fadeInStart,
    end: fadeInEnd,
  );

  static final Tween<double> slideUpTween = Tween<double>(
    begin: slideDistance,
    end: 0.0,
  );

  static final Tween<double> slideDownTween = Tween<double>(
    begin: -slideDistance,
    end: 0.0,
  );

  static final Tween<double> pulseTween = Tween<double>(
    begin: pulseScaleMin,
    end: pulseScaleMax,
  );

  static final Tween<double> rotationTween = Tween<double>(
    begin: -shakeRotation,
    end: shakeRotation,
  );

  // Common Animation Sequences

  /// Button press animation configuration
  static AnimationSequence get buttonPress => AnimationSequence([
    AnimationStep(
      duration: buttonTapDuration,
      curve: buttonTapCurve,
      tween: scaleTween,
    ),
  ]);

  /// Correct answer feedback animation
  static AnimationSequence get correctAnswer => AnimationSequence([
    AnimationStep(
      duration: const Duration(milliseconds: 200),
      curve: elastic,
      tween: Tween<double>(begin: 1.0, end: 1.1),
    ),
    AnimationStep(
      duration: const Duration(milliseconds: 300),
      curve: easeOut,
      tween: Tween<double>(begin: 1.1, end: 1.0),
    ),
  ]);

  /// Wrong answer shake animation
  static AnimationSequence get wrongAnswer => AnimationSequence([
    AnimationStep(
      duration: const Duration(milliseconds: 100),
      curve: linear,
      tween: Tween<double>(begin: 0.0, end: microSlideDistance),
    ),
    AnimationStep(
      duration: const Duration(milliseconds: 100),
      curve: linear,
      tween: Tween<double>(begin: microSlideDistance, end: -microSlideDistance),
    ),
    AnimationStep(
      duration: const Duration(milliseconds: 100),
      curve: linear,
      tween: Tween<double>(begin: -microSlideDistance, end: microSlideDistance),
    ),
    AnimationStep(
      duration: const Duration(milliseconds: 100),
      curve: linear,
      tween: Tween<double>(begin: microSlideDistance, end: 0.0),
    ),
  ]);

  /// New question slide up animation
  static AnimationSequence get newQuestion => AnimationSequence([
    AnimationStep(
      duration: newQuestionDuration,
      curve: newQuestionCurve,
      tween: slideUpTween,
    ),
  ]);

  /// Achievement celebration animation
  static AnimationSequence get achievement => AnimationSequence([
    AnimationStep(
      duration: const Duration(milliseconds: 300),
      curve: bounce,
      tween: Tween<double>(begin: 0.0, end: achievementScale),
    ),
    AnimationStep(
      duration: const Duration(milliseconds: 300),
      curve: easeOut,
      tween: Tween<double>(begin: achievementScale, end: 1.0),
    ),
  ]);

  // Timer pulse animation for warning state
  static AnimationSequence get timerWarning => AnimationSequence([
    AnimationStep(
      duration: const Duration(milliseconds: 500),
      curve: easeInOut,
      tween: pulseTween,
    ),
    AnimationStep(
      duration: const Duration(milliseconds: 500),
      curve: easeInOut,
      tween: Tween<double>(begin: pulseScaleMax, end: pulseScaleMin),
    ),
  ]);

  /// Bounce in-out animation for interactive elements
  static AnimationSequence get bounceInOut => AnimationSequence([
    AnimationStep(
      duration: const Duration(milliseconds: 200),
      curve: bounce,
      tween: Tween<double>(begin: 1.0, end: 1.1),
    ),
    AnimationStep(
      duration: const Duration(milliseconds: 200),
      curve: easeOut,
      tween: Tween<double>(begin: 1.1, end: 1.0),
    ),
  ]);

  /// Slide in-out animation for cards and buttons
  static AnimationSequence get slideInOut => AnimationSequence([
    AnimationStep(
      duration: const Duration(milliseconds: 300),
      curve: easeInOut,
      tween: Tween<double>(begin: 0.0, end: 1.0),
    ),
  ]);

  // Loading animation configuration
  static const Duration loadingRotationDuration = Duration(milliseconds: 1500);
  static const Curve loadingRotationCurve = linear;

  // Particle animation settings for confetti/celebration
  static const int confettiParticleCount = 50;
  static const Duration confettiDuration = Duration(milliseconds: 3000);
  static const double confettiSpread = 100.0;
  static const double confettiGravity = 0.5;

  // Ripple animation settings
  static const Duration rippleDuration = Duration(milliseconds: 600);
  static const double rippleRadius = 40.0;
  static const Curve rippleCurve = easeOut;

  // Page transition configurations
  static const Offset slideTransitionBegin = Offset(1.0, 0.0);
  static const Offset slideTransitionEnd = Offset.zero;
  static const Offset slideUpTransitionBegin = Offset(0.0, 1.0);
  static const Offset slideUpTransitionEnd = Offset.zero;

  // Staggered animation helpers
  static Duration getStaggeredDelay(
    int index, {
    Duration baseDelay = staggerDelay,
  }) {
    return Duration(milliseconds: baseDelay.inMilliseconds * index);
  }

  static Duration getLeaderboardStagger(int index) {
    return Duration(milliseconds: leaderboardStagger.inMilliseconds * index);
  }

  // Animation state helpers
  static bool isAnimating(AnimationController controller) {
    return controller.status == AnimationStatus.forward ||
        controller.status == AnimationStatus.reverse;
  }

  static bool isCompleted(AnimationController controller) {
    return controller.status == AnimationStatus.completed;
  }
}

/// Helper class for defining animation sequences
class AnimationSequence {
  final List<AnimationStep> steps;

  const AnimationSequence(this.steps);

  Duration get totalDuration {
    return steps.fold(Duration.zero, (sum, step) => sum + step.duration);
  }
}

/// Individual animation step configuration
class AnimationStep {
  final Duration duration;
  final Curve curve;
  final Tween<double> tween;

  const AnimationStep({
    required this.duration,
    required this.curve,
    required this.tween,
  });
}
