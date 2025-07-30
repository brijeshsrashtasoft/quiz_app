import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_entity.freezed.dart';

/// Device entity for device management and trust levels
/// Following CLAUDE.md Clean Architecture patterns
@freezed
class DeviceEntity with _$DeviceEntity {
  const factory DeviceEntity({
    required String id,
    required String userId,
    required String deviceName,
    required String platform,
    required String osVersion,
    required DeviceTrustLevel trustLevel,
    required DateTime registeredAt,
    required DateTime lastSeenAt,
    String? deviceModel,
    String? fingerprint,
    bool? isCurrentDevice,
    Map<String, dynamic>? metadata,
  }) = _DeviceEntity;
}

/// Device trust level enumeration
enum DeviceTrustLevel { untrusted, pending, trusted, blocked }

/// Device entity extensions for business logic
extension DeviceEntityX on DeviceEntity {
  /// Check if device is trusted
  bool get isTrusted {
    return trustLevel == DeviceTrustLevel.trusted;
  }

  /// Check if device is blocked
  bool get isBlocked {
    return trustLevel == DeviceTrustLevel.blocked;
  }

  /// Check if device trust is pending
  bool get isPendingTrust {
    return trustLevel == DeviceTrustLevel.pending;
  }

  /// Check if device is recently registered (within 7 days)
  bool get isNewDevice {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return registeredAt.isAfter(sevenDaysAgo);
  }

  /// Check if device has been inactive for long time (30+ days)
  bool get isInactive {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return lastSeenAt.isBefore(thirtyDaysAgo);
  }

  /// Get device age in days
  int get deviceAgeInDays {
    return DateTime.now().difference(registeredAt).inDays;
  }

  /// Get days since last seen
  int get daysSinceLastSeen {
    return DateTime.now().difference(lastSeenAt).inDays;
  }

  /// Check if device requires verification
  bool get requiresVerification {
    return !isTrusted || isNewDevice;
  }

  /// Get device display name
  String get displayName {
    return deviceModel != null ? '$deviceName ($deviceModel)' : deviceName;
  }

  /// Check if device can perform sensitive operations
  bool get canPerformSensitiveOperations {
    return isTrusted && !isInactive && !isBlocked;
  }
}
