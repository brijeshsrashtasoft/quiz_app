import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/session_firestore_datasource.dart';
import 'package:uuid/uuid.dart';

/// Implementation of IDeviceRepository using Firestore
/// Following CLAUDE.md Clean Architecture and free tier patterns
class DeviceRepositoryImpl implements IDeviceRepository {
  final SessionFirestoreDataSource _dataSource;
  final Uuid _uuid;

  DeviceRepositoryImpl({required SessionFirestoreDataSource dataSource, Uuid? uuid})
    : _dataSource = dataSource,
      _uuid = uuid ?? const Uuid();

  @override
  Future<Result<DeviceEntity>> registerDevice({
    required String userId,
    required String deviceName,
    required String platform,
    required String osVersion,
    String? deviceModel,
    String? fingerprint,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userDevice = await _dataSource.registerDevice(
        userId: userId,
        deviceId: fingerprint ?? _generateDeviceId(),
        deviceName: deviceName,
        deviceType: deviceModel ?? 'unknown',
        platform: platform,
        fcmToken: null,
      );
      
      // Convert UserDevice to DeviceEntity
      final deviceEntity = DeviceEntity(
        id: userDevice.deviceId,
        userId: userDevice.userId,
        deviceName: userDevice.deviceName,
        platform: userDevice.platform,
        osVersion: osVersion,
        trustLevel: userDevice.trustLevel == 'trusted' 
            ? DeviceTrustLevel.trusted 
            : DeviceTrustLevel.untrusted,
        registeredAt: userDevice.firstSeenAt,
        lastSeenAt: userDevice.lastSeenAt,
        deviceModel: deviceModel,
        fingerprint: fingerprint,
        isCurrentDevice: !userDevice.isRevoked,
        metadata: metadata,
      );
      
      return Result.success(deviceEntity);
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to register device', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to register device: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<DeviceEntity?>> getDeviceById(String deviceId) async {
    try {
      throw UnimplementedError(
        'getDeviceById requires userId for Firestore subcollection access. '
        'This is a design limitation that needs interface refactoring.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to get device by id', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to get device by id: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<List<DeviceEntity>>> getUserDevices(String userId) async {
    try {
      final userDevices = await _dataSource.getUserDevices(userId);
      
      // Convert UserDevice list to DeviceEntity list
      final deviceEntities = userDevices.map((userDevice) => DeviceEntity(
        id: userDevice.deviceId,
        userId: userDevice.userId,
        deviceName: userDevice.deviceName,
        platform: userDevice.platform,
        osVersion: '1.0.0', // UserDevice doesn't have osVersion
        trustLevel: userDevice.trustLevel == 'trusted' 
            ? DeviceTrustLevel.trusted 
            : DeviceTrustLevel.untrusted,
        registeredAt: userDevice.firstSeenAt,
        lastSeenAt: userDevice.lastSeenAt,
        deviceModel: userDevice.deviceType,
        fingerprint: userDevice.deviceId,
        isCurrentDevice: !userDevice.isRevoked,
        metadata: userDevice.deviceFingerprint,
      )).toList();
      
      return Result.success(deviceEntities);
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to get user devices', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to get user devices: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<List<DeviceEntity>>> getTrustedDevices(String userId) async {
    try {
      throw UnimplementedError(
        'getTrustedDevices needs proper entity mapping. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to get trusted devices', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to get trusted devices: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<DeviceEntity>> updateTrustLevel({
    required String deviceId,
    required DeviceTrustLevel trustLevel,
  }) async {
    try {
      throw UnimplementedError(
        'updateTrustLevel requires userId and proper entity mapping. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to update trust level', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to update trust level: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<DeviceEntity>> trustDevice(String deviceId) async {
    try {
      throw UnimplementedError(
        'trustDevice requires userId and proper entity mapping. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to trust device', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to trust device: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<DeviceEntity>> blockDevice(String deviceId) async {
    try {
      throw UnimplementedError(
        'blockDevice requires userId and proper entity mapping. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to block device', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to block device: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void>> removeDevice(String deviceId) async {
    try {
      throw UnimplementedError(
        'removeDevice requires userId for Firestore subcollection access. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to remove device', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to remove device: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void>> updateLastSeen(String deviceId) async {
    try {
      throw UnimplementedError(
        'updateLastSeen requires userId for Firestore subcollection access. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to update last seen', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to update last seen: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<DeviceEntity?>> getCurrentDevice(String userId) async {
    try {
      throw UnimplementedError(
        'getCurrentDevice needs proper entity mapping. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to get current device', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to get current device: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void>> setCurrentDevice({
    required String userId,
    required String deviceId,
  }) async {
    try {
      throw UnimplementedError(
        'setCurrentDevice needs proper implementation. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to set current device', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to set current device: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> isDeviceRegistered({
    required String userId,
    required String fingerprint,
  }) async {
    try {
      throw UnimplementedError(
        'isDeviceRegistered needs proper implementation. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error(
        'DeviceRepository: Failed to check device registration',
        e,
      );
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to check device registration: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<DeviceEntity?>> getDeviceByFingerprint({
    required String userId,
    required String fingerprint,
  }) async {
    try {
      throw UnimplementedError(
        'getDeviceByFingerprint needs proper implementation. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error(
        'DeviceRepository: Failed to get device by fingerprint',
        e,
      );
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to get device by fingerprint: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<List<DeviceEntity>>> getInactiveDevices(String userId) async {
    try {
      throw UnimplementedError(
        'getInactiveDevices needs proper entity mapping. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to get inactive devices', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to get inactive devices: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<int>> cleanupInactiveDevices(String userId) async {
    try {
      throw UnimplementedError(
        'cleanupInactiveDevices needs proper implementation. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error(
        'DeviceRepository: Failed to cleanup inactive devices',
        e,
      );
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to cleanup inactive devices: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<int>> getDeviceCount(String userId) async {
    try {
      throw UnimplementedError(
        'getDeviceCount needs proper implementation. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to get device count', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to get device count: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> hasTrustedDevices(String userId) async {
    try {
      throw UnimplementedError(
        'hasTrustedDevices needs proper implementation. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to check trusted devices', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to check trusted devices: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<Result<List<DeviceEntity>>> watchUserDevices(String userId) {
    try {
      throw UnimplementedError(
        'watchUserDevices needs proper stream implementation. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to setup device stream', e);
      return Stream.value(
        Result.failure(
          Failure.deviceFailure(
            message: 'Failed to watch devices: ${e.toString()}',
          ),
        ),
      );
    }
  }

  @override
  Future<Result<DeviceEntity>> updateDeviceMetadata({
    required String deviceId,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      throw UnimplementedError(
        'updateDeviceMetadata requires userId and proper entity mapping. '
        'This interface mismatch needs to be resolved.',
      );
    } catch (e) {
      AppLogger.error('DeviceRepository: Failed to update device metadata', e);
      return Result.failure(
        Failure.deviceFailure(
          message: 'Failed to update device metadata: ${e.toString()}',
        ),
      );
    }
  }

  /// Generate a unique device ID
  String _generateDeviceId() {
    return _uuid.v4();
  }
}
