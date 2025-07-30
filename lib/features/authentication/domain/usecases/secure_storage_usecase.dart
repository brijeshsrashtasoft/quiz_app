import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';

/// Secure storage use case for handling sensitive data storage
/// Following CLAUDE.md Clean Architecture patterns
abstract class ISecureStorageRepository {
  /// Store sensitive data securely
  Future<Result<void>> storeSecurely(String key, String value);

  /// Retrieve sensitive data securely
  Future<Result<String?>> retrieveSecurely(String key);

  /// Delete sensitive data
  Future<Result<void>> deleteSecurely(String key);

  /// Check if key exists
  Future<Result<bool>> hasKey(String key);

  /// Clear all stored data
  Future<Result<void>> clearAll();

  /// Store with encryption and expiration
  Future<Result<void>> storeWithExpiration(
    String key,
    String value,
    Duration expiration,
  );

  /// Get all keys
  Future<Result<List<String>>> getAllKeys();

  /// Store object as JSON
  Future<Result<void>> storeObject(String key, Map<String, dynamic> object);

  /// Retrieve object from JSON
  Future<Result<Map<String, dynamic>?>> retrieveObject(String key);
}

/// Secure storage use case implementation
class SecureStorageUseCase {
  final ISecureStorageRepository _secureStorageRepository;

  SecureStorageUseCase(this._secureStorageRepository);

  /// Store user session token securely
  Future<Result<void>> storeSessionToken(StoreSessionTokenParams params) async {
    final key = 'session_token_${params.userId}';
    return await _secureStorageRepository.storeWithExpiration(
      key,
      params.token,
      params.expiration,
    );
  }

  /// Retrieve user session token
  Future<Result<String?>> getSessionToken(GetSessionTokenParams params) async {
    final key = 'session_token_${params.userId}';
    return await _secureStorageRepository.retrieveSecurely(key);
  }

  /// Clear user session token
  Future<Result<void>> clearSessionToken(ClearSessionTokenParams params) async {
    final key = 'session_token_${params.userId}';
    return await _secureStorageRepository.deleteSecurely(key);
  }

  /// Store biometric preferences securely
  Future<Result<void>> storeBiometricPreferences(
    StoreBiometricPreferencesParams params,
  ) async {
    final key = 'biometric_prefs_${params.userId}';
    final prefsMap = {
      'enabled': params.enabled,
      'fallbackToPin': params.fallbackToPin,
      'requireConfirmation': params.requireConfirmation,
      'maxFailureAttempts': params.maxFailureAttempts,
      'lockoutDurationMinutes': params.lockoutDuration.inMinutes,
    };
    return await _secureStorageRepository.storeObject(key, prefsMap);
  }

  /// Retrieve biometric preferences
  Future<Result<BiometricStoragePreferences?>> getBiometricPreferences(
    GetBiometricPreferencesParams params,
  ) async {
    final key = 'biometric_prefs_${params.userId}';
    final result = await _secureStorageRepository.retrieveObject(key);

    if (result.isFailure) return Result.failure(result.failureOrNull!);
    if (result.data == null) return Result.success(null);

    final prefs = result.data!;
    return Result.success(
      BiometricStoragePreferences(
        enabled: prefs['enabled'] ?? false,
        fallbackToPin: prefs['fallbackToPin'] ?? true,
        requireConfirmation: prefs['requireConfirmation'] ?? true,
        maxFailureAttempts: prefs['maxFailureAttempts'] ?? 5,
        lockoutDuration: Duration(
          minutes: prefs['lockoutDurationMinutes'] ?? 30,
        ),
      ),
    );
  }

  /// Store device fingerprint
  Future<Result<void>> storeDeviceFingerprint(
    StoreDeviceFingerprintParams params,
  ) async {
    final key = 'device_fingerprint_${params.userId}';
    return await _secureStorageRepository.storeSecurely(
      key,
      params.fingerprint,
    );
  }

  /// Retrieve device fingerprint
  Future<Result<String?>> getDeviceFingerprint(
    GetDeviceFingerprintParams params,
  ) async {
    final key = 'device_fingerprint_${params.userId}';
    return await _secureStorageRepository.retrieveSecurely(key);
  }

  /// Store security PIN/password hash
  Future<Result<void>> storeSecurityPin(StoreSecurityPinParams params) async {
    final key = 'security_pin_${params.userId}';
    return await _secureStorageRepository.storeSecurely(key, params.hashedPin);
  }

  /// Verify security PIN
  Future<Result<bool>> verifySecurityPin(VerifySecurityPinParams params) async {
    final key = 'security_pin_${params.userId}';
    final storedHashResult = await _secureStorageRepository.retrieveSecurely(
      key,
    );

    if (storedHashResult.isFailure)
      return Result.failure(storedHashResult.failureOrNull!);
    if (storedHashResult.data == null) return Result.success(false);

    return Result.success(storedHashResult.data == params.hashedPin);
  }

  /// Store encrypted backup data
  Future<Result<void>> storeBackupData(StoreBackupDataParams params) async {
    final key = 'backup_data_${params.userId}';
    final backupMap = {
      'data': params.encryptedData,
      'timestamp': DateTime.now().toIso8601String(),
      'version': params.version,
    };
    return await _secureStorageRepository.storeObject(key, backupMap);
  }

  /// Retrieve backup data
  Future<Result<BackupData?>> getBackupData(GetBackupDataParams params) async {
    final key = 'backup_data_${params.userId}';
    final result = await _secureStorageRepository.retrieveObject(key);

    if (result.isFailure) return Result.failure(result.failureOrNull!);
    if (result.data == null) return Result.success(null);

    final backup = result.data!;
    return Result.success(
      BackupData(
        encryptedData: backup['data'] ?? '',
        timestamp:
            DateTime.tryParse(backup['timestamp'] ?? '') ?? DateTime.now(),
        version: backup['version'] ?? 1,
      ),
    );
  }

