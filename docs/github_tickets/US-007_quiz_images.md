# US-007: Add Images to Quiz Questions

## User Story
As a quiz creator, I want to add images to questions so that I can make quizzes more visual and engaging.

## User Journey Map
```
Image Addition Flow:
1. Creator editing question → Sees "Add Image" button
2. Clicks button → Image upload options
3. Selects/uploads image → Preview shown
4. Adjusts image → Saves with question
5. Players see image → Enhanced engagement
```

## Acceptance Criteria
- [ ] "Add Image" button on each question
- [ ] Support JPEG, PNG, WebP formats
- [ ] Maximum file size 5MB per image
- [ ] Automatic image compression/optimization
- [ ] Image preview with edit/remove options
- [ ] Responsive image display in quiz player
- [ ] Fallback for failed image loads
- [ ] Progress indicator during upload
- [ ] Multiple upload methods (camera, gallery, URL)
- [ ] Accessibility alt text required
- [ ] Storage quota tracking (100MB free tier)
- [ ] Works offline with cached images

## Navigation Flow

### Current State
```
Image upload widget exists (UI only)
No Firebase Storage integration
Using placeholder images
No actual upload functionality
```

### Required Implementation
```
1. Image Upload Flow:
   Question Editor → "Add Image" button
   ├── Upload Options Dialog
   │   ├── Take Photo (mobile)
   │   ├── Choose from Gallery
   │   ├── Enter Image URL
   │   └── Browse Stock Images (future)
   │
   ├── Image Selected → Processing
   │   ├── Validate format/size
   │   ├── Compress if needed
   │   ├── Generate thumbnails
   │   └── Upload to Firebase
   │
   └── Upload Complete → Question Updated
       ├── Show preview
       ├── Alt text input
       ├── Edit/crop options
       └── Remove option

2. Player Experience:
   Question Display
   ├── Load optimized image
   ├── Progressive loading
   ├── Tap to zoom (mobile)
   └── Fallback on error
```

## Technical Implementation

### 1. Firebase Storage Integration
```dart
// lib/features/quiz_creation/data/services/image_upload_service.dart

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ImageUploadService {
  final FirebaseStorage _storage;
  final ImagePicker _picker;
  
  static const int maxWidth = 1200;
  static const int maxHeight = 800;
  static const int thumbnailSize = 300;
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  
  Future<Either<Failure, ImageUploadResult>> uploadQuestionImage({
    required String quizId,
    required String questionId,
    required ImageSource source,
  }) async {
    try {
      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        imageQuality: 85,
      );
      
      if (pickedFile == null) {
        return const Left(ImageUploadFailure.cancelled());
      }
      
      // Validate file size
      final fileSize = await pickedFile.length();
      if (fileSize > maxFileSizeBytes) {
        return const Left(ImageUploadFailure.fileTooLarge());
      }
      
      // Process image
      final processedImage = await _processImage(pickedFile);
      
      // Upload to Firebase Storage
      final imagePath = 'quizzes/$quizId/questions/$questionId/image.jpg';
      final thumbnailPath = 'quizzes/$quizId/questions/$questionId/thumbnail.jpg';
      
      // Upload main image
      final imageRef = _storage.ref(imagePath);
      final imageUploadTask = imageRef.putData(
        processedImage.imageData,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalName': pickedFile.name,
          },
        ),
      );
      
      // Upload thumbnail
      final thumbnailRef = _storage.ref(thumbnailPath);
      final thumbnailUploadTask = thumbnailRef.putData(
        processedImage.thumbnailData,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Track progress
      final tasks = [imageUploadTask, thumbnailUploadTask];
      await Future.wait(tasks.map((task) => task.whenComplete(() {})));
      
      // Get download URLs
      final imageUrl = await imageRef.getDownloadURL();
      final thumbnailUrl = await thumbnailRef.getDownloadURL();
      
      return Right(ImageUploadResult(
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
        width: processedImage.width,
        height: processedImage.height,
        sizeBytes: processedImage.imageData.length,
      ));
    } catch (e) {
      return Left(ImageUploadFailure.fromException(e));
    }
  }
  
  Future<ProcessedImage> _processImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;
    
    // Resize if needed
    final resized = img.copyResize(
      image,
      width: image.width > maxWidth ? maxWidth : null,
      height: image.height > maxHeight ? maxHeight : null,
    );
    
    // Create thumbnail
    final thumbnail = img.copyResize(
      image,
      width: thumbnailSize,
      height: thumbnailSize,
    );
    
    // Compress
    final imageData = Uint8List.fromList(
      img.encodeJpg(resized, quality: 85),
    );
    
    final thumbnailData = Uint8List.fromList(
      img.encodeJpg(thumbnail, quality: 75),
    );
    
    return ProcessedImage(
      imageData: imageData,
      thumbnailData: thumbnailData,
      width: resized.width,
      height: resized.height,
    );
  }
}
```

