import 'dart:typed_data';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/firebase/auth_config.dart';
import '../repositories/user_repository.dart';
import '../../data/datasources/profile_storage_datasource.dart';
import '../../data/services/image_processing_service.dart';

/// Use case for uploading user avatar to Firebase Storage
/// Handles image optimization, upload, and profile update
/// Following CLAUDE.md Clean Architecture patterns
class UploadAvatarUseCase extends BaseUseCase<String, UploadAvatarParams> {
  final UserRepository userRepository;
  final ProfileStorageDataSource storageDataSource;

  UploadAvatarUseCase({
    required this.userRepository,
    required this.storageDataSource,
  });

  @override
  Future<Result<String>> call(UploadAvatarParams params) async {
    try {
      final currentUser = AuthConfig.currentUser;
      if (currentUser == null) {
        return Result.failure(
          Failure.authFailure(
            message: 'No user is currently signed in',
            code: 'AUTH_NO_CURRENT_USER',
          ),
        );
      }

      AppLogger.firebase(
        'UploadAvatarUseCase',
        'Starting avatar upload for user: ${currentUser.uid}',
      );
      final startTime = DateTime.now();

      // Step 1: Validate image file
      final validationResult = ImageProcessingService.validateImageFile(
        imageData: params.imageData,
        fileName: params.fileName,
      );

      if (validationResult.isFailure) {
        return Result.failure(validationResult.failureOrNull!);
      }

      // Step 2: Optimize image for avatar use
      final optimizationResult =
          await ImageProcessingService.optimizeAvatarImage(
            imageData: params.imageData,
            maxWidth: 512,
            maxHeight: 512,
            quality: 85,
          );

      if (optimizationResult.isFailure) {
        return Result.failure(optimizationResult.failureOrNull!);
      }

      final optimizedImageData = optimizationResult.dataOrNull!;

      // Step 3: Delete existing avatar if present
      AppLogger.firebase(
        'UploadAvatarUseCase',
        'Deleting existing avatar for user: ${currentUser.uid}',
      );

      await storageDataSource.deleteAvatar(currentUser.uid);
      // Note: We don't fail if deletion fails - the new upload will overwrite

      // Step 4: Upload optimized image to Firebase Storage
      final uploadResult = await storageDataSource.uploadAvatar(
        userId: currentUser.uid,
        imageData: optimizedImageData,
        fileName: params.fileName,
      );

      if (uploadResult.isFailure) {
        return Result.failure(uploadResult.failureOrNull!);
      }

      final downloadUrl = uploadResult.dataOrNull!;

      // Step 5: Update user profile with new avatar URL
      final getUserResult = await userRepository.getUserById(currentUser.uid);
      if (getUserResult.isFailure) {
        AppLogger.error(
          'Failed to get user for profile update: ${currentUser.uid}',
          getUserResult.failureOrNull,
        );
        return Result.failure(getUserResult.failureOrNull!);
      }

      final currentUserEntity = getUserResult.dataOrNull!;
      final updatedUser = currentUserEntity.copyWith(
        profileImageUrl: downloadUrl,
      );

      final updateResult = await userRepository.updateUser(updatedUser);
      if (updateResult.isFailure) {
        AppLogger.error(
          'Failed to update user profile with new avatar URL',
          updateResult.failureOrNull,
        );

        // Try to clean up the uploaded file since profile update failed
        await storageDataSource.deleteAvatar(currentUser.uid);

        return Result.failure(updateResult.failureOrNull!);
      }

      // Step 6: Update Firebase Auth profile photo URL
      try {
        await AuthConfig.updateUserProfile(photoURL: downloadUrl);
        AppLogger.firebase(
          'UploadAvatarUseCase',
          'Updated Firebase Auth profile photo URL',
        );
      } catch (e) {
        // This is non-critical - the Firestore profile has the correct URL
        AppLogger.warning('Failed to update Firebase Auth photo URL: $e');
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Upload Avatar Use Case', duration);
      AppLogger.firebase(
        'UploadAvatarUseCase',
        'Avatar upload completed successfully for user: ${currentUser.uid}. URL: $downloadUrl',
      );

      return Result.success(downloadUrl);
    } catch (e, stackTrace) {
      AppLogger.error('Avatar upload failed', e, stackTrace);
      return Result.failure(
        Failure.unknownFailure(
          message: 'Avatar upload failed: ${e.toString()}',
        ),
      );
    }
  }
}

/// Parameters for UploadAvatarUseCase
class UploadAvatarParams {
  final Uint8List imageData;
  final String fileName;

  const UploadAvatarParams({required this.imageData, required this.fileName});

  @override
  String toString() =>
      'UploadAvatarParams(fileName: $fileName, size: ${imageData.length} bytes)';
}