  /// Clear all user data
  Future<Result<void>> clearAllUserData(ClearAllUserDataParams params) async {
    final keysResult = await _secureStorageRepository.getAllKeys();
    if (keysResult.isFailure) return Result.failure(keysResult.failureOrNull!);

    final userKeys = keysResult.data!.where(
      (key) => key.contains(params.userId),
    );

    for (final key in userKeys) {
      await _secureStorageRepository.deleteSecurely(key);
    }

    return Result.success(null);
  }

  /// Get storage summary for user
  Future<Result<StorageSummary>> getStorageSummary(
    GetStorageSummaryParams params,
  ) async {
    final keysResult = await _secureStorageRepository.getAllKeys();
    if (keysResult.isFailure) return Result.failure(keysResult.failureOrNull!);

    final userKeys = keysResult.data!
        .where((key) => key.contains(params.userId))
        .toList();

    final hasSessionToken = userKeys.any(
      (key) => key.startsWith('session_token_'),
    );
    final hasBiometricPrefs = userKeys.any(
      (key) => key.startsWith('biometric_prefs_'),
    );
    final hasDeviceFingerprint = userKeys.any(
      (key) => key.startsWith('device_fingerprint_'),
    );
    final hasSecurityPin = userKeys.any(
      (key) => key.startsWith('security_pin_'),
    );
    final hasBackupData = userKeys.any((key) => key.startsWith('backup_data_'));

    return Result.success(
      StorageSummary(
        totalStoredItems: userKeys.length,
        hasSessionToken: hasSessionToken,
        hasBiometricPreferences: hasBiometricPrefs,
        hasDeviceFingerprint: hasDeviceFingerprint,
        hasSecurityPin: hasSecurityPin,
        hasBackupData: hasBackupData,
        storedKeys: userKeys,
      ),
    );
  }
}

/// Parameters for storing session token
class StoreSessionTokenParams {
  final String userId;
  final String token;
  final Duration expiration;

  StoreSessionTokenParams({
    required this.userId,
    required this.token,
    required this.expiration,
  });
}

/// Parameters for getting session token
class GetSessionTokenParams {
  final String userId;

  GetSessionTokenParams({required this.userId});
}

/// Parameters for clearing session token
class ClearSessionTokenParams {
  final String userId;

  ClearSessionTokenParams({required this.userId});
}

/// Parameters for storing biometric preferences
class StoreBiometricPreferencesParams {
  final String userId;
  final bool enabled;
  final bool fallbackToPin;
  final bool requireConfirmation;
  final int maxFailureAttempts;
  final Duration lockoutDuration;

  StoreBiometricPreferencesParams({
    required this.userId,
    required this.enabled,
    this.fallbackToPin = true,
    this.requireConfirmation = true,
    this.maxFailureAttempts = 5,
    this.lockoutDuration = const Duration(minutes: 30),
  });
}

/// Parameters for getting biometric preferences
class GetBiometricPreferencesParams {
  final String userId;

  GetBiometricPreferencesParams({required this.userId});
}

/// Parameters for storing device fingerprint
class StoreDeviceFingerprintParams {
  final String userId;
  final String fingerprint;

  StoreDeviceFingerprintParams({
    required this.userId,
    required this.fingerprint,
  });
}

/// Parameters for getting device fingerprint
class GetDeviceFingerprintParams {
  final String userId;

  GetDeviceFingerprintParams({required this.userId});
}

/// Parameters for storing security PIN
class StoreSecurityPinParams {
  final String userId;
  final String hashedPin;

  StoreSecurityPinParams({required this.userId, required this.hashedPin});
}

/// Parameters for verifying security PIN
class VerifySecurityPinParams {
  final String userId;
  final String hashedPin;

  VerifySecurityPinParams({required this.userId, required this.hashedPin});
}

/// Parameters for storing backup data
class StoreBackupDataParams {
  final String userId;
  final String encryptedData;
  final int version;

  StoreBackupDataParams({
    required this.userId,
    required this.encryptedData,
    required this.version,
  });
}

/// Parameters for getting backup data
class GetBackupDataParams {
  final String userId;

  GetBackupDataParams({required this.userId});
}

/// Parameters for clearing all user data
class ClearAllUserDataParams {
  final String userId;

  ClearAllUserDataParams({required this.userId});
}

/// Parameters for getting storage summary
class GetStorageSummaryParams {
  final String userId;

  GetStorageSummaryParams({required this.userId});
}

/// Biometric storage preferences
class BiometricStoragePreferences {
  final bool enabled;
  final bool fallbackToPin;
  final bool requireConfirmation;
  final int maxFailureAttempts;
  final Duration lockoutDuration;

  BiometricStoragePreferences({
    required this.enabled,
    required this.fallbackToPin,
    required this.requireConfirmation,
    required this.maxFailureAttempts,
    required this.lockoutDuration,
  });
}

/// Backup data structure
class BackupData {
  final String encryptedData;
  final DateTime timestamp;
  final int version;

  BackupData({
    required this.encryptedData,
    required this.timestamp,
    required this.version,
  });
}

/// Storage summary
class StorageSummary {
  final int totalStoredItems;
  final bool hasSessionToken;
  final bool hasBiometricPreferences;
  final bool hasDeviceFingerprint;
  final bool hasSecurityPin;
  final bool hasBackupData;
  final List<String> storedKeys;

  StorageSummary({
    required this.totalStoredItems,
    required this.hasSessionToken,
    required this.hasBiometricPreferences,
    required this.hasDeviceFingerprint,
    required this.hasSecurityPin,
    required this.hasBackupData,
    required this.storedKeys,
  });
}
