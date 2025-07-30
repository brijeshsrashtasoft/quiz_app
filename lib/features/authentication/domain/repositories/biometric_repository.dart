import '../../../../core/utils/result.dart';
import '../entities/biometric_capability_entity.dart';

/// Biometric repository contract for biometric authentication
/// Following CLAUDE.md Clean Architecture patterns
abstract class IBiometricRepository {
  /// Check if biometric authentication is available on device
  Future<Result<BiometricCapabilityEntity>> checkBiometricCapability();

  /// Authenticate user using biometric
  Future<Result<bool>> authenticateWithBiometric({
    String? localizedFallbackTitle,
    String? cancelButton,
  });

  /// Enable biometric authentication for user
  Future<Result<void>> enableBiometric(String userId);

  /// Disable biometric authentication for user
  Future<Result<bool>> disableBiometric(String userId);

  /// Check if biometric is enabled for user
  Future<Result<bool>> isBiometricEnabled(String userId);

  /// Get supported biometric types
  Future<Result<List<BiometricType>>> getSupportedBiometricTypes();

  /// Check if device has enrolled biometrics
  Future<Result<bool>> hasEnrolledBiometrics();

  /// Get biometric authentication status
  Future<Result<BiometricStatus>> getBiometricStatus();

  /// Authenticate with specific biometric type
  Future<Result<bool>> authenticateWithType({
    required BiometricType biometricType,
    String? reason,
  });

  /// Check if strong biometric authentication is available
  Future<Result<bool>> isStrongBiometricAvailable();

  /// Check if weak biometric authentication is available
  Future<Result<bool>> isWeakBiometricAvailable();

  /// Get last biometric authentication timestamp
  Future<Result<DateTime?>> getLastBiometricAuth(String userId);

  /// Update last biometric authentication timestamp
  Future<Result<void>> updateLastBiometricAuth(String userId);

  /// Get biometric failure count
  Future<Result<int>> getBiometricFailureCount(String userId);

  /// Reset biometric failure count
  Future<Result<void>> resetBiometricFailureCount(String userId);

  /// Increment biometric failure count
  Future<Result<void>> incrementBiometricFailureCount(String userId);

  /// Check if biometric is locked due to failures
  Future<Result<bool>> isBiometricLocked(String userId);

  /// Get biometric lock duration remaining
  Future<Result<Duration?>> getBiometricLockDuration(String userId);

  /// Unlock biometric after cooldown period
  Future<Result<void>> unlockBiometric(String userId);

  /// Get biometric preferences for user
  Future<Result<BiometricPreferences>> getBiometricPreferences(String userId);

  /// Update biometric preferences
  Future<Result<void>> updateBiometricPreferences({
    required String userId,
    required BiometricPreferences preferences,
  });

  /// Check if biometric capabilities have changed
  Future<Result<bool>> haveBiometricCapabilitiesChanged();

  /// Refresh biometric capability cache
  Future<Result<BiometricCapabilityEntity>> refreshCapabilityCache();
}

/// Biometric preferences for user customization
class BiometricPreferences {
  final bool enabled;
  final bool fallbackToPin;
  final List<BiometricType> preferredTypes;
  final bool requireConfirmation;
  final int maxFailureAttempts;
  final Duration lockoutDuration;

  BiometricPreferences({
    required this.enabled,
    this.fallbackToPin = true,
    this.preferredTypes = const [],
    this.requireConfirmation = true,
    this.maxFailureAttempts = 5,
    this.lockoutDuration = const Duration(minutes: 30),
  });
}