### 2. Update Image Upload Widget
```dart
// lib/features/quiz_creation/presentation/widgets/image_upload_widget.dart

class ImageUploadWidget extends ConsumerStatefulWidget {
  final String? currentImageUrl;
  final Function(String imageUrl, String? altText) onImageUploaded;
  final VoidCallback? onImageRemoved;
  
  @override
  _ImageUploadWidgetState createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends ConsumerState<ImageUploadWidget> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _altText;
  
  @override
  Widget build(BuildContext context) {
    if (widget.currentImageUrl != null) {
      return _buildImagePreview();
    }
    
    return _buildUploadPrompt();
  }
  
  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: widget.currentImageUrl!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 200,
                color: Colors.white,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 200,
              color: Colors.grey[200],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48),
                  Text('Failed to load image'),
                ],
              ),
            ),
          ),
        ),
        
        // Action buttons
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _showAltTextDialog,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _confirmRemove,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Alt text indicator
        if (_altText != null)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.accessibility, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Alt text added',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildUploadPrompt() {
    if (_isUploading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: _uploadProgress),
            const SizedBox(height: 16),
            Text('Uploading... ${(_uploadProgress * 100).toInt()}%'),
          ],
        ),
      );
    }
    
    return InkWell(
      onTap: _showImageSourceDialog,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              'Add Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'JPEG, PNG, WebP (max 5MB)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _showImageSourceDialog() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Enter Image URL'),
              onTap: () => Navigator.pop(context, null),
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
    
    if (source != null) {
      await _uploadImage(source);
    }
  }
  
  Future<void> _uploadImage(ImageSource source) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });
    
    final quizState = ref.read(quizCreationProvider);
    final uploadService = ref.read(imageUploadServiceProvider);
    
    final result = await uploadService.uploadQuestionImage(
      quizId: quizState.quiz!.id!,
      questionId: const Uuid().v4(),
      source: source,
    );
    
    result.fold(
      (failure) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (uploadResult) {
        setState(() => _isUploading = false);
        _showAltTextDialog(uploadResult.imageUrl);
      },
    );
  }
}
```

### 3. Image Display in Quiz Player
```dart
// lib/features/game/presentation/widgets/question_image.dart

class QuestionImage extends StatelessWidget {
  final String imageUrl;
  final String? altText;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: Hero(
        tag: 'question_image_$imageUrl',
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: 300,
            maxWidth: double.infinity,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => _buildPlaceholder(),
              errorWidget: (context, url, error) => _buildErrorWidget(),
              // Accessibility
              semanticsLabel: altText ?? 'Question image',
            ),
          ),
        ),
      ),
    );
  }
  
  void _showFullScreenImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          imageUrl: imageUrl,
          altText: altText,
        ),
      ),
    );
  }
}
```

