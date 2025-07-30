import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';

/// Responsive layout component that adapts to different screen sizes
/// Reference: docs/ui_guideline.md - Responsive Design
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double tabletBreakpoint;
  final double desktopBreakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.tabletBreakpoint = 768,
    this.desktopBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= tabletBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Screen size utility class
class ScreenSize {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}

/// Responsive padding that adapts to screen size
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;

    if (ScreenSize.isDesktop(context)) {
      padding =
          desktopPadding ??
          tabletPadding ??
          mobilePadding ??
          EdgeInsets.all(AppSpacing.spacingL);
    } else if (ScreenSize.isTablet(context)) {
      padding =
          tabletPadding ?? mobilePadding ?? EdgeInsets.all(AppSpacing.spacingM);
    } else {
      padding = mobilePadding ?? EdgeInsets.all(AppSpacing.spacingM);
    }

    return Padding(padding: padding, child: child);
  }
}

/// Safe area wrapper with responsive padding
class ResponsiveSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const ResponsiveSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ResponsivePadding(
        mobilePadding: EdgeInsets.all(AppSpacing.spacingM),
        tabletPadding: EdgeInsets.all(AppSpacing.spacingL),
        desktopPadding: EdgeInsets.all(AppSpacing.spacingXL),
        child: child,
      ),
    );
  }
}
