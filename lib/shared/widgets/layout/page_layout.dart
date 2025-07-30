import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import 'responsive_layout.dart';

/// Standard page layout component with consistent structure
/// Reference: docs/ui_guideline.md - Layout System
class PageLayout extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showAppBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const PageLayout({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showAppBar = true,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.offWhite,
      appBar: showAppBar ? (appBar ?? _buildDefaultAppBar(context)) : null,
      body: ResponsiveSafeArea(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  PreferredSizeWidget? _buildDefaultAppBar(BuildContext context) {
    if (title == null && (actions == null || actions!.isEmpty)) {
      return null;
    }

    return AppBar(
      title: title != null ? Text(title!) : null,
      actions: actions,
      backgroundColor: AppColors.pureWhite,
      foregroundColor: AppColors.charcoal,
      elevation: 0,
      centerTitle: true,
    );
  }
}

/// AppScaffold alias for consistent usage across the app
typedef AppScaffold = Scaffold;

/// Loading page layout with spinner and optional message
class LoadingPageLayout extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? spinnerColor;

  const LoadingPageLayout({
    super.key,
    this.message,
    this.backgroundColor,
    this.spinnerColor,
  });

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      showAppBar: false,
      backgroundColor: backgroundColor ?? AppColors.offWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                spinnerColor ?? AppColors.vibrantPurple,
              ),
            ),
            if (message != null) ...[
              SizedBox(height: AppSpacing.spacingL),
              Text(
                message!,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.coolGray),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error page layout with retry functionality
class ErrorPageLayout extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final IconData? icon;

  const ErrorPageLayout({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryButtonText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      showAppBar: false,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: AppColors.coolGray,
              ),
              SizedBox(height: AppSpacing.spacingL),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: AppColors.charcoal),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.spacingM),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.coolGray),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                SizedBox(height: AppSpacing.spacingL),
                ElevatedButton(
                  onPressed: onRetry,
                  child: Text(retryButtonText ?? 'Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state page layout
class EmptyStateLayout extends StatelessWidget {
  final String title;
  final String message;
  final Widget? action;
  final IconData? icon;
  final String? imagePath;

  const EmptyStateLayout({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.icon,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(imagePath!, width: 120, height: 120)
            else
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 64,
                color: AppColors.coolGray,
              ),
            SizedBox(height: AppSpacing.spacingL),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.charcoal),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.spacingM),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: AppSpacing.spacingL),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
