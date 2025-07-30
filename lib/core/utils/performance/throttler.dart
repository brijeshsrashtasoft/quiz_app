import 'dart:async';

/// Throttler class for limiting the rate of function calls
/// Ensures function is called at most once per specified duration
class Throttler {
  final Duration duration;
  Timer? _timer;
  bool _isThrottling = false;
  void Function()? _pendingCallback;

  Throttler({required this.duration});

  /// Run the callback immediately if not throttling, 
  /// otherwise queue it to run after the throttle period
  void run(void Function() callback) {
    if (!_isThrottling) {
      callback();
      _isThrottling = true;
      _timer = Timer(duration, () {
        _isThrottling = false;
        if (_pendingCallback != null) {
          final pending = _pendingCallback!;
          _pendingCallback = null;
          run(pending);
        }
      });
    } else {
      _pendingCallback = callback;
    }
  }

  /// Cancel any pending callbacks
  void cancel() {
    _timer?.cancel();
    _isThrottling = false;
    _pendingCallback = null;
  }

  /// Dispose of the throttler
  void dispose() {
    cancel();
  }
}

/// Extension for easy throttling on functions
extension ThrottlerExtension on void Function() {
  void Function() throttle(Duration duration) {
    final throttler = Throttler(duration: duration);
    return () => throttler.run(this);
  }
}