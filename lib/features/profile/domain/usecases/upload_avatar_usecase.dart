import 'dart:io';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for uploading user avatar image
/// Handles image validation and Firebase Storage upload
/// Following CLAUDE.md patterns and free tier compliance
class UploadAvatarUseCase extends BaseUseCase<String, UploadAvatarParams> {
  final ProfileRepository profileRepository;

  UploadAvatarUseCase({required this.profileRepository});

  @override
  Future<Result<String>> call(UploadAvatarParams params) async {
    try {
      AppLogger.info(
        'UploadAvatarUseCase',
        'Uploading avatar for user: ${params.userId}',
      );

      // Validate image file
      final validationResult = _validateImageFile(params.imageFile);
      if (!validationResult.isSuccess) {
        return Result.failure(validationResult.failureOrNull!);
      }

      final startTime = DateTime.now();

      // Upload avatar to Firebase Storage
      final uploadResult = await profileRepository.uploadAvatar(
        params.userId,
        params.imageFile,
      );

      if (!uploadResult.isSuccess) {
        return Result.failure(uploadResult.failureOrNull!);
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Upload Avatar Use Case', duration);
      AppLogger.info(
        'UploadAvatarUseCase',
        'Avatar upload successful for user: ${params.userId}',
      );

      return Result.success(uploadResult.dataOrNull!);
    } catch (e) {
      AppLogger.error('Avatar upload failed', e);
      return Result.failure(
        Failure.serverFailure(
          message: 'Failed to upload avatar. Please try again.',
        ),
      );
    }
  }

  /// Validate image file size and format
  Result<void> _validateImageFile(File imageFile) {
    try {
      // Check if file exists
      if (!imageFile.existsSync()) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Image file does not exist',
          ),
        );
      }

      // Check file size (max 5MB for free tier compliance)
      final fileSizeInBytes = imageFile.lengthSync();
      const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
      if (fileSizeInBytes > maxSizeInBytes) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Image size must be less than 5MB',
          ),
        );
      }

      // Check file extension
      final fileName = imageFile.path.toLowerCase();
      const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
      final hasValidExtension = allowedExtensions.any(
        (ext) => fileName.endsWith(ext),
      );

      if (!hasValidExtension) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Only JPG, PNG, GIF, and WebP images are allowed',
          ),
        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.validationFailure(
          message: 'Failed to validate image file',
        ),
      );
    }
  }
}

/// Parameters for UploadAvatarUseCase
class UploadAvatarParams extends BaseUseCaseParams {
  final String userId;
  final File imageFile;

  const UploadAvatarParams({required this.userId, required this.imageFile});

  @override
  String toString() =>
      'UploadAvatarParams(userId: $userId, imageFile: ${imageFile.path})';
}
