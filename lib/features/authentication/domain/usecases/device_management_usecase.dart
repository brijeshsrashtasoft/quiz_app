import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';
import '../repositories/security_repository.dart';
import '../entities/security_event_entity.dart';

/// Device management use case for managing user devices
/// Following CLAUDE.md Clean Architecture patterns
class DeviceManagementUseCase {
  final IDeviceRepository _deviceRepository;
  final ISecurityRepository _securityRepository;

  DeviceManagementUseCase(this._deviceRepository, this._securityRepository);

  /// Register a new device for user
  Future<Result<DeviceEntity>> registerDevice(
    RegisterDeviceParams params,
  ) async {
    // Check if device already exists
    final existingDeviceResult = await _deviceRepository.getDeviceByFingerprint(
      userId: params.userId,
      fingerprint: params.fingerprint,
    );

    if (existingDeviceResult.isSuccess && existingDeviceResult.data != null) {
      // Device already registered, update last seen
      await _deviceRepository.updateLastSeen(existingDeviceResult.data!.id);
      return Result.success(existingDeviceResult.data!);
    }

    // Register new device
    final registerResult = await _deviceRepository.registerDevice(
      userId: params.userId,
      deviceName: params.deviceName,
      platform: params.platform,
      osVersion: params.osVersion,
      deviceModel: params.deviceModel,
      fingerprint: params.fingerprint,
      metadata: params.metadata,
    );

    if (registerResult.isSuccess) {
      // Log security event
      await _securityRepository.logEvent(
        userId: params.userId,
        eventType: SecurityEventType.deviceRegistration,
        severity: SecurityEventSeverity.low,
        description: 'New device registered: ${params.deviceName}',
        deviceId: registerResult.data!.id,
        metadata: {
          'platform': params.platform,
          'deviceModel': params.deviceModel,
        },
      );
    }

    return registerResult;
  }

  /// Trust a device
  Future<Result<DeviceEntity>> trustDevice(TrustDeviceParams params) async {
    final result = await _deviceRepository.trustDevice(params.deviceId);

    if (result.isSuccess) {
      // Log security event
      await _securityRepository.logEvent(
        userId: result.data!.userId,
        eventType: SecurityEventType.deviceTrustChange,
        severity: SecurityEventSeverity.low,
        description: 'Device trusted: ${result.data!.displayName}',
        deviceId: params.deviceId,
      );
    }

    return result;
  }

  /// Block a device
  Future<Result<DeviceEntity>> blockDevice(BlockDeviceParams params) async {
    final result = await _deviceRepository.blockDevice(params.deviceId);

    if (result.isSuccess) {
      // Log security event
      await _securityRepository.logEvent(
        userId: result.data!.userId,
        eventType: SecurityEventType.deviceTrustChange,
        severity: SecurityEventSeverity.medium,
        description:
            params.reason ?? 'Device blocked: ${result.data!.displayName}',
        deviceId: params.deviceId,
      );
    }

    return result;
  }

  /// Remove a device
  Future<Result<void>> removeDevice(RemoveDeviceParams params) async {
    // Get device info before removal
    final deviceResult = await _deviceRepository.getDeviceById(params.deviceId);

    final result = await _deviceRepository.removeDevice(params.deviceId);

    if (result.isSuccess && deviceResult.isSuccess) {
      final device = deviceResult.data!;

      // Log security event
      await _securityRepository.logEvent(
        userId: device.userId,
        eventType: SecurityEventType.deviceTrustChange,
        severity: SecurityEventSeverity.low,
        description: 'Device removed: ${device.displayName}',
        deviceId: params.deviceId,
      );
    }

    return result;
  }

  /// Get all devices for user
  Future<Result<List<DeviceEntity>>> getUserDevices(
    GetUserDevicesParams params,
  ) async {
    return await _deviceRepository.getUserDevices(params.userId);
  }

  /// Get trusted devices for user
  Future<Result<List<DeviceEntity>>> getTrustedDevices(
    GetTrustedDevicesParams params,
  ) async {
    return await _deviceRepository.getTrustedDevices(params.userId);
  }

  /// Get current device for user
  Future<Result<DeviceEntity?>> getCurrentDevice(
    GetCurrentDeviceParams params,
  ) async {
    return await _deviceRepository.getCurrentDevice(params.userId);
  }

