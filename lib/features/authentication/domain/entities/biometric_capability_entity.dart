import 'package:freezed_annotation/freezed_annotation.dart';

part 'biometric_capability_entity.freezed.dart';

/// Biometric capability entity for biometric authentication features
/// Following CLAUDE.md Clean Architecture patterns
@freezed
class BiometricCapabilityEntity with _$BiometricCapabilityEntity {
  const factory BiometricCapabilityEntity({
    required bool isDeviceSupported,
    required bool isBiometricAvailable,
    required List<BiometricType> availableTypes,
    required BiometricStatus status,
    String? errorMessage,
    DateTime? lastCheckedAt,
    Map<String, dynamic>? deviceInfo,
  }) = _BiometricCapabilityEntity;
}

/// Biometric type enumeration
enum BiometricType { fingerprint, face, iris, voice, strong, weak }

/// Biometric status enumeration
enum BiometricStatus {
  available,
  notEnrolled,
  notAvailable,
  disabled,
  lockedOut,
  permanentlyLockedOut,
}

/// Biometric capability entity extensions for business logic
extension BiometricCapabilityEntityX on BiometricCapabilityEntity {
  /// Check if biometrics can be used
  bool get canUseBiometrics {
    return isDeviceSupported &&
        isBiometricAvailable &&
        status == BiometricStatus.available &&
        availableTypes.isNotEmpty;
  }

  /// Check if fingerprint is available
  bool get hasFingerprint {
    return availableTypes.contains(BiometricType.fingerprint);
  }

  /// Check if face recognition is available
  bool get hasFaceRecognition {
    return availableTypes.contains(BiometricType.face);
  }

  /// Check if iris recognition is available
  bool get hasIrisRecognition {
    return availableTypes.contains(BiometricType.iris);
  }

  /// Check if strong biometric authentication is available
  bool get hasStrongBiometric {
    return availableTypes.contains(BiometricType.strong);
  }

  /// Check if only weak biometric is available
  bool get hasOnlyWeakBiometric {
    return availableTypes.contains(BiometricType.weak) && !hasStrongBiometric;
  }

  /// Check if biometric is locked out
  bool get isLockedOut {
    return status == BiometricStatus.lockedOut ||
        status == BiometricStatus.permanentlyLockedOut;
  }

  /// Check if biometric needs enrollment
  bool get needsEnrollment {
    return status == BiometricStatus.notEnrolled && isDeviceSupported;
  }

  /// Get primary biometric type
  BiometricType? get primaryBiometricType {
    if (availableTypes.isEmpty) return null;

    // Prefer strong biometrics
    if (hasStrongBiometric) return BiometricType.strong;

    // Then specific types in order of preference
    if (hasFingerprint) return BiometricType.fingerprint;
    if (hasFaceRecognition) return BiometricType.face;
    if (hasIrisRecognition) return BiometricType.iris;

    // Finally weak biometric
    if (hasOnlyWeakBiometric) return BiometricType.weak;

    return availableTypes.first;
  }

  /// Get user-friendly status message
  String get statusMessage {
    switch (status) {
      case BiometricStatus.available:
        return 'Biometric authentication is available';
      case BiometricStatus.notEnrolled:
        return 'Please enroll biometric authentication in device settings';
      case BiometricStatus.notAvailable:
        return 'Biometric authentication is not available on this device';
      case BiometricStatus.disabled:
        return 'Biometric authentication is disabled';
      case BiometricStatus.lockedOut:
        return 'Biometric authentication is temporarily locked out';
      case BiometricStatus.permanentlyLockedOut:
        return 'Biometric authentication is permanently locked out';
    }
  }

  /// Get available biometric types as display strings
  List<String> get availableTypesDisplay {
    return availableTypes.map((type) {
      switch (type) {
        case BiometricType.fingerprint:
          return 'Fingerprint';
        case BiometricType.face:
          return 'Face Recognition';
        case BiometricType.iris:
          return 'Iris Recognition';
        case BiometricType.voice:
          return 'Voice Recognition';
        case BiometricType.strong:
          return 'Strong Biometric';
        case BiometricType.weak:
          return 'Weak Biometric';
      }
    }).toList();
  }

  /// Check if capability info is stale (older than 5 minutes)
  bool get isStale {
    if (lastCheckedAt == null) return true;

    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
    return lastCheckedAt!.isBefore(fiveMinutesAgo);
  }

  /// Get recommended action for user
  String? get recommendedAction {
    if (!isDeviceSupported) {
      return 'Device does not support biometric authentication';
    }

    if (needsEnrollment) {
      return 'Go to device settings to set up biometric authentication';
    }

    if (isLockedOut) {
      return 'Try again later or use alternative authentication method';
    }

    if (status == BiometricStatus.disabled) {
      return 'Enable biometric authentication in app settings';
    }

    return null;
  }
}
