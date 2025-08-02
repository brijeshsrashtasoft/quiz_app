import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_failure.freezed.dart';

/// Notification-specific failures following Clean Architecture patterns
@freezed
class NotificationFailure with _$NotificationFailure {
  const factory NotificationFailure.fetchFailed({
    required String message,
    String? code,
  }) = _FetchFailedNotificationFailure;

  const factory NotificationFailure.markAsReadFailed({
    required String message,
    required String notificationId,
    String? code,
  }) = _MarkAsReadFailedNotificationFailure;

  const factory NotificationFailure.deleteFailed({
    required String message,
    required String notificationId,
    String? code,
  }) = _DeleteFailedNotificationFailure;

  const factory NotificationFailure.networkError({
    required String message,
    String? code,
  }) = _NetworkErrorNotificationFailure;

  const factory NotificationFailure.permissionDenied({
    required String message,
    String? code,
  }) = _PermissionDeniedNotificationFailure;

  const factory NotificationFailure.invalidNotificationId({
    required String message,
    required String notificationId,
    String? code,
  }) = _InvalidNotificationIdFailure;

  const factory NotificationFailure.serverError({
    required String message,
    String? code,
  }) = _ServerErrorNotificationFailure;

  const factory NotificationFailure.unknown({
    required String message,
    String? code,
  }) = _UnknownNotificationFailure;
}

/// Extension for user-friendly error messages
extension NotificationFailureX on NotificationFailure {
  String get userMessage {
    return when(
      fetchFailed: (message, _) =>
          'Failed to load notifications. Please try again.',
      markAsReadFailed: (message, notificationId, _) =>
          'Could not mark notification as read.',
      deleteFailed: (message, notificationId, _) =>
          'Could not delete notification.',
      networkError: (message, _) =>
          'No internet connection. Please check your network.',
      permissionDenied: (message, _) =>
          'Permission denied. Please check your settings.',
      invalidNotificationId: (message, notificationId, _) =>
          'Invalid notification. Please refresh.',
      serverError: (message, _) =>
          'Server error occurred. Please try again later.',
      unknown: (message, _) => 'Something went wrong. Please try again.',
    );
  }

  String get technicalMessage {
    return when(
      fetchFailed: (message, code) =>
          'Fetch notifications failed: $message${code != null ? ' (Code: $code)' : ''}',
      markAsReadFailed: (message, notificationId, code) =>
          'Mark as read failed for $notificationId: $message${code != null ? ' (Code: $code)' : ''}',
      deleteFailed: (message, notificationId, code) =>
          'Delete failed for $notificationId: $message${code != null ? ' (Code: $code)' : ''}',
      networkError: (message, code) =>
          'Network error: $message${code != null ? ' (Code: $code)' : ''}',
      permissionDenied: (message, code) =>
          'Permission denied: $message${code != null ? ' (Code: $code)' : ''}',
      invalidNotificationId: (message, notificationId, code) =>
          'Invalid notification ID $notificationId: $message${code != null ? ' (Code: $code)' : ''}',
      serverError: (message, code) =>
          'Server error: $message${code != null ? ' (Code: $code)' : ''}',
      unknown: (message, code) =>
          'Unknown error: $message${code != null ? ' (Code: $code)' : ''}',
    );
  }

  String get errorCode {
    return when(
      fetchFailed: (_, code) => code ?? 'NOTIFICATION_FETCH_FAILED',
      markAsReadFailed: (_, __, code) =>
          code ?? 'NOTIFICATION_MARK_READ_FAILED',
      deleteFailed: (_, __, code) => code ?? 'NOTIFICATION_DELETE_FAILED',
      networkError: (_, code) => code ?? 'NOTIFICATION_NETWORK_ERROR',
      permissionDenied: (_, code) => code ?? 'NOTIFICATION_PERMISSION_DENIED',
      invalidNotificationId: (_, __, code) => code ?? 'INVALID_NOTIFICATION_ID',
      serverError: (_, code) => code ?? 'NOTIFICATION_SERVER_ERROR',
      unknown: (_, code) => code ?? 'NOTIFICATION_UNKNOWN_ERROR',
    );
  }
}
