import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring mixin for UI components
mixin PerformanceMonitor<T extends StatefulWidget> on State<T> {
  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<Duration>> _measurements = {};
  final Map<String, FrameCallback> _frameCallbacks = {};
  bool _isMonitoring = false;

  /// Start monitoring performance
  void startPerformanceMonitoring() {
    _isMonitoring = true;
  }

  /// Stop monitoring performance
  void stopPerformanceMonitoring() {
    _isMonitoring = false;
    _clearFrameCallbacks();
  }

  /// Start timing an operation
  void startTimer(String operation) {
    if (!_isMonitoring) return;
    _timers[operation] = Stopwatch()..start();
  }

  /// Stop timing an operation and record the measurement
  Duration? stopTimer(String operation) {
    if (!_isMonitoring) return null;

    final timer = _timers[operation];
    if (timer == null || !timer.isRunning) return null;

    timer.stop();
    final duration = timer.elapsed;

    _measurements[operation] ??= [];
    _measurements[operation]!.add(duration);

    _timers.remove(operation);
    return duration;
  }

  /// Measure the time taken by a function
  Future<U> measureAsync<U>(String operation, Future<U> Function() fn) async {
    startTimer(operation);
    try {
      return await fn();
    } finally {
      stopTimer(operation);
    }
  }

  /// Measure the time taken by a synchronous function
  U measureSync<U>(String operation, U Function() fn) {
    startTimer(operation);
    try {
      return fn();
    } finally {
      stopTimer(operation);
    }
  }

  /// Monitor frame rendering performance
  void monitorFrameRendering(String key) {
    if (!_isMonitoring) return;

    void callback(Duration timestamp) {
      // Only record if monitoring is enabled and key is still active
      if (!_isMonitoring || !_frameCallbacks.containsKey(key)) return;

      final renderTime = SchedulerBinding.instance.currentFrameTimeStamp;
      _measurements['frame_$key'] ??= [];
      _measurements['frame_$key']!.add(
        Duration(
          microseconds: renderTime.inMicroseconds - timestamp.inMicroseconds,
        ),
      );
    }

    _frameCallbacks[key] = callback;
    SchedulerBinding.instance.addPersistentFrameCallback(callback);
  }

  /// Stop monitoring frame rendering for a specific key
  void stopFrameMonitoring(String key) {
    // Remove from our tracking map - callback will become inactive
    _frameCallbacks.remove(key);
  }

  /// Get average duration for an operation
  Duration? getAverageDuration(String operation) {
    final measurements = _measurements[operation];
    if (measurements == null || measurements.isEmpty) return null;

    final totalMicroseconds = measurements
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);

    return Duration(microseconds: totalMicroseconds ~/ measurements.length);
  }

  /// Get performance statistics for an operation
  PerformanceStats? getStats(String operation) {
    final measurements = _measurements[operation];
    if (measurements == null || measurements.isEmpty) return null;

    final microseconds = measurements.map((d) => d.inMicroseconds).toList();
    microseconds.sort();

    final sum = microseconds.reduce((a, b) => a + b);
    final average = sum / microseconds.length;
    final median = microseconds[microseconds.length ~/ 2];
    final min = microseconds.first;
    final max = microseconds.last;

    return PerformanceStats(
      operation: operation,
      count: measurements.length,
      average: Duration(microseconds: average.round()),
      median: Duration(microseconds: median),
      min: Duration(microseconds: min),
      max: Duration(microseconds: max),
    );
  }

  /// Get all performance statistics
  Map<String, PerformanceStats> getAllStats() {
    final stats = <String, PerformanceStats>{};
    for (final operation in _measurements.keys) {
      final stat = getStats(operation);
      if (stat != null) {
        stats[operation] = stat;
      }
    }
    return stats;
  }

  /// Clear all measurements
  void clearMeasurements() {
    _timers.clear();
    _measurements.clear();
  }

  /// Clear frame callbacks
  void _clearFrameCallbacks() {
    // Simply clear our tracking map - callbacks will become inactive
    _frameCallbacks.clear();
  }

  /// Print performance report
  void printPerformanceReport() {
    if (!_isMonitoring) {
      debugPrint('Performance monitoring is not enabled');
      return;
    }

    debugPrint('=== Performance Report ===');
    final stats = getAllStats();

    for (final stat in stats.values) {
      debugPrint('Operation: ${stat.operation}');
      debugPrint('  Count: ${stat.count}');
      debugPrint('  Average: ${stat.average.inMilliseconds}ms');
      debugPrint('  Median: ${stat.median.inMilliseconds}ms');
      debugPrint('  Min: ${stat.min.inMilliseconds}ms');
      debugPrint('  Max: ${stat.max.inMilliseconds}ms');
      debugPrint('');
    }
    debugPrint('========================');
  }

  @override
  void dispose() {
    stopPerformanceMonitoring();
    super.dispose();
  }
}

/// Performance statistics for an operation
class PerformanceStats {
  final String operation;
  final int count;
  final Duration average;
  final Duration median;
  final Duration min;
  final Duration max;

  const PerformanceStats({
    required this.operation,
    required this.count,
    required this.average,
    required this.median,
    required this.min,
    required this.max,
  });

  /// Check if performance meets target
  bool meetsTarget(Duration target) {
    return average <= target;
  }

  /// Get performance rating
  PerformanceRating get rating {
    if (average.inMilliseconds < 16) return PerformanceRating.excellent;
    if (average.inMilliseconds < 33) return PerformanceRating.good;
    if (average.inMilliseconds < 50) return PerformanceRating.acceptable;
    return PerformanceRating.poor;
  }
}

/// Performance rating enum
enum PerformanceRating {
  excellent, // < 16ms (60+ fps)
  good, // < 33ms (30+ fps)
  acceptable, // < 50ms (20+ fps)
  poor, // >= 50ms (< 20 fps)
}

/// Widget performance observer
class WidgetPerformanceObserver extends StatefulWidget {
  final Widget child;
  final String widgetName;
  final void Function(PerformanceStats stats)? onPerformanceUpdate;
  final Duration updateInterval;

  const WidgetPerformanceObserver({
    super.key,
    required this.child,
    required this.widgetName,
    this.onPerformanceUpdate,
    this.updateInterval = const Duration(seconds: 1),
  });

  @override
  State<WidgetPerformanceObserver> createState() =>
      _WidgetPerformanceObserverState();
}

class _WidgetPerformanceObserverState extends State<WidgetPerformanceObserver>
    with PerformanceMonitor<WidgetPerformanceObserver> {
  @override
  void initState() {
    super.initState();
    startPerformanceMonitoring();
    monitorFrameRendering(widget.widgetName);
    _schedulePerformanceUpdate();
  }

  void _schedulePerformanceUpdate() {
    Future.delayed(widget.updateInterval, () {
      if (!mounted) return;

      final stats = getStats('frame_${widget.widgetName}');
      if (stats != null) {
        widget.onPerformanceUpdate?.call(stats);
      }

      _schedulePerformanceUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return measureSync('build_${widget.widgetName}', () {
      return widget.child;
    });
  }

  @override
  void dispose() {
    stopFrameMonitoring(widget.widgetName);
    super.dispose();
  }
}
