import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_animations.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/navigation/app_navigation_bar.dart';
import '../../../../shared/widgets/layout/page_layout.dart';
import '../../../../core/navigation/route_constants.dart';
import '../widgets/avatar_upload_widget.dart';
import '../widgets/profile_field_widget.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

/// Edit profile page with comprehensive form and avatar upload
/// Kahoot-style engaging design with smooth animations and validation
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  File? _selectedAvatarImage;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeFormData();
    _setupChangeListeners();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );

    _animationController.forward();
  }

  void _initializeFormData() {
    final authState = ref.read(authStateProvider);
    final user = authState.value?.user;
    
    if (user != null) {
      _displayNameController.text = user.displayName ?? '';
      _usernameController.text = user.username ?? '';
      _emailController.text = user.email;
      _bioController.text = user.bio ?? '';
    }
  }

  void _setupChangeListeners() {
    _displayNameController.addListener(_onFieldChanged);
    _usernameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _displayNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes', style: AppTextStyles.sectionHeader),
        content: Text(
          'You have unsaved changes. Are you sure you want to leave?',
          style: AppTextStyles.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Stay',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.coolGray,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Leave',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement profile update logic with backend
      // This would typically involve:
      // 1. Upload avatar image if changed
      // 2. Update user profile data
      // 3. Update authentication state

      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.pureWhite),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        setState(() {
          _hasUnsavedChanges = false;
        });

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile: $e',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.pureWhite),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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

  void _onAvatarImageSelected(File image) {
    setState(() {
      _selectedAvatarImage = image;
      _hasUnsavedChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          title: Text(
            'Edit Profile',
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.pureWhite,
            ),
          ),
          backgroundColor: AppColors.vibrantPurple,
          foregroundColor: AppColors.pureWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                context.pop();
              }
            },
          ),
          actions: [
            if (_hasUnsavedChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: Text(
                  'Save',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(user),
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildContent(dynamic user) {
    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantPurple),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.spacingL),

            // Avatar Upload Section
            _buildAvatarSection(user),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Form Fields
            _buildFormFields(),

            const SizedBox(height: AppSpacing.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(dynamic user) {
    return Container(
      padding: AppSpacing.allL,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Profile Photo',
            style: AppTextStyles.sectionHeader.copyWith(
              fontSize: 20,
            ),
          ),

          const SizedBox(height: AppSpacing.spacingL),

          AvatarUploadWidget(
            currentImageUrl: user.photoURL,
            onImageSelected: _onAvatarImageSelected,
            size: 120,
            fallbackText: user.displayName?.isNotEmpty == true
                ? user.displayName[0].toUpperCase()
                : user.email[0].toUpperCase(),
          ),

          const SizedBox(height: AppSpacing.spacingM),

          Text(
            'Tap to change your profile photo',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: AppSpacing.allL,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: AppTextStyles.sectionHeader.copyWith(
              fontSize: 20,
            ),
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Display Name
          DisplayNameFieldWidget(
            controller: _displayNameController,
            onChanged: (_) => _onFieldChanged(),
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Username
          UsernameFieldWidget(
            controller: _usernameController,
            onChanged: (_) => _onFieldChanged(),
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Email
          EmailFieldWidget(
            controller: _emailController,
            isEditable: false, // Email typically can't be changed directly
            onChanged: (_) => _onFieldChanged(),
          ),

          const SizedBox(height: AppSpacing.spacingL),

          // Bio
          BioFieldWidget(
            controller: _bioController,
            onChanged: (_) => _onFieldChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.spacingL,
        right: AppSpacing.spacingL,
        top: AppSpacing.spacingM,
        bottom: AppSpacing.spacingL + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) {
                  context.pop();
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingM),
                side: BorderSide(color: AppColors.coolGray),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.coolGray,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.spacingM),

          Expanded(
            flex: 2,
            child: PrimaryButton(
              text: 'Save Changes',
              onPressed: _hasUnsavedChanges ? _saveProfile : null,
              isLoading: _isLoading,
              backgroundColor: _hasUnsavedChanges
                  ? AppColors.vibrantPurple
                  : AppColors.disabled,
            ),
          ),
        ],
      ),
    );
  }
}