import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_dimensions.dart';

/// Loading states specifically for navigation and route changes
/// Provides visual feedback during page transitions and data loading
class NavigationLoadingStates {
  NavigationLoadingStates._();

  /// Full screen loading overlay for major navigation changes
  static Widget fullScreenLoading({
    String? message,
    bool showLogo = true,
    Color? backgroundColor,
  }) {
    return Container(
      color: backgroundColor ?? AppColors.offWhite,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or brand element
            if (showLogo) ...[
              Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusL,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.quiz,
                      color: AppColors.pureWhite,
                      size: 40,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.1, 1.1),
                    duration: AppAnimations.longAnimation,
                    curve: AppAnimations.easeInOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.1, 1.1),
                    end: const Offset(1.0, 1.0),
                    duration: AppAnimations.longAnimation,
                    curve: AppAnimations.easeInOut,
                  ),
              const SizedBox(height: AppSpacing.spacingL),
            ],

            // Loading spinner
            SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.vibrantPurple,
                    ),
                    backgroundColor: AppColors.lightGray,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: const Duration(seconds: 1)),

            const SizedBox(height: AppSpacing.spacingL),

            // Loading message
            if (message != null)
              Text(
                    message,
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.coolGray,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: AppAnimations.mediumAnimation)
                  .then(delay: const Duration(milliseconds: 500))
                  .fadeOut(duration: AppAnimations.mediumAnimation),
          ],
        ),
      ),
    );
  }

  /// Shimmer loading for navigation content
  static Widget shimmerPageLoading({
    bool showAppBar = true,
    bool showBottomNav = true,
    int contentLines = 5,
  }) {
    return Column(
          children: [
            // App bar shimmer
            if (showAppBar)
              Container(
                height: AppDimensions.appBarHeight,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingM,
                ),
                color: AppColors.pureWhite,
                child: Row(
                  children: [
                    // Back button shimmer
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacingM),
                    // Title shimmer
                    Expanded(
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacingM),
                    // Action button shimmer
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),

            // Content shimmer
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPaddingAll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero section shimmer
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacingL),

                    // Content lines shimmer
                    ...List.generate(contentLines, (index) {
                      final width = index == contentLines - 1 ? 0.7 : 1.0;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < contentLines - 1
                              ? AppSpacing.spacingM
                              : 0,
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * width,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.spacingL),

                    // Button shimmer
                    Container(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonRadius,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom navigation shimmer
            if (showBottomNav)
              Container(
                height: AppDimensions.bottomNavHeight,
                color: AppColors.pureWhite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
          ],
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: AppColors.pureWhite.withOpacity(0.8),
        );
  }

  /// Navigation progress indicator
  static Widget navigationProgress({
    double? progress,
    String? currentStep,
    List<String>? steps,
  }) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            if (progress != null) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.lightGray,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.vibrantPurple,
                ),
                minHeight: 4,
              ),
              const SizedBox(height: AppSpacing.spacingS),
            ],

            // Current step
            if (currentStep != null)
              Text(
                currentStep,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.coolGray,
                ),
                textAlign: TextAlign.center,
              ),

            // Steps indicator
            if (steps != null && steps.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.spacingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final isActive =
                      progress != null &&
                      index < (progress * steps.length).floor();
                  return Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacingXS,
                    ),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.vibrantPurple
                          : AppColors.lightGray,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Inline loading state for content areas
  static Widget inlineLoading({String? message, bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(
        compact ? AppSpacing.spacingM : AppSpacing.spacingL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: compact ? 24 : 32,
            height: compact ? 24 : 32,
            child: CircularProgressIndicator(
              strokeWidth: compact ? 2 : 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.vibrantPurple,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(
              height: compact ? AppSpacing.spacingS : AppSpacing.spacingM,
            ),
            Text(
              message,
              style: compact ? AppTextStyles.caption : AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Skeleton loading for specific navigation elements
  static Widget navigationSkeleton() {
    return Container(
          height: AppDimensions.bottomNavHeight,
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              );
            }),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: AppColors.pureWhite.withOpacity(0.6),
        );
  }
}

/// Loading state provider widget
class NavigationLoadingProvider extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Widget? customLoadingWidget;

  const NavigationLoadingProvider({
    super.key,
    required this.child,
    this.isLoading = false,
    this.loadingMessage,
    this.customLoadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child:
                customLoadingWidget ??
                NavigationLoadingStates.fullScreenLoading(
                  message: loadingMessage,
                ),
          ),
      ],
    );
  }
}
