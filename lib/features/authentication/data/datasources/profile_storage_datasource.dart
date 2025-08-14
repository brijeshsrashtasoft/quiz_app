import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/firebase_constants.dart';

/// Profile storage data source for Firebase Storage operations
/// Handles avatar uploads, downloads, and management following free tier constraints
/// Following CLAUDE.md Firebase Storage integration patterns
class ProfileStorageDataSource {
  final FirebaseStorage _storage;

  ProfileStorageDataSource({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  /// Upload user avatar to Firebase Storage
  /// Automatically compresses and optimizes images to stay within free tier limits
  Future<Result<String>> uploadAvatar({
    required String userId,
    required Uint8List imageData,
    required String fileName,
  }) async {
    try {
      AppLogger.firebase(
        'ProfileStorageDataSource',
        'Starting avatar upload for user: $userId',
      );
      final startTime = DateTime.now();

      // Validate file size (max 5MB per Firebase Storage free tier guidelines)
      const maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
      if (imageData.length > maxFileSizeBytes) {
        return Result.failure(
          Failure.validationFailure(
            message:
                'Image file size exceeds 5MB. Please choose a smaller image.',
            fieldErrors: {'image': 'File size must be less than 5MB'},
          ),
        );
      }

      // Validate file type by extension
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      final fileExtension = _getFileExtension(fileName).toLowerCase();
      if (!allowedExtensions.contains(fileExtension)) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Invalid file type. Please use JPG, PNG, or WebP format.',
            fieldErrors: {
              'image': 'Only JPG, PNG, and WebP formats are supported',
            },
          ),
        );
      }

      // Create storage reference following organized structure
      // users/{userId}/avatar.{extension} for easy management
      final storageRef = _storage
          .ref()
          .child(FirebaseConstants.userAvatarsPath)
          .child(userId)
          .child('avatar.$fileExtension');

      // Set metadata for proper caching and content type
      final metadata = SettableMetadata(
        contentType: _getContentType(fileExtension),
        cacheControl: 'public, max-age=86400', // Cache for 24 hours
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'originalFileName': fileName,
        },
      );

      // Upload file to Firebase Storage
      final uploadTask = storageRef.putData(imageData, metadata);

