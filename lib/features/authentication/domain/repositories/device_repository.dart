import '../../../../core/utils/result.dart';
import '../entities/device_entity.dart';

/// Device repository contract for device management
/// Following CLAUDE.md Clean Architecture patterns
abstract class IDeviceRepository {
  /// Register a new device for user
  Future<Result<DeviceEntity>> registerDevice({
    required String userId,
    required String deviceName,
    required String platform,
    required String osVersion,
    String? deviceModel,
    String? fingerprint,
    Map<String, dynamic>? metadata,
  });

  /// Get device by ID
  Future<Result<DeviceEntity?>> getDeviceById(String deviceId);

  /// Get all devices for user
  Future<Result<List<DeviceEntity>>> getUserDevices(String userId);

  /// Get trusted devices for user
  Future<Result<List<DeviceEntity>>> getTrustedDevices(String userId);

  /// Update device trust level
  Future<Result<DeviceEntity>> updateTrustLevel({
    required String deviceId,
    required DeviceTrustLevel trustLevel,
  });

  /// Trust a device
  Future<Result<DeviceEntity>> trustDevice(String deviceId);

  /// Block a device
  Future<Result<DeviceEntity>> blockDevice(String deviceId);

  /// Remove/unregister a device
  Future<Result<void>> removeDevice(String deviceId);

  /// Update device last seen timestamp
  Future<Result<void>> updateLastSeen(String deviceId);

  /// Get current device for user
  Future<Result<DeviceEntity?>> getCurrentDevice(String userId);

  /// Set device as current
  Future<Result<void>> setCurrentDevice({
    required String userId,
    required String deviceId,
  });

  /// Check if device exists and is registered
  Future<Result<bool>> isDeviceRegistered({
    required String userId,
    required String fingerprint,
  });

  /// Get device by fingerprint
  Future<Result<DeviceEntity?>> getDeviceByFingerprint({
    required String userId,
    required String fingerprint,
  });

  /// Get inactive devices (not seen for 30+ days)
  Future<Result<List<DeviceEntity>>> getInactiveDevices(String userId);

  /// Cleanup inactive devices
  Future<Result<int>> cleanupInactiveDevices(String userId);

  /// Get device count for user
  Future<Result<int>> getDeviceCount(String userId);

  /// Check if user has trusted devices
  Future<Result<bool>> hasTrustedDevices(String userId);

  /// Watch user devices (real-time)
  Stream<Result<List<DeviceEntity>>> watchUserDevices(String userId);

  /// Update device metadata
  Future<Result<DeviceEntity>> updateDeviceMetadata({
    required String deviceId,
    required Map<String, dynamic> metadata,
  });
}
