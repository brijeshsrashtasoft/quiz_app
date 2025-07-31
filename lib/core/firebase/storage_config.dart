import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/logger.dart';

/// Firebase Storage configuration and helper methods
/// Following CLAUDE.md Firebase integration patterns and free tier restrictions
class StorageConfig {
  static FirebaseStorage? _instance;

  /// Get Firebase Storage instance
  static FirebaseStorage get instance {
    _instance ??= FirebaseStorage.instance;
    return _instance!;
  }

  /// Get reference to quiz images folder
  static Reference get quizImagesRef => instance.ref('quizzes');

  /// Get reference to user avatars folder
  static Reference get userAvatarsRef => instance.ref('users');

  /// Get reference to temp uploads folder
  static Reference get tempUploadsRef => instance.ref('temp');

  /// Upload quiz image with proper validation
  static Future<String> uploadQuizImage({
    required String quizId,
    required String imageId,
    required List<int> imageBytes,
    required String contentType,
  }) async {
    try {
      AppLogger.firebase(
        'StorageConfig',
        'Uploading quiz image: $quizId/$imageId',
      );

      // Validate file size (5MB limit for free tier)
      const maxSize = 5 * 1024 * 1024; // 5MB
      if (imageBytes.length > maxSize) {
        throw Exception('File size exceeds 5MB limit');
      }

      // Validate content type
      if (!_isValidImageType(contentType)) {
        throw Exception(
          'Invalid image type. Only JPEG, PNG, and WebP are allowed',
        );
      }

      final ref = quizImagesRef.child('$quizId/$imageId');
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'quizId': quizId,
        },
      );

      final uploadTask = ref.putData(Uint8List.fromList(imageBytes), metadata);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        AppLogger.firebase(
          'StorageConfig',
          'Upload progress: ${(progress * 100).toStringAsFixed(2)}%',
        );
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.firebase(
        'StorageConfig',
        'Quiz image uploaded successfully: $downloadUrl',
      );

      return downloadUrl;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to upload quiz image', e, stackTrace);
      rethrow;
    }
  }

  /// Upload user avatar with validation
  static Future<String> uploadUserAvatar({
    required String userId,
    required List<int> imageBytes,
    required String contentType,
  }) async {
    try {
      AppLogger.firebase('StorageConfig', 'Uploading user avatar: $userId');

      // Validate file size (5MB limit for free tier)
      const maxSize = 5 * 1024 * 1024; // 5MB
      if (imageBytes.length > maxSize) {
        throw Exception('File size exceeds 5MB limit');
      }

      // Validate content type
      if (!_isValidImageType(contentType)) {
        throw Exception(
          'Invalid image type. Only JPEG, PNG, and WebP are allowed',
        );
      }

      final extension = _getExtensionFromContentType(contentType);
      final ref = userAvatarsRef.child('$userId/avatar.$extension');
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'userId': userId,
        },
      );

      final uploadTask = ref.putData(Uint8List.fromList(imageBytes), metadata);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.firebase(
        'StorageConfig',
        'User avatar uploaded successfully: $downloadUrl',
      );

      return downloadUrl;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to upload user avatar', e, stackTrace);
      rethrow;
    }
  }

  /// Delete quiz image
  static Future<void> deleteQuizImage({
    required String quizId,
    required String imageId,
  }) async {
    try {
      AppLogger.firebase(
        'StorageConfig',
        'Deleting quiz image: $quizId/$imageId',
      );

      final ref = quizImagesRef.child('$quizId/$imageId');
      await ref.delete();

      AppLogger.firebase('StorageConfig', 'Quiz image deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete quiz image', e, stackTrace);
      rethrow;
    }
  }

  /// Delete all quiz images
  static Future<void> deleteAllQuizImages(String quizId) async {
    try {
      AppLogger.firebase(
        'StorageConfig',
        'Deleting all images for quiz: $quizId',
      );

      final listResult = await quizImagesRef.child(quizId).listAll();

      // Delete all items in parallel
      await Future.wait(listResult.items.map((ref) => ref.delete()));

      AppLogger.firebase(
        'StorageConfig',
        'All quiz images deleted successfully',
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete quiz images', e, stackTrace);
      rethrow;
    }
  }

  /// Check if content type is valid image
  static bool _isValidImageType(String contentType) {
    return contentType == 'image/jpeg' ||
        contentType == 'image/png' ||
        contentType == 'image/webp';
  }

  /// Get file extension from content type
  static String _getExtensionFromContentType(String contentType) {
    switch (contentType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      default:
        return 'jpg';
    }
  }

  /// Get storage usage info (for monitoring free tier limits)
  static Future<Map<String, dynamic>> getStorageUsageInfo() async {
    try {
      // Note: Firebase doesn't provide direct API for usage stats
      // This would need to be implemented via Cloud Functions or admin SDK
      // For now, return placeholder data
      return {
        'totalBytes': 0,
        'usedBytes': 0,
        'freeBytes': 5 * 1024 * 1024 * 1024, // 5GB free tier
        'percentageUsed': 0.0,
      };
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get storage usage info', e, stackTrace);
      return {
        'error': e.toString(),
        'totalBytes': 0,
        'usedBytes': 0,
        'freeBytes': 0,
        'percentageUsed': 0.0,
      };
    }
  }
}
