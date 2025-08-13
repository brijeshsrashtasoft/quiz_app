import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_animations.dart';

/// Image upload widget for questions
class ImageUploadWidget extends ConsumerStatefulWidget {
  final String? currentImageUrl;
  final Function(String?) onImageChanged;

  const ImageUploadWidget({
    super.key,
    this.currentImageUrl,
    required this.onImageChanged,
  });

  @override
  ConsumerState<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends ConsumerState<ImageUploadWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isUploading = true;
    });

    // Simulate image upload
    await Future.delayed(const Duration(seconds: 2));

    // For demo, use a placeholder image
    widget.onImageChanged('https://via.placeholder.com/400x300');

    setState(() {
      _isUploading = false;
    });

    _animationController.forward();
  }

  void _removeImage() {
    widget.onImageChanged(null);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.currentImageUrl != null;

    return AnimatedContainer(
      duration: AppAnimations.shortAnimation,
      height: hasImage ? 200 : 120,
      decoration: BoxDecoration(
        color: hasImage ? AppColors.offWhite : AppColors.offWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasImage ? AppColors.vibrantPurple : AppColors.lightGray,
          width: hasImage ? 2 : 1,
        ),
      ),
      child: hasImage ? _buildImagePreview() : _buildUploadPrompt(),
    );
  }

  Widget _buildUploadPrompt() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isUploading ? null : _uploadImage,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: AppColors.coolGray,
              ),
              const SizedBox(height: AppSpacing.spacingM),
              Text(
                _isUploading ? 'Uploading...' : 'Upload Image',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.coolGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingXS),
              Text(
                'Optional - Add visual context',
                style: AppTextStyles.caption,
              ),
              if (_isUploading) ...[
                const SizedBox(height: AppSpacing.spacingM),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.vibrantPurple,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ScaleTransition(
            scale: _animationController.drive(
              CurveTween(curve: AppAnimations.elastic),
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: AppColors.lightGray,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 60, color: AppColors.coolGray),
                    const SizedBox(height: AppSpacing.spacingM),
                    Text(
                      'Image Preview',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.coolGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.spacingS,
          right: AppSpacing.spacingS,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowDark.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _uploadImage,
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.vibrantPurple,
                    size: 20,
                  ),
                  tooltip: 'Change image',
                ),
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowDark.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _removeImage,
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.coralRed,
                    size: 20,
                  ),
                  tooltip: 'Remove image',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
