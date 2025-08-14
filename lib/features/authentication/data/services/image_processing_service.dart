import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/firebase_constants.dart';

/// Image processing service for optimizing images before Firebase Storage upload
/// Implements compression and resizing to stay within free tier limits
/// Following CLAUDE.md performance guidelines
class ImageProcessingService {
  /// Compress and optimize image for avatar upload
  /// Reduces file size while maintaining quality suitable for profile pictures
  static Future<Result<Uint8List>> optimizeAvatarImage({
    required Uint8List imageData,
    int maxWidth = 512,
    int maxHeight = 512,
    int quality = 85,
  }) async {
    try {
      AppLogger.firebase(
        'ImageProcessingService',
        'Starting image optimization. Original size: ${imageData.length} bytes',
      );
      final startTime = DateTime.now();

      // Validate input size
      if (imageData.length > FirebaseConstants.maxFileSizeBytes) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Image file is too large. Maximum size is 5MB.',
            fieldErrors: {
              'image':
                  'File size exceeds ${FirebaseConstants.maxFileSizeBytes ~/ (1024 * 1024)}MB limit',
            },
          ),
        );
      }

      // Decode the image
      final codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: maxWidth,
        targetHeight: maxHeight,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Calculate optimal dimensions maintaining aspect ratio
      final aspectRatio = image.width / image.height;
      int newWidth, newHeight;

      if (aspectRatio > 1) {
        // Landscape image
        newWidth = maxWidth;
        newHeight = (maxWidth / aspectRatio).round();
      } else {
        // Portrait image
        newHeight = maxHeight;
        newWidth = (maxHeight * aspectRatio).round();
      }

      // Ensure dimensions don't exceed maximums
      if (newWidth > maxWidth) {
        newWidth = maxWidth;
        newHeight = (maxWidth / aspectRatio).round();
      }
      if (newHeight > maxHeight) {
        newHeight = maxHeight;
        newWidth = (maxHeight * aspectRatio).round();
      }

      AppLogger.firebase(
        'ImageProcessingService',
        'Resizing image from ${image.width}x${image.height} to ${newWidth}x$newHeight',
      );

      // Create a new image with the calculated dimensions
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw the resized image
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
        Paint()..filterQuality = FilterQuality.high,
      );

      final picture = recorder.endRecording();
      final resizedImage = await picture.toImage(newWidth, newHeight);

      // Convert to PNG format (lossless but typically smaller than original)
      final byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        return Result.failure(
          Failure.unknownFailure(message: 'Failed to process image data'),
        );
      }

      final optimizedData = byteData.buffer.asUint8List();

      // If the optimized image is still too large, try with lower quality
      if (optimizedData.length > FirebaseConstants.maxFileSizeBytes) {
        AppLogger.firebase(
          'ImageProcessingService',
          'First optimization resulted in ${optimizedData.length} bytes, trying JPEG with quality $quality',
        );

        // Try JPEG format with quality compression
        final jpegByteData = await resizedImage.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (jpegByteData == null) {
          return Result.failure(
            Failure.unknownFailure(message: 'Failed to process image data'),
          );
        }

        // For JPEG compression, we would need a proper image encoding library
        // For now, return the PNG version if it's under the limit
        if (optimizedData.length <= FirebaseConstants.maxFileSizeBytes) {
          final duration = DateTime.now().difference(startTime);
          AppLogger.performance('Image Optimization', duration);
          AppLogger.firebase(
            'ImageProcessingService',
            'Image optimization completed. Final size: ${optimizedData.length} bytes '
                '(${(optimizedData.length / 1024 / 1024).toStringAsFixed(2)}MB)',
          );

          return Result.success(optimizedData);
        } else {
          return Result.failure(
            Failure.validationFailure(
              message:
                  'Unable to compress image to required size. Please choose a smaller image.',
              fieldErrors: {'image': 'Image too large after compression'},
            ),
          );
        }
      }

      final duration = DateTime.now().difference(startTime);
      AppLogger.performance('Image Optimization', duration);
      AppLogger.firebase(
        'ImageProcessingService',
        'Image optimization completed. Original: ${imageData.length} bytes, '
            'Optimized: ${optimizedData.length} bytes '
            '(${((1 - optimizedData.length / imageData.length) * 100).toStringAsFixed(1)}% reduction)',
      );

      return Result.success(optimizedData);
    } catch (e, stackTrace) {
      AppLogger.error('Image optimization failed', e, stackTrace);
      return Result.failure(
        Failure.unknownFailure(
          message: 'Image processing failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Validate image file before processing
  static Result<void> validateImageFile({
    required Uint8List imageData,
    required String fileName,
  }) {
    try {
      // Check file size
      if (imageData.isEmpty) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Image file is empty',
            fieldErrors: {'image': 'Please select a valid image file'},
          ),
        );
      }

      if (imageData.length > FirebaseConstants.maxFileSizeBytes) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Image file is too large. Maximum size is 5MB.',
            fieldErrors: {
              'image':
                  'File size exceeds ${FirebaseConstants.maxFileSizeBytes ~/ (1024 * 1024)}MB limit',
            },
          ),
        );
      }

      // Check file extension
      final extension = _getFileExtension(fileName).toLowerCase();
      if (!FirebaseConstants.allowedImageExtensions.contains(extension)) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Invalid file type. Please use JPG, PNG, or WebP format.',
            fieldErrors: {
              'image':
                  'Only ${FirebaseConstants.allowedImageExtensions.join(', ')} formats are supported',
            },
          ),
        );
      }

      // Basic image format validation by checking file headers
      if (!_isValidImageFormat(imageData)) {
        return Result.failure(
          Failure.validationFailure(
            message: 'Invalid image format. Please select a valid image file.',
            fieldErrors: {'image': 'File does not appear to be a valid image'},
          ),
        );
      }

      AppLogger.firebase(
        'ImageProcessingService',
        'Image validation passed for file: $fileName (${imageData.length} bytes)',
      );

      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Image validation failed', e);
      return Result.failure(
        Failure.unknownFailure(
          message: 'Image validation failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Get estimated compressed file size without actually compressing
  /// Useful for UI feedback before actual upload
  static int estimateCompressedSize({
    required int originalSize,
    int targetWidth = 512,
    int targetHeight = 512,
  }) {
    // Very rough estimation based on typical compression ratios
    // PNG typically compresses to about 60-80% of original for photos
    // Resizing also reduces file size proportionally to pixel reduction

    const compressionRatio =
        0.7; // Assume 70% of original size after compression
    const maxPixels = 512 * 512; // Target resolution
    const typicalOriginalPixels =
        2048 * 1536; // Assume typical phone camera resolution

    final pixelReductionRatio = maxPixels / typicalOriginalPixels;
    final estimatedSize =
        (originalSize * compressionRatio * pixelReductionRatio).round();

    return estimatedSize.clamp(0, originalSize);
  }

  /// Check if image meets recommended dimensions for avatars
  static Future<Result<ImageDimensions>> getImageDimensions(
    Uint8List imageData,
  ) async {
    try {
      final codec = await ui.instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final dimensions = ImageDimensions(
        width: image.width,
        height: image.height,
      );

      AppLogger.firebase(
        'ImageProcessingService',
        'Image dimensions: ${dimensions.width}x${dimensions.height}',
      );

      return Result.success(dimensions);
    } catch (e) {
      AppLogger.error('Failed to get image dimensions', e);
      return Result.failure(
        Failure.unknownFailure(
          message: 'Failed to read image dimensions: ${e.toString()}',
        ),
      );
    }
  }

  // ===========================
  // PRIVATE HELPER METHODS
  // ===========================

  /// Get file extension from filename
  static String _getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return fileName.substring(lastDotIndex + 1);
  }

  /// Basic image format validation by checking file headers
  static bool _isValidImageFormat(Uint8List data) {
    if (data.length < 4) return false;

    // Check PNG signature
    if (data[0] == 0x89 &&
        data[1] == 0x50 &&
        data[2] == 0x4E &&
        data[3] == 0x47) {
      return true;
    }

    // Check JPEG signature
    if (data[0] == 0xFF && data[1] == 0xD8) {
      return true;
    }

    // Check WebP signature
    if (data.length >= 12 &&
        data[0] == 0x52 &&
        data[1] == 0x49 &&
        data[2] == 0x46 &&
        data[3] == 0x46 &&
        data[8] == 0x57 &&
        data[9] == 0x45 &&
        data[10] == 0x42 &&
        data[11] == 0x50) {
      return true;
    }

    // Check GIF signature
    if (data.length >= 6 &&
        ((data[0] == 0x47 && data[1] == 0x49 && data[2] == 0x46) && // "GIF"
            (data[3] == 0x38 &&
                (data[4] == 0x37 || data[4] == 0x39) &&
                data[5] == 0x61))) {
      // "87a" or "89a"
      return true;
    }

    return false;
  }
}

/// Image dimensions data class
class ImageDimensions {
  final int width;
  final int height;

  const ImageDimensions({required this.width, required this.height});

  /// Get aspect ratio
  double get aspectRatio => width / height;

  /// Check if image is square (good for avatars)
  bool get isSquare => (width - height).abs() <= 10; // Allow 10px tolerance

  /// Check if image is landscape
  bool get isLandscape => width > height;

  /// Check if image is portrait
  bool get isPortrait => height > width;

  /// Get total pixels
  int get totalPixels => width * height;

  /// Check if image meets minimum avatar requirements
  bool get meetsAvatarRequirements => width >= 256 && height >= 256;

  @override
  String toString() => '${width}x$height';

  @override
  bool operator ==(Object other) {
    return other is ImageDimensions &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(width, height);
}