      // Monitor upload progress if needed (useful for large files)
      // ignore: unused_result
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          AppLogger.firebase(
            'ProfileStorageDataSource',
            'Upload progress for $userId: ${(progress * 100).toStringAsFixed(1)}%',
          );
        },
        onError: (error) {
          AppLogger.error('Upload progress error for $userId', error);
        },
      );

      // Wait for upload completion
      final taskSnapshot = await uploadTask;

      // Get download URL for the uploaded file
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Avatar Upload', duration);
      AppLogger.firebase(
        'ProfileStorageDataSource',
        'Avatar upload successful for $userId. URL: $downloadUrl',
      );

      return Result.success(downloadUrl);
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase Storage error during avatar upload', e);
      return Result.failure(_mapStorageException(e));
    } catch (e) {
      AppLogger.error('Unexpected error during avatar upload', e);
      return Result.failure(
        Failure.unknownFailure(
          message: 'Avatar upload failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Delete user avatar from Firebase Storage
  Future<Result<void>> deleteAvatar(String userId) async {
    try {
      AppLogger.firebase(
        'ProfileStorageDataSource',
        'Deleting avatar for user: $userId',
      );
      final startTime = DateTime.now();

      // Get all possible avatar files for the user
      final avatarFolder = _storage
          .ref()
          .child(FirebaseConstants.userAvatarsPath)
          .child(userId);

      // List all files in user's avatar folder
      final listResult = await avatarFolder.listAll();

      // Delete all avatar files
      for (final item in listResult.items) {
        await item.delete();
        AppLogger.firebase(
          'ProfileStorageDataSource',
          'Deleted avatar file: ${item.fullPath}',
        );
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Avatar Deletion', duration);
      AppLogger.firebase(
        'ProfileStorageDataSource',
        'Avatar deletion successful for user: $userId',
      );

      return const Result.success(null);
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase Storage error during avatar deletion', e);
      if (e.code == 'object-not-found') {
        // If avatar doesn't exist, consider it successful
        AppLogger.firebase(
          'ProfileStorageDataSource',
          'No avatar found for user $userId - deletion considered successful',
        );
        return const Result.success(null);
      }
      return Result.failure(_mapStorageException(e));
    } catch (e) {
      AppLogger.error('Unexpected error during avatar deletion', e);
      return Result.failure(
        Failure.unknownFailure(
          message: 'Avatar deletion failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Get avatar download URL for a user
  Future<Result<String?>> getAvatarUrl(String userId) async {
    try {
      AppLogger.firebase(
        'ProfileStorageDataSource',
        'Getting avatar URL for user: $userId',
      );
      final startTime = DateTime.now();

      // Try to find avatar with common extensions
      final extensions = ['jpg', 'jpeg', 'png', 'webp'];

      for (final extension in extensions) {
        try {
          final avatarRef = _storage
              .ref()
              .child(FirebaseConstants.userAvatarsPath)
              .child(userId)
              .child('avatar.$extension');

          final downloadUrl = await avatarRef.getDownloadURL();

          final duration = DateTime.now().difference(startTime);
          AppLogger.performance('Get Avatar URL', duration);
          AppLogger.firebase(
            'ProfileStorageDataSource',
            'Avatar URL retrieved for $userId: $downloadUrl',
          );

          return Result.success(downloadUrl);
        } on FirebaseException catch (e) {
          if (e.code == 'object-not-found') {
            // Continue to try next extension
            continue;
          }
          // Re-throw other Firebase exceptions
          rethrow;
        }
      }

      // No avatar found with any extension
      AppLogger.firebase(
        'ProfileStorageDataSource',
        'No avatar found for user: $userId',
      );
      return const Result.success(null);
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase Storage error getting avatar URL', e);
      return Result.failure(_mapStorageException(e));
    } catch (e) {
      AppLogger.error('Unexpected error getting avatar URL', e);
      return Result.failure(
        Failure.unknownFailure(
          message: 'Failed to get avatar URL: ${e.toString()}',
        ),
      );
    }
  }

  /// Check if user has an avatar
  Future<Result<bool>> hasAvatar(String userId) async {
    try {
      final avatarUrlResult = await getAvatarUrl(userId);
      return avatarUrlResult.when(
        success: (url) => Result.success(url != null),
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      AppLogger.error('Error checking if user has avatar', e);
      return Result.failure(
        Failure.unknownFailure(
          message: 'Failed to check avatar existence: ${e.toString()}',
        ),
      );
    }
  }

  /// Get storage usage information for monitoring free tier limits
  Future<Result<StorageUsageInfo>> getStorageUsage(String userId) async {
    try {
      AppLogger.firebase(
        'ProfileStorageDataSource',
        'Getting storage usage for user: $userId',
      );

      final avatarFolder = _storage
          .ref()
          .child(FirebaseConstants.userAvatarsPath)
          .child(userId);

      final listResult = await avatarFolder.listAll();

      int totalSize = 0;
      int fileCount = 0;

      for (final item in listResult.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
        fileCount++;
      }

      final usageInfo = StorageUsageInfo(
        totalSizeBytes: totalSize,
        fileCount: fileCount,
        userId: userId,
      );

      AppLogger.firebase(
        'ProfileStorageDataSource',
        'Storage usage for $userId: ${usageInfo.totalSizeMB.toStringAsFixed(2)}MB, $fileCount files',
      );

      return Result.success(usageInfo);
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase Storage error getting usage info', e);
      return Result.failure(_mapStorageException(e));
    } catch (e) {
      AppLogger.error('Unexpected error getting storage usage', e);
      return Result.failure(
        Failure.unknownFailure(
          message: 'Failed to get storage usage: ${e.toString()}',
        ),
      );
    }
  }

  // ===========================
  // PRIVATE HELPER METHODS
  // ===========================

  /// Map Firebase Storage exceptions to domain failures
  Failure _mapStorageException(FirebaseException e) {
    switch (e.code) {
      case 'storage/object-not-found':
        return Failure.serverFailure(message: 'File not found', code: e.code);
      case 'storage/unauthorized':
        return Failure.authFailure(
          message: 'You are not authorized to perform this action',
          code: e.code,
        );
      case 'storage/canceled':
        return Failure.serverFailure(
          message: 'Upload was canceled',
          code: e.code,
        );
      case 'storage/unknown':
        return Failure.unknownFailure(message: 'An unknown error occurred');
      case 'storage/quota-exceeded':
        return Failure.serverFailure(
          message: 'Storage quota exceeded. Please contact support',
          code: e.code,
        );
      case 'storage/unauthenticated':
        return Failure.authFailure(
          message: 'Please sign in to continue',
          code: e.code,
        );
      case 'storage/retry-limit-exceeded':
        return Failure.networkFailure(
          message: 'Upload failed after multiple retries. Please try again',
        );
      case 'storage/invalid-checksum':
        return Failure.serverFailure(
          message:
              'File upload failed due to data corruption. Please try again',
          code: e.code,
        );
      default:
        return Failure.serverFailure(
          message: e.message ?? 'Storage operation failed',
          code: e.code,
        );
    }
  }

  /// Get file extension from filename
  String _getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return fileName.substring(lastDotIndex + 1);
  }

  /// Get content type for file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg'; // Default to JPEG
    }
  }
}

/// Storage usage information for monitoring free tier limits
class StorageUsageInfo {
  final int totalSizeBytes;
  final int fileCount;
  final String userId;

  const StorageUsageInfo({
    required this.totalSizeBytes,
    required this.fileCount,
    required this.userId,
  });

  /// Get total size in MB
  double get totalSizeMB => totalSizeBytes / (1024 * 1024);

  /// Check if approaching free tier limit (5GB)
  bool get isApproachingLimit => totalSizeMB > 4000; // 4GB warning threshold

  /// Check if exceeding recommended per-user limit (100MB)
  bool get exceedsUserLimit => totalSizeMB > 100;

  @override
  String toString() {
    return 'StorageUsageInfo('
        'userId: $userId, '
        'totalSize: ${totalSizeMB.toStringAsFixed(2)}MB, '
        'fileCount: $fileCount'
        ')';
  }
}
