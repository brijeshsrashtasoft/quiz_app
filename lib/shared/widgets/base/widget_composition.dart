import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base component interface for composable widgets
abstract class Component {
  Widget build(BuildContext context);
}

/// Composite widget that can contain multiple components
class CompositeWidget extends StatelessWidget {
  final List<Component> components;
  final Widget Function(BuildContext context, List<Widget> children)? builder;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const CompositeWidget({
    super.key,
    required this.components,
    this.builder,
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    final children = components.map((c) => c.build(context)).toList();
    
    if (builder != null) {
      return builder!(context, children);
    }

    if (direction == Axis.horizontal) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(children, spacing, Axis.horizontal),
      );
    } else {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(children, spacing, Axis.vertical),
      );
    }
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing, Axis direction) {
    if (spacing == 0 || children.isEmpty) return children;
    
    final spacer = direction == Axis.horizontal
        ? SizedBox(width: spacing)
        : SizedBox(height: spacing);
    
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(spacer);
      }
    }
    return result;
  }
}

/// Decorator pattern for adding behavior to widgets
abstract class WidgetDecorator extends StatelessWidget {
  final Widget child;

  const WidgetDecorator({
    super.key,
    required this.child,
  });

  Widget decorate(BuildContext context, Widget child);

  @override
  Widget build(BuildContext context) {
    return decorate(context, child);
  }
}

/// Padding decorator
class PaddingDecorator extends WidgetDecorator {
  final EdgeInsetsGeometry padding;

  const PaddingDecorator({
    super.key,
    required super.child,
    required this.padding,
  });

  @override
  Widget decorate(BuildContext context, Widget child) {
    return Padding(padding: padding, child: child);
  }
}

/// Animation decorator
class AnimationDecorator extends WidgetDecorator {
  final Duration duration;
  final Curve curve;
  final Widget Function(BuildContext context, Widget child, Animation<double> animation) builder;

  const AnimationDecorator({
    super.key,
    required super.child,
    required this.duration,
    this.curve = Curves.easeInOut,
    required this.builder,
  });

  @override
  Widget decorate(BuildContext context, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, _) => builder(context, child, 
        AlwaysStoppedAnimation(value)),
    );
  }
}

/// Theme decorator
class ThemeDecorator extends WidgetDecorator {
  final ThemeData? theme;
  final Widget Function(BuildContext context, Widget child, ThemeData theme)? builder;

  const ThemeDecorator({
    super.key,
    required super.child,
    this.theme,
    this.builder,
  });

  @override
  Widget decorate(BuildContext context, Widget child) {
    if (builder != null) {
      return builder!(context, child, Theme.of(context));
    }
    
    if (theme != null) {
      return Theme(data: theme!, child: child);
    }
    
    return child;
  }
}

/// Gesture decorator
class GestureDecorator extends WidgetDecorator {
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final HitTestBehavior behavior;

  const GestureDecorator({
    super.key,
    required super.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  Widget decorate(BuildContext context, Widget child) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      behavior: behavior,
      child: child,
    );
  }
}

/// State decorator for adding state management
class StateDecorator<T> extends ConsumerWidget {
  final Widget child;
  final ProviderListenable<T> provider;
  final Widget Function(BuildContext context, T value, Widget child) builder;

  const StateDecorator({
    super.key,
    required this.child,
    required this.provider,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(provider);
    return builder(context, value, child);
  }
}

/// Builder pattern for complex widget construction
class WidgetBuilder {
  final List<WidgetDecorator Function(Widget)> _decorators = [];
  Widget? _child;

  WidgetBuilder child(Widget child) {
    _child = child;
    return this;
  }

  WidgetBuilder padding(EdgeInsetsGeometry padding) {
    _decorators.add((child) => PaddingDecorator(padding: padding, child: child));
    return this;
  }

  WidgetBuilder animate({
    required Duration duration,
    Curve curve = Curves.easeInOut,
    required Widget Function(BuildContext, Widget, Animation<double>) builder,
  }) {
    _decorators.add((child) => AnimationDecorator(
      duration: duration,
      curve: curve,
      builder: builder,
      child: child,
    ));
    return this;
  }

  WidgetBuilder theme(ThemeData theme) {
    _decorators.add((child) => ThemeDecorator(theme: theme, child: child));
    return this;
  }

  WidgetBuilder gesture({
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    VoidCallback? onLongPress,
  }) {
    _decorators.add((child) => GestureDecorator(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: child,
    ));
    return this;
  }

  Widget build() {
    if (_child == null) {
      throw StateError('Child widget must be set before building');
    }

    Widget result = _child!;
    for (final decorator in _decorators.reversed) {
      result = decorator(result);
    }
    return result;
  }
}

/// Mixin for widgets that need composition capabilities
mixin CompositionMixin {
  /// Compose multiple widgets with a builder
  Widget compose({
    required List<Widget> children,
    Widget Function(BuildContext, List<Widget>)? builder,
    Axis direction = Axis.vertical,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return Builder(
      builder: (context) {
        if (builder != null) {
          return builder(context, children);
        }

        if (direction == Axis.horizontal) {
          return Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          );
        } else {
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          );
        }
      },
    );
  }

  /// Apply decorators to a widget
  Widget decorate(
    Widget child, {
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    Duration? animationDuration,
  }) {
    Widget result = child;

    if (padding != null) {
      result = Padding(padding: padding, child: result);
    }

    if (onTap != null) {
      result = GestureDetector(onTap: onTap, child: result);
    }

    if (animationDuration != null) {
      result = AnimatedContainer(
        duration: animationDuration,
        child: result,
      );
    }

    return result;
  }
}