import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_entity.freezed.dart';

/// Authentication user entity for Clean Architecture domain layer
/// Represents the authenticated user without Firebase-specific details
@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    String? displayName,
    String? photoURL,
  }) = _AuthUser;
}

/// Authentication entity that wraps user data with auth state
/// Following Clean Architecture patterns for domain layer
@freezed
class AuthEntity with _$AuthEntity {
  const factory AuthEntity({
    required AuthUser user,
    required bool isEmailVerified,
    DateTime? lastSignInTime,
    DateTime? creationTime,
  }) = _AuthEntity;
}

/// Authentication entity extensions for business logic
extension AuthEntityX on AuthEntity {
  /// Check if user profile is complete
  bool get isProfileComplete {
    return user.displayName?.isNotEmpty == true && user.email.isNotEmpty;
  }

  /// Check if user needs email verification
  bool get needsEmailVerification {
    return !isEmailVerified;
  }

  /// Get display name or fallback to email prefix
  String get displayNameOrEmail {
    if (user.displayName?.isNotEmpty == true) {
      return user.displayName!;
    }
    return user.email.split('@').first;
  }

  /// Check if user has profile photo
  bool get hasProfilePhoto {
    return user.photoURL?.isNotEmpty == true;
  }

  /// Check if user is new (signed up recently)
  bool get isNewUser {
    if (creationTime == null) return false;
    final now = DateTime.now();
    final difference = now.difference(creationTime!);
    return difference.inDays <= 1; // New user within 24 hours
  }

  /// Get user initials for avatar placeholder
  String get initials {
    final name = user.displayName ?? user.email;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

/// Authentication user extensions
extension AuthUserX on AuthUser {
  /// Get user's domain from email
  String get emailDomain {
    return email.split('@').last;
  }

  /// Check if email is from a specific domain
  bool isFromDomain(String domain) {
    return emailDomain.toLowerCase() == domain.toLowerCase();
  }

  /// Get username from email (part before @)
  String get username {
    return email.split('@').first;
  }
}
