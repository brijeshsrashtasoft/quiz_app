import 'logger.dart';

/// Track app startup performance milestones
class StartupPerformance {
  static DateTime? _appStartTime;
  static DateTime? _firebaseInitTime;
  static DateTime? _firstFrameTime;

  /// Mark when the app starts
  static void markAppStart() {
    _appStartTime = DateTime.now();
    AppLogger.info('[Startup] App start marked');
  }

  /// Mark when Firebase initialization completes
  static void markFirebaseInit() {
    _firebaseInitTime = DateTime.now();
    if (_appStartTime != null) {
      final duration = _firebaseInitTime!.difference(_appStartTime!);
      AppLogger.performance('Firebase initialization', duration);
    }
  }

  /// Mark when first frame is rendered
  static void markFirstFrame() {
    _firstFrameTime = DateTime.now();
    if (_appStartTime != null) {
      final duration = _firstFrameTime!.difference(_appStartTime!);
      AppLogger.performance('First frame render', duration);
    }
  }

  /// Get total startup time
  static Duration? get totalStartupTime {
    if (_appStartTime == null || _firstFrameTime == null) return null;
    return _firstFrameTime!.difference(_appStartTime!);
  }

  /// Get Firebase initialization time
  static Duration? get firebaseInitTime {
    if (_appStartTime == null || _firebaseInitTime == null) return null;
    return _firebaseInitTime!.difference(_appStartTime!);
  }

  /// Log startup performance summary
  static void logSummary() {
    if (_appStartTime == null) {
      AppLogger.warning('Startup performance not tracked');
      return;
    }

    final summary = StringBuffer('Startup Performance Summary:\n');

    if (totalStartupTime != null) {
      final totalMs = totalStartupTime!.inMilliseconds;
      summary.writeln('  Total startup: ${totalMs}ms');

      // Check against 3-second requirement
      if (totalMs > 3000) {
        summary.writeln('  ⚠️  WARNING: Startup exceeds 3-second requirement!');
      } else {
        summary.writeln('  ✅ Startup time meets requirement (<3000ms)');
      }
    }

    if (firebaseInitTime != null) {
      final firebaseMs = firebaseInitTime!.inMilliseconds;
      summary.writeln('  Firebase init: ${firebaseMs}ms');

      // Check Firebase initialization performance
      if (firebaseMs > 2000) {
        summary.writeln('  ⚠️  Firebase init is slow (>2000ms)');
      } else {
        summary.writeln('  ✅ Firebase init is acceptable');
      }
    }

    // Check app readiness
    _checkAppReadiness(summary);

    AppLogger.info(summary.toString());
  }

  /// Check if app is ready for user interaction
  static void _checkAppReadiness(StringBuffer summary) {
    final now = DateTime.now();

    if (_appStartTime != null) {
      final readinessTime = now.difference(_appStartTime!);
      summary.writeln('  App readiness: ${readinessTime.inMilliseconds}ms');

      if (readinessTime.inMilliseconds <= 3000) {
        summary.writeln('  ✅ App is ready for user interaction');
      } else {
        summary.writeln('  ⚠️  App readiness exceeds target');
      }
    }
  }

  /// Validate startup performance meets requirements
  static bool meetsPerformanceRequirements() {
    final total = totalStartupTime;
    if (total == null) return false;

    // Must start in under 3 seconds
    return total.inMilliseconds < 3000;
  }
}
