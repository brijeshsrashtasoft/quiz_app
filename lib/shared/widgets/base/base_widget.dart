import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base widget abstraction for all reusable components
/// Provides common functionality and patterns for widget composition
abstract class BaseWidget extends ConsumerWidget {
  const BaseWidget({super.key});

  /// Widget identifier for debugging and analytics
  String get widgetId;

  /// Whether this widget should rebuild on theme changes
  bool get rebuildOnThemeChange => true;

  /// Build the widget implementation
  Widget buildWidget(BuildContext context, WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBuilder(
      animation: rebuildOnThemeChange
          ? Theme.of(context)
          : const AlwaysStoppedAnimation(0),
      builder: (context, child) => buildWidget(context, ref),
    );
  }
}

/// Base stateful widget abstraction for widgets with internal state
abstract class BaseStatefulWidget extends ConsumerStatefulWidget {
  const BaseStatefulWidget({super.key});

  /// Widget identifier for debugging and analytics
  String get widgetId;
}

/// Base state abstraction for stateful widgets
abstract class BaseState<T extends BaseStatefulWidget> extends ConsumerState<T>
    with WidgetsBindingObserver {
  /// Whether this widget is currently mounted
  bool get isMounted => mounted;

  /// Safe setState that checks if widget is mounted
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    onDispose();
    super.dispose();
  }

  /// Override to handle initialization logic
  void onInit() {}

  /// Override to handle disposal logic
  void onDispose() {}

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
        break;
      case AppLifecycleState.paused:
        onPause();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  /// Called when app resumes
  void onResume() {}

  /// Called when app pauses
  void onPause() {}
}

/// Mixin for widgets that need animation controllers
mixin AnimationControllerMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin {
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Animation> _animations = {};

  /// Create and register an animation controller
  AnimationController createAnimationController({
    required String key,
    required Duration duration,
    Duration? reverseDuration,
    double initialValue = 0.0,
    double lowerBound = 0.0,
    double upperBound = 1.0,
  }) {
    final controller = AnimationController(
      vsync: this,
      duration: duration,
      reverseDuration: reverseDuration,
      value: initialValue,
      lowerBound: lowerBound,
      upperBound: upperBound,
    );
    _controllers[key] = controller;
    return controller;
  }

  /// Get a registered animation controller
  AnimationController? getController(String key) => _controllers[key];

  /// Create and register an animation
  Animation<T> createAnimation<T>({
    required String key,
    required String controllerKey,
    required Animatable<T> animatable,
  }) {
    final controller = _controllers[controllerKey];
    if (controller == null) {
      throw ArgumentError('Controller with key $controllerKey not found');
    }
    final animation = animatable.animate(controller);
    _animations[key] = animation;
    return animation;
  }

  /// Get a registered animation
  Animation<T>? getAnimation<T>(String key) =>
      _animations[key] as Animation<T>?;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _animations.clear();
    super.dispose();
  }
}

/// Mixin for responsive widgets
mixin ResponsiveMixin {
  /// Get the current screen size category
  ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return ScreenSize.small;
    if (width < 1200) return ScreenSize.medium;
    return ScreenSize.large;
  }

  /// Get the current orientation
  Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Build responsive widget based on screen size
  Widget buildResponsive(
    BuildContext context, {
    required Widget small,
    Widget? medium,
    Widget? large,
  }) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return small;
      case ScreenSize.medium:
        return medium ?? small;
      case ScreenSize.large:
        return large ?? medium ?? small;
    }
  }

  /// Get responsive value based on screen size
  T responsiveValue<T>(
    BuildContext context, {
    required T small,
    T? medium,
    T? large,
  }) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return small;
      case ScreenSize.medium:
        return medium ?? small;
      case ScreenSize.large:
        return large ?? medium ?? small;
    }
  }
}

/// Screen size categories for responsive design
enum ScreenSize {
  small, // < 600px (mobile)
  medium, // 600-1200px (tablet)
  large, // > 1200px (desktop)
}