  /// Set device as current
  Future<Result<void>> setCurrentDevice(SetCurrentDeviceParams params) async {
    return await _deviceRepository.setCurrentDevice(
      userId: params.userId,
      deviceId: params.deviceId,
    );
  }

  /// Cleanup inactive devices
  Future<Result<int>> cleanupInactiveDevices(
    CleanupInactiveDevicesParams params,
  ) async {
    return await _deviceRepository.cleanupInactiveDevices(params.userId);
  }

  /// Get device security summary
  Future<Result<DeviceSecuritySummary>> getDeviceSecuritySummary(
    GetDeviceSecuritySummaryParams params,
  ) async {
    final devicesResult = await _deviceRepository.getUserDevices(params.userId);
    if (devicesResult.isFailure)
      return Result.failure(devicesResult.failureOrNull!);

    final devices = devicesResult.data!;
    final trustedDevices = devices.where((d) => d.isTrusted).toList();
    final blockedDevices = devices.where((d) => d.isBlocked).toList();
    final inactiveDevices = devices.where((d) => d.isInactive).toList();
    final newDevices = devices.where((d) => d.isNewDevice).toList();

    return Result.success(
      DeviceSecuritySummary(
        totalDevices: devices.length,
        trustedDevices: trustedDevices.length,
        blockedDevices: blockedDevices.length,
        inactiveDevices: inactiveDevices.length,
        newDevices: newDevices.length,
        devices: devices,
      ),
    );
  }

  /// Watch user devices (real-time)
  Stream<Result<List<DeviceEntity>>> watchUserDevices(
    WatchUserDevicesParams params,
  ) {
    return _deviceRepository.watchUserDevices(params.userId);
  }
}

/// Parameters for registering a device
class RegisterDeviceParams {
  final String userId;
  final String deviceName;
  final String platform;
  final String osVersion;
  final String fingerprint;
  final String? deviceModel;
  final Map<String, dynamic>? metadata;

  RegisterDeviceParams({
    required this.userId,
    required this.deviceName,
    required this.platform,
    required this.osVersion,
    required this.fingerprint,
    this.deviceModel,
    this.metadata,
  });
}

/// Parameters for trusting a device
class TrustDeviceParams {
  final String deviceId;

  TrustDeviceParams({required this.deviceId});
}

/// Parameters for blocking a device
class BlockDeviceParams {
  final String deviceId;
  final String? reason;

  BlockDeviceParams({required this.deviceId, this.reason});
}

/// Parameters for removing a device
class RemoveDeviceParams {
  final String deviceId;

  RemoveDeviceParams({required this.deviceId});
}

/// Parameters for getting user devices
class GetUserDevicesParams {
  final String userId;

  GetUserDevicesParams({required this.userId});
}

/// Parameters for getting trusted devices
class GetTrustedDevicesParams {
  final String userId;

  GetTrustedDevicesParams({required this.userId});
}

/// Parameters for getting current device
class GetCurrentDeviceParams {
  final String userId;

  GetCurrentDeviceParams({required this.userId});
}

/// Parameters for setting current device
class SetCurrentDeviceParams {
  final String userId;
  final String deviceId;

  SetCurrentDeviceParams({required this.userId, required this.deviceId});
}

/// Parameters for cleaning up inactive devices
class CleanupInactiveDevicesParams {
  final String userId;

  CleanupInactiveDevicesParams({required this.userId});
}

/// Parameters for getting device security summary
class GetDeviceSecuritySummaryParams {
  final String userId;

  GetDeviceSecuritySummaryParams({required this.userId});
}

/// Parameters for watching user devices
class WatchUserDevicesParams {
  final String userId;

  WatchUserDevicesParams({required this.userId});
}

/// Device security summary
class DeviceSecuritySummary {
  final int totalDevices;
  final int trustedDevices;
  final int blockedDevices;
  final int inactiveDevices;
  final int newDevices;
  final List<DeviceEntity> devices;

  DeviceSecuritySummary({
    required this.totalDevices,
    required this.trustedDevices,
    required this.blockedDevices,
    required this.inactiveDevices,
    required this.newDevices,
    required this.devices,
  });
}