### 4. Storage Quota Management
```dart
// lib/features/quiz_creation/domain/services/storage_quota_service.dart

class StorageQuotaService {
  static const int freeQuotaBytes = 100 * 1024 * 1024; // 100MB
  
  Future<StorageQuota> getUserQuota(String userId) async {
    final userDoc = await _firestore
        .collection('users')
        .doc(userId)
        .get();
    
    final usedBytes = userDoc.data()?['storageUsed'] ?? 0;
    
    return StorageQuota(
      usedBytes: usedBytes,
      totalBytes: freeQuotaBytes,
      remainingBytes: freeQuotaBytes - usedBytes,
    );
  }
  
  Future<bool> checkQuota(String userId, int additionalBytes) async {
    final quota = await getUserQuota(userId);
    return quota.remainingBytes >= additionalBytes;
  }
  
  Future<void> updateUsedStorage(String userId, int bytesChange) async {
    await _firestore.collection('users').doc(userId).update({
      'storageUsed': FieldValue.increment(bytesChange),
    });
  }
}
```

### 5. Offline Support
```dart
// lib/features/quiz_creation/data/services/image_cache_service.dart

class ImageCacheService {
  static const String cacheKey = 'quiz_images_cache';
  
  Future<void> cacheImage(String url, Uint8List data) async {
    final box = await Hive.openBox<Uint8List>(cacheKey);
    await box.put(url, data);
  }
  
  Future<Uint8List?> getCachedImage(String url) async {
    final box = await Hive.openBox<Uint8List>(cacheKey);
    return box.get(url);
  }
  
  Future<void> preloadQuizImages(Quiz quiz) async {
    final imagesToCache = quiz.questions
        .where((q) => q.imageUrl != null)
        .map((q) => q.imageUrl!)
        .toList();
    
    for (final url in imagesToCache) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await cacheImage(url, response.bodyBytes);
        }
      } catch (e) {
        // Continue with other images
      }
    }
  }
}
```

## Image Requirements

### Supported Formats
- JPEG (.jpg, .jpeg)
- PNG (.png)
- WebP (.webp)

### Size Limits
- Maximum file size: 5MB
- Recommended dimensions: 1200x800px
- Minimum dimensions: 200x200px
- Automatic compression above 1MB

### Accessibility
- Alt text required for all images
- Minimum contrast ratio for overlaid text
- Support for screen readers
- Keyboard navigation for image actions

## Error Handling

```dart
enum ImageUploadError {
  fileTooLarge('Image must be less than 5MB'),
  unsupportedFormat('Please use JPEG, PNG, or WebP'),
  uploadFailed('Failed to upload image. Please try again'),
  quotaExceeded('Storage limit reached. Delete old images first'),
  networkError('Check your internet connection'),
  accessDenied('Camera/gallery access denied');
  
  final String message;
  const ImageUploadError(this.message);
}
```

## Testing Requirements

### Unit Tests
- [ ] Image compression logic
- [ ] Format validation
- [ ] Quota calculations
- [ ] Cache management

### Integration Tests
- [ ] Upload flow with Firebase
- [ ] Progress tracking
- [ ] Error scenarios
- [ ] Offline functionality

### E2E Tests
- [ ] Add image from camera
- [ ] Add image from gallery
- [ ] Edit alt text
- [ ] Remove image
- [ ] View in quiz player

## Performance Optimization
- Progressive image loading
- Thumbnail generation for lists
- CDN integration for global delivery
- WebP format for modern browsers
- Lazy loading in quiz player

## Security Considerations
- Validate image content (no inappropriate content)
- Sanitize file names
- Restrict file types server-side
- Implement rate limiting
- Scan for malware

## Related Issues
- Depends on: US-006 (Create quiz)
- Blocks: Enhanced quiz experience
- Related: Storage management
- Related: Offline support

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Firebase Storage integrated
- [ ] Image compression working
- [ ] Alt text functionality complete
- [ ] Quota tracking implemented
- [ ] Offline caching working
- [ ] Unit tests passing (>85% coverage)
- [ ] Integration tests passing
- [ ] Manual testing on all platforms
- [ ] Performance benchmarks met
- [ ] Security review passed