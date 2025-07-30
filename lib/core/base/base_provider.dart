import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/result.dart';
import '../errors/failures.dart';

/// Base provider state for async operations
/// Following CLAUDE.md Riverpod state management patterns
class BaseAsyncState<T> {
  final bool isLoading;
  final T? data;
  final Failure? failure;

  const BaseAsyncState({this.isLoading = false, this.data, this.failure});

  /// Create loading state
  BaseAsyncState<T> copyWithLoading() {
    return BaseAsyncState<T>(isLoading: true, data: data, failure: null);
  }

  /// Create success state
  BaseAsyncState<T> copyWithData(T newData) {
    return BaseAsyncState<T>(isLoading: false, data: newData, failure: null);
  }

  /// Create error state
  BaseAsyncState<T> copyWithFailure(Failure newFailure) {
    return BaseAsyncState<T>(isLoading: false, data: data, failure: newFailure);
  }

  /// Check if has data
  bool get hasData => data != null;

  /// Check if has error
  bool get hasError => failure != null;

  /// Check if is initial state
  bool get isInitial => !isLoading && !hasData && !hasError;
}

/// Base notifier for async operations
/// Provides common patterns for handling Result<T> responses
abstract class BaseAsyncNotifier<T> extends StateNotifier<BaseAsyncState<T>> {
  BaseAsyncNotifier() : super(const BaseAsyncState());

  /// Execute operation with proper state management
  Future<void> executeOperation(Future<Result<T>> Function() operation) async {
    state = state.copyWithLoading();

    final result = await operation();

    result.when(
      success: (data) => state = state.copyWithData(data),
      failure: (failure) => state = state.copyWithFailure(failure),
    );
  }

  /// Execute operation and return result without state change
  Future<Result<T>> executeWithoutState(
    Future<Result<T>> Function() operation,
  ) async {
    return await operation();
  }
}

/// Stream provider base for real-time data
/// Following CLAUDE.md real-time requirements (<200ms latency)
abstract class BaseStreamProvider<T> {
  /// Create stream provider with error handling
  static StreamProvider<Result<T>> create<T>(
    Stream<Result<T>> Function(Ref) create,
  ) {
    return StreamProvider<Result<T>>((ref) {
      return create(ref).handleError((error, stackTrace) {
        // Convert stream errors to Result.failure
        return Result<T>.failure(
          Failure.unknownFailure(message: error.toString()),
        );
      });
    });
  }
}
