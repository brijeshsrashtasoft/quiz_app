import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';

/// Avatar upload widget with camera/gallery options and image cropping
/// Kahoot-style engaging design with smooth animations
class AvatarUploadWidget extends StatefulWidget {
  final String? currentImageUrl;
  final Function(File) onImageSelected;
  final VoidCallback? onImageRemoved;
  final double size;
  final bool isEditable;
  final String fallbackText;

  const AvatarUploadWidget({
    super.key,
    this.currentImageUrl,
    required this.onImageSelected,
    this.onImageRemoved,
    this.size = 120,
    this.isEditable = true,
    this.fallbackText = 'U',
  });

  @override
  State<AvatarUploadWidget> createState() => _AvatarUploadWidgetState();
}

class _AvatarUploadWidgetState extends State<AvatarUploadWidget>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    if (!widget.isEditable) return;

    await _animationController.forward();
    await _animationController.reverse();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageSourceBottomSheet(
        onCameraSelected: () => _pickImage(ImageSource.camera),
        onGallerySelected: () => _pickImage(ImageSource.gallery),
        onRemoveSelected:
            widget.currentImageUrl != null || _selectedImage != null
            ? () => _removeImage()
            : null,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop(); // Close bottom sheet

    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        setState(() {
          _selectedImage = imageFile;
        });
        widget.onImageSelected(imageFile);
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeImage() {
    Navigator.of(context).pop(); // Close bottom sheet
    setState(() {
      _selectedImage = null;
    });
    
    // Call callback to remove image from server
    if (widget.onImageRemoved != null) {
      widget.onImageRemoved!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: _buildAvatarContainer(),
          ),
        );
      },
    );
  }

  Widget _buildAvatarContainer() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.purpleGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.pureWhite,
            border: Border.all(color: AppColors.pureWhite, width: 2),
          ),
          child: ClipOval(child: _buildAvatarContent()),
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (_isLoading) {
      return Container(
        color: AppColors.offWhite,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantPurple),
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(),
      );
    }

    if (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty) {
      return Image.network(
        widget.currentImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.offWhite,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.vibrantPurple,
                ),
                strokeWidth: 3,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(),
      );
    }

    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: AppColors.lightGray.withValues(alpha: 0.3),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            widget.fallbackText,
            style: AppTextStyles.gameTitle.copyWith(
              color: AppColors.vibrantPurple,
              fontSize: widget.size * 0.4,
            ),
          ),
          if (widget.isEditable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: widget.size * 0.25,
                height: widget.size * 0.25,
                decoration: BoxDecoration(
                  color: AppColors.vibrantPurple,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.pureWhite, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.pureWhite,
                  size: widget.size * 0.12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bottom sheet for image source selection
class _ImageSourceBottomSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;
  final VoidCallback? onRemoveSelected;

  const _ImageSourceBottomSheet({
    required this.onCameraSelected,
    required this.onGallerySelected,
    this.onRemoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.allM,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.spacingM),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: AppSpacing.horizontalL,
            child: Text(
              'Select Image Source',
              style: AppTextStyles.sectionHeader,
            ),
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Options
          _buildOption(
            icon: Icons.camera_alt,
            title: 'Camera',
            subtitle: 'Take a new photo',
            color: AppColors.mintGreen,
            onTap: onCameraSelected,
          ),

          _buildOption(
            icon: Icons.photo_library,
            title: 'Gallery',
            subtitle: 'Choose from gallery',
            color: AppColors.turquoise,
            onTap: onGallerySelected,
          ),

          if (onRemoveSelected != null)
            _buildOption(
              icon: Icons.delete,
              title: 'Remove Photo',
              subtitle: 'Use default avatar',
              color: AppColors.coralRed,
              onTap: onRemoveSelected!,
            ),

          const SizedBox(height: AppSpacing.spacingL),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: AppSpacing.allM,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),

              const SizedBox(width: AppSpacing.spacingM),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.coolGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
