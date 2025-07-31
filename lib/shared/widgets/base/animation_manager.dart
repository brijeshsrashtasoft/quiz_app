import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Animation manager for centralized animation control
class AnimationManager {
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Animation> _animations = {};
  final Map<String, List<VoidCallback>> _listeners = {};
  final TickerProvider _vsync;

  AnimationManager({required TickerProvider vsync}) : _vsync = vsync;

  /// Register an animation controller
  AnimationController registerController({
    required String key,
    required Duration duration,
    Duration? reverseDuration,
    double initialValue = 0.0,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
  }) {
    if (_controllers.containsKey(key)) {
      throw ArgumentError('Controller with key $key already exists');
    }

    final controller = AnimationController(
      vsync: _vsync,
      duration: duration,
      reverseDuration: reverseDuration,
      value: initialValue,
      lowerBound: lowerBound,
      upperBound: upperBound,
      animationBehavior: animationBehavior,
    );

    _controllers[key] = controller;
    return controller;
  }

  /// Register an animation
  Animation<T> registerAnimation<T>({
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

  /// Get a controller by key
  AnimationController? getController(String key) => _controllers[key];

  /// Get an animation by key
  Animation<T>? getAnimation<T>(String key) =>
      _animations[key] as Animation<T>?;

  /// Play an animation forward
  Future<void> play(String controllerKey) async {
    final controller = _controllers[controllerKey];
    if (controller != null) {
      await controller.forward();
    }
  }

  /// Play an animation in reverse
  Future<void> reverse(String controllerKey) async {
    final controller = _controllers[controllerKey];
    if (controller != null) {
      await controller.reverse();
    }
  }

  /// Repeat an animation
  Future<void> repeat(String controllerKey, {bool reverse = false}) async {
    final controller = _controllers[controllerKey];
    if (controller != null) {
      controller.repeat(reverse: reverse);
    }
  }

  /// Stop an animation
  void stop(String controllerKey) {
    final controller = _controllers[controllerKey];
    if (controller != null) {
      controller.stop();
    }
  }

  /// Reset an animation to its initial value
  void reset(String controllerKey) {
    final controller = _controllers[controllerKey];
    if (controller != null) {
      controller.reset();
    }
  }

  /// Add a listener to an animation
  void addListener(String key, VoidCallback listener) {
    _listeners[key] ??= [];
    _listeners[key]!.add(listener);

    final controller = _controllers[key];
    controller?.addListener(listener);
  }

  /// Remove a listener from an animation
  void removeListener(String key, VoidCallback listener) {
    _listeners[key]?.remove(listener);

    final controller = _controllers[key];
    controller?.removeListener(listener);
  }

  /// Dispose all animations and controllers
  void dispose() {
    // Remove all listeners
    _listeners.forEach((key, listeners) {
      final controller = _controllers[key];
      if (controller != null) {
        for (final listener in listeners) {
          controller.removeListener(listener);
        }
      }
    });
    _listeners.clear();

    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _animations.clear();
  }

  /// Create a sequence of animations
  Future<void> sequence(List<AnimationSequenceItem> items) async {
    for (final item in items) {
      final controller = _controllers[item.controllerKey];
      if (controller != null) {
        if (item.delay != null) {
          await Future.delayed(item.delay!);
        }

        switch (item.action) {
          case AnimationAction.forward:
            await controller.forward();
            break;
          case AnimationAction.reverse:
            await controller.reverse();
            break;
          case AnimationAction.repeat:
            controller.repeat(reverse: item.reverse);
            if (item.duration != null) {
              await Future.delayed(item.duration!);
              controller.stop();
            }
            break;
          case AnimationAction.reset:
            controller.reset();
            break;
        }
      }
    }
  }

  /// Create parallel animations
  Future<void> parallel(List<AnimationParallelItem> items) async {
    final futures = <Future>[];

    for (final item in items) {
      final controller = _controllers[item.controllerKey];
      if (controller != null) {
        Future<void> animationFuture;

        switch (item.action) {
          case AnimationAction.forward:
            animationFuture = controller.forward();
            break;
          case AnimationAction.reverse:
            animationFuture = controller.reverse();
            break;
          case AnimationAction.repeat:
            controller.repeat(reverse: item.reverse);
            animationFuture = item.duration != null
                ? Future.delayed(item.duration!).then((_) => controller.stop())
                : Future.value();
            break;
          case AnimationAction.reset:
            controller.reset();
            animationFuture = Future.value();
            break;
        }

        if (item.delay != null) {
          futures.add(Future.delayed(item.delay!).then((_) => animationFuture));
        } else {
          futures.add(animationFuture);
        }
      }
    }

    await Future.wait(futures);
  }
}

/// Animation sequence item
class AnimationSequenceItem {
  final String controllerKey;
  final AnimationAction action;
  final Duration? delay;
  final Duration? duration;
  final bool reverse;

  const AnimationSequenceItem({
    required this.controllerKey,
    required this.action,
    this.delay,
    this.duration,
    this.reverse = false,
  });
}

/// Animation parallel item
class AnimationParallelItem extends AnimationSequenceItem {
  const AnimationParallelItem({
    required super.controllerKey,
    required super.action,
    super.delay,
    super.duration,
    super.reverse,
  });
}

/// Animation actions
enum AnimationAction { forward, reverse, repeat, reset }

/// Provider for animation manager
final animationManagerProvider =
    Provider.family<AnimationManager, TickerProvider>((ref, vsync) {
      final manager = AnimationManager(vsync: vsync);
      ref.onDispose(() => manager.dispose());
      return manager;
    });

/// Mixin for widgets that use animation manager
mixin AnimationManagerMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin {
  late final AnimationManager animationManager;

  @override
  void initState() {
    super.initState();
    animationManager = AnimationManager(vsync: this);
  }

  @override
  void dispose() {
    animationManager.dispose();
    super.dispose();
  }
}
