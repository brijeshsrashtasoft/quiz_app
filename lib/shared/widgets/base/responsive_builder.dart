import 'package:flutter/material.dart';

/// Responsive builder widget for creating adaptive layouts
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveInfo info) builder;
  final ResponsiveBreakpoints? breakpoints;

  const ResponsiveBuilder({super.key, required this.builder, this.breakpoints});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final info = ResponsiveInfo(
          screenSize: _getScreenSize(constraints.maxWidth),
          screenWidth: constraints.maxWidth,
          screenHeight: constraints.maxHeight,
          orientation: MediaQuery.of(context).orientation,
          devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
          breakpoints: breakpoints ?? ResponsiveBreakpoints.defaults,
        );
        return builder(context, info);
      },
    );
  }

  ScreenSize _getScreenSize(double width) {
    final bp = breakpoints ?? ResponsiveBreakpoints.defaults;
    if (width < bp.small) return ScreenSize.small;
    if (width < bp.medium) return ScreenSize.medium;
    if (width < bp.large) return ScreenSize.large;
    return ScreenSize.extraLarge;
  }
}

/// Responsive layout widget with predefined layouts for different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget small;
  final Widget? medium;
  final Widget? large;
  final Widget? extraLarge;
  final ResponsiveBreakpoints? breakpoints;

  const ResponsiveLayout({
    super.key,
    required this.small,
    this.medium,
    this.large,
    this.extraLarge,
    this.breakpoints,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      breakpoints: breakpoints,
      builder: (context, info) {
        switch (info.screenSize) {
          case ScreenSize.small:
            return small;
          case ScreenSize.medium:
            return medium ?? small;
          case ScreenSize.large:
            return large ?? medium ?? small;
          case ScreenSize.extraLarge:
            return extraLarge ?? large ?? medium ?? small;
        }
      },
    );
  }
}

/// Responsive value widget for adaptive values
class ResponsiveValue<T> extends StatelessWidget {
  final T small;
  final T? medium;
  final T? large;
  final T? extraLarge;
  final Widget Function(BuildContext context, T value) builder;
  final ResponsiveBreakpoints? breakpoints;

  const ResponsiveValue({
    super.key,
    required this.small,
    this.medium,
    this.large,
    this.extraLarge,
    required this.builder,
    this.breakpoints,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      breakpoints: breakpoints,
      builder: (context, info) {
        final value = _getValue(info.screenSize);
        return builder(context, value);
      },
    );
  }

  T _getValue(ScreenSize size) {
    switch (size) {
      case ScreenSize.small:
        return small;
      case ScreenSize.medium:
        return medium ?? small;
      case ScreenSize.large:
        return large ?? medium ?? small;
      case ScreenSize.extraLarge:
        return extraLarge ?? large ?? medium ?? small;
    }
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int smallColumns;
  final int? mediumColumns;
  final int? largeColumns;
  final int? extraLargeColumns;
  final double spacing;
  final double runSpacing;
  final ResponsiveBreakpoints? breakpoints;

  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.smallColumns,
    this.mediumColumns,
    this.largeColumns,
    this.extraLargeColumns,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.breakpoints,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      breakpoints: breakpoints,
      builder: (context, info) {
        final columns = _getColumns(info.screenSize);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  int _getColumns(ScreenSize size) {
    switch (size) {
      case ScreenSize.small:
        return smallColumns;
      case ScreenSize.medium:
        return mediumColumns ?? smallColumns;
      case ScreenSize.large:
        return largeColumns ?? mediumColumns ?? smallColumns;
      case ScreenSize.extraLarge:
        return extraLargeColumns ??
            largeColumns ??
            mediumColumns ??
            smallColumns;
    }
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets small;
  final EdgeInsets? medium;
  final EdgeInsets? large;
  final EdgeInsets? extraLarge;
  final ResponsiveBreakpoints? breakpoints;

  const ResponsivePadding({
    super.key,
    required this.child,
    required this.small,
    this.medium,
    this.large,
    this.extraLarge,
    this.breakpoints,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveValue<EdgeInsets>(
      small: small,
      medium: medium,
      large: large,
      extraLarge: extraLarge,
      breakpoints: breakpoints,
      builder: (context, padding) => Padding(padding: padding, child: child),
    );
  }
}

/// Responsive information
class ResponsiveInfo {
  final ScreenSize screenSize;
  final double screenWidth;
  final double screenHeight;
  final Orientation orientation;
  final double devicePixelRatio;
  final ResponsiveBreakpoints breakpoints;

  const ResponsiveInfo({
    required this.screenSize,
    required this.screenWidth,
    required this.screenHeight,
    required this.orientation,
    required this.devicePixelRatio,
    required this.breakpoints,
  });

  /// Check if current screen is at least the specified size
  bool isAtLeast(ScreenSize size) {
    return screenSize.index >= size.index;
  }

  /// Check if current screen is at most the specified size
  bool isAtMost(ScreenSize size) {
    return screenSize.index <= size.index;
  }

  /// Get responsive value based on screen size
  T value<T>({required T small, T? medium, T? large, T? extraLarge}) {
    switch (screenSize) {
      case ScreenSize.small:
        return small;
      case ScreenSize.medium:
        return medium ?? small;
      case ScreenSize.large:
        return large ?? medium ?? small;
      case ScreenSize.extraLarge:
        return extraLarge ?? large ?? medium ?? small;
    }
  }
}

/// Screen size enum
enum ScreenSize { small, medium, large, extraLarge }

/// Responsive breakpoints
class ResponsiveBreakpoints {
  final double small;
  final double medium;
  final double large;

  const ResponsiveBreakpoints({
    required this.small,
    required this.medium,
    required this.large,
  });

  /// Default breakpoints following Material Design guidelines
  static const ResponsiveBreakpoints defaults = ResponsiveBreakpoints(
    small: 600, // Mobile
    medium: 1024, // Tablet
    large: 1440, // Desktop
  );

  /// Compact breakpoints for smaller screens
  static const ResponsiveBreakpoints compact = ResponsiveBreakpoints(
    small: 480,
    medium: 768,
    large: 1200,
  );

  /// Expanded breakpoints for larger screens
  static const ResponsiveBreakpoints expanded = ResponsiveBreakpoints(
    small: 768,
    medium: 1200,
    large: 1920,
  );
}
