import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_failure.freezed.dart';

/// Profile-specific failures for Clean Architecture error handling
/// Following CLAUDE.md patterns and using composition
@freezed
class ProfileFailure with _$ProfileFailure {
  const ProfileFailure._();
  const factory ProfileFailure.invalidUsername({
    required String message,
    @Default('PROFILE_INVALID_USERNAME') String code,
  }) = InvalidUsernameFailure;

  const factory ProfileFailure.usernameTaken({
    required String message,
    @Default('PROFILE_USERNAME_TAKEN') String code,
  }) = UsernameTakenFailure;

  const factory ProfileFailure.invalidProfileImage({
    required String message,
    @Default('PROFILE_INVALID_IMAGE') String code,
  }) = InvalidProfileImageFailure;

  const factory ProfileFailure.imageUploadFailed({
    required String message,
    @Default('PROFILE_IMAGE_UPLOAD_FAILED') String code,
  }) = ImageUploadFailedFailure;

  const factory ProfileFailure.profileNotFound({
    required String message,
    @Default('PROFILE_NOT_FOUND') String code,
  }) = ProfileNotFoundFailure;

  const factory ProfileFailure.profileUpdateFailed({
    required String message,
    @Default('PROFILE_UPDATE_FAILED') String code,
  }) = ProfileUpdateFailedFailure;

  const factory ProfileFailure.insufficientPermissions({
    required String message,
    @Default('PROFILE_INSUFFICIENT_PERMISSIONS') String code,
  }) = InsufficientPermissionsFailure;

  const factory ProfileFailure.accountDeletionFailed({
    required String message,
    @Default('PROFILE_ACCOUNT_DELETION_FAILED') String code,
  }) = AccountDeletionFailedFailure;

  const factory ProfileFailure.statsUpdateFailed({
    required String message,
    @Default('PROFILE_STATS_UPDATE_FAILED') String code,
  }) = StatsUpdateFailedFailure;

  const factory ProfileFailure.preferencesUpdateFailed({
    required String message,
    @Default('PROFILE_PREFERENCES_UPDATE_FAILED') String code,
  }) = PreferencesUpdateFailedFailure;

  const factory ProfileFailure.privacySettingsUpdateFailed({
    required String message,
    @Default('PROFILE_PRIVACY_SETTINGS_UPDATE_FAILED') String code,
  }) = PrivacySettingsUpdateFailedFailure;

  const factory ProfileFailure.onboardingUpdateFailed({
    required String message,
    @Default('PROFILE_ONBOARDING_UPDATE_FAILED') String code,
  }) = OnboardingUpdateFailedFailure;

  const factory ProfileFailure.invalidBio({
    required String message,
    @Default('PROFILE_INVALID_BIO') String code,
  }) = InvalidBioFailure;

  const factory ProfileFailure.rateLimitExceeded({
    required String message,
    @Default('PROFILE_RATE_LIMIT_EXCEEDED') String code,
  }) = RateLimitExceededFailure;

  const factory ProfileFailure.networkError({
    required String message,
    @Default('PROFILE_NETWORK_ERROR') String code,
  }) = ProfileNetworkErrorFailure;

  const factory ProfileFailure.unknown({
    required String message,
    @Default('PROFILE_UNKNOWN_ERROR') String code,
  }) = UnknownProfileFailure;

  String get userMessage => when(
    invalidUsername: (message, code) => message,
    usernameTaken: (message, code) => message,
    invalidProfileImage: (message, code) => message,
    imageUploadFailed: (message, code) => message,
    profileNotFound: (message, code) => message,
    profileUpdateFailed: (message, code) => message,
    insufficientPermissions: (message, code) => message,
    accountDeletionFailed: (message, code) => message,
    statsUpdateFailed: (message, code) => message,
    preferencesUpdateFailed: (message, code) => message,
    privacySettingsUpdateFailed: (message, code) => message,
    onboardingUpdateFailed: (message, code) => message,
    invalidBio: (message, code) => message,
    rateLimitExceeded: (message, code) => message,
    networkError: (message, code) => message,
    unknown: (message, code) => message,
  );

  String get technicalMessage => when(
    invalidUsername: (message, code) => '$code: $message',
    usernameTaken: (message, code) => '$code: $message',
    invalidProfileImage: (message, code) => '$code: $message',
    imageUploadFailed: (message, code) => '$code: $message',
    profileNotFound: (message, code) => '$code: $message',
    profileUpdateFailed: (message, code) => '$code: $message',
    insufficientPermissions: (message, code) => '$code: $message',
    accountDeletionFailed: (message, code) => '$code: $message',
    statsUpdateFailed: (message, code) => '$code: $message',
    preferencesUpdateFailed: (message, code) => '$code: $message',
    privacySettingsUpdateFailed: (message, code) => '$code: $message',
    onboardingUpdateFailed: (message, code) => '$code: $message',
    invalidBio: (message, code) => '$code: $message',
    rateLimitExceeded: (message, code) => '$code: $message',
    networkError: (message, code) => '$code: $message',
    unknown: (message, code) => '$code: $message',
  );
}
