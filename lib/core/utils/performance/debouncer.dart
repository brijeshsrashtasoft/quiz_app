import 'dart:async';

/// Debouncer class for optimizing rapid state changes
/// Ensures only the last event is processed after a delay
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// Run the callback after the delay, cancelling any previous calls
  void run(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Cancel any pending callbacks
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of the debouncer
  void dispose() {
    _timer?.cancel();
  }
}

/// Extension for easy debouncing on functions
extension DebouncerExtension on void Function() {
  void Function() debounce(Duration delay) {
    final debouncer = Debouncer(delay: delay);
    return () => debouncer.run(this);
  }
}
