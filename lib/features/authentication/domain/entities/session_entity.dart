import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_entity.freezed.dart';

/// Session entity representing user session data for security management
/// Following Clean Architecture domain layer patterns
@freezed
class SessionEntity with _$SessionEntity {
  const factory SessionEntity({
    required String id,
    required String userId,
    required String deviceId,
    required String deviceName,
    required String deviceType,
    required String ipAddress,
    required DateTime createdAt,
    required DateTime lastActivityAt,
    required DateTime expiresAt,
    required bool isActive,
    required bool isTrusted,
    required String location,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) = _SessionEntity;
}

/// Extension methods for SessionEntity
extension SessionEntityX on SessionEntity {
  /// Check if session is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if session is near expiration (within 30 minutes)
  bool get isNearExpiration {
    final thirtyMinutesFromNow = DateTime.now().add(
      const Duration(minutes: 30),
    );
    return thirtyMinutesFromNow.isAfter(expiresAt);
  }

  /// Get session duration in minutes
  int get durationInMinutes {
    return lastActivityAt.difference(createdAt).inMinutes;
  }

  /// Check if session needs refresh
  bool get needsRefresh => isNearExpiration && isActive;

  /// Get session status
  String get status {
    if (!isActive) return 'inactive';
    if (isExpired) return 'expired';
    if (isNearExpiration) return 'expiring';
    return 'active';
  }
}
