import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State manager for animated components
class AnimatedStateManager<T> extends ChangeNotifier {
  T _state;
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Animation> _animations = {};
  final Duration defaultDuration;

  AnimatedStateManager({
    required T initialState,
    this.defaultDuration = const Duration(milliseconds: 300),
  }) : _state = initialState;

  /// Current state
  T get state => _state;

  /// Update state and notify listeners
  void updateState(T newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Register an animation controller
  void registerController(String key, AnimationController controller) {
    _controllers[key] = controller;
  }

  /// Register an animation
  void registerAnimation<A>(String key, Animation<A> animation) {
    _animations[key] = animation;
  }

  /// Get controller by key
  AnimationController? getController(String key) => _controllers[key];

  /// Get animation by key
  Animation<A>? getAnimation<A>(String key) =>
      _animations[key] as Animation<A>?;

  /// Trigger animation with state change
  Future<void> animateToState(
    T newState,
    String animationKey, {
    bool reverse = false,
  }) async {
    final controller = _controllers[animationKey];
    if (controller != null) {
      if (reverse) {
        await controller.reverse();
      } else {
        await controller.forward();
      }
    }
    updateState(newState);
  }

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

/// Provider for animated state managers
final animatedStateManagerProvider =
    Provider.family<
      AnimatedStateManager<dynamic>,
      AnimatedStateConfig<dynamic>
    >((ref, config) {
      final manager = AnimatedStateManager<dynamic>(
        initialState: config.initialState,
        defaultDuration: config.defaultDuration,
      );
      ref.onDispose(() => manager.dispose());
      return manager;
    });

/// Configuration for animated state manager
class AnimatedStateConfig<T> {
  final T initialState;
  final Duration defaultDuration;

  const AnimatedStateConfig({
    required this.initialState,
    this.defaultDuration = const Duration(milliseconds: 300),
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimatedStateConfig<T> &&
          runtimeType == other.runtimeType &&
          initialState == other.initialState &&
          defaultDuration == other.defaultDuration;

  @override
  int get hashCode => initialState.hashCode ^ defaultDuration.hashCode;
}

/// Base class for animated stateful widgets
abstract class AnimatedStatefulWidget<T> extends ConsumerStatefulWidget {
  final T initialState;
  final Duration animationDuration;

  const AnimatedStatefulWidget({
    super.key,
    required this.initialState,
    this.animationDuration = const Duration(milliseconds: 300),
  });
}

/// Base state for animated stateful widgets
abstract class AnimatedState<W extends AnimatedStatefulWidget<T>, T>
    extends ConsumerState<W>
    with TickerProviderStateMixin {
  late final AnimatedStateManager<T> stateManager;
  final Map<String, AnimationController> _localControllers = {};

  @override
  void initState() {
    super.initState();
    stateManager = AnimatedStateManager<T>(
      initialState: widget.initialState,
      defaultDuration: widget.animationDuration,
    );
    setupAnimations();
  }

  /// Override to setup animations
  void setupAnimations();

  /// Create and register an animation controller
  AnimationController createController({
    required String key,
    Duration? duration,
    double initialValue = 0.0,
    double lowerBound = 0.0,
    double upperBound = 1.0,
  }) {
    final controller = AnimationController(
      vsync: this,
      duration: duration ?? widget.animationDuration,
      value: initialValue,
      lowerBound: lowerBound,
      upperBound: upperBound,
    );
    _localControllers[key] = controller;
    stateManager.registerController(key, controller);
    return controller;
  }

  /// Create and register an animation
  Animation<U> createAnimation<U>({
    required String key,
    required String controllerKey,
    required Animatable<U> animatable,
  }) {
    final controller = _localControllers[controllerKey];
    if (controller == null) {
      throw ArgumentError('Controller with key $controllerKey not found');
    }
    final animation = animatable.animate(controller);
    stateManager.registerAnimation(key, animation);
    return animation;
  }

  /// Animate to a new state
  Future<void> animateToState(
    T newState, {
    String? animationKey,
    bool reverse = false,
  }) async {
    if (animationKey != null) {
      await stateManager.animateToState(
        newState,
        animationKey,
        reverse: reverse,
      );
    } else {
      stateManager.updateState(newState);
    }
  }

  @override
  void dispose() {
    for (final controller in _localControllers.values) {
      controller.dispose();
    }
    stateManager.dispose();
    super.dispose();
  }
}

/// Mixin for widgets that need animated state transitions
mixin AnimatedTransitionMixin<T extends StatefulWidget> on State<T> {
  final Map<String, AnimationController> _transitionControllers = {};
  final Map<String, Animation> _transitions = {};

  /// Create a transition animation
  Animation<U> createTransition<U>({
    required String key,
    required Duration duration,
    required Animatable<U> animatable,
    required TickerProvider vsync,
  }) {
    final controller = AnimationController(vsync: vsync, duration: duration);
    _transitionControllers[key] = controller;

    final animation = animatable.animate(controller);
    _transitions[key] = animation;

    return animation;
  }

  /// Trigger a transition
  Future<void> triggerTransition(String key, {bool reverse = false}) async {
    final controller = _transitionControllers[key];
    if (controller != null) {
      if (reverse) {
        await controller.reverse();
      } else {
        await controller.forward();
      }
    }
  }

  /// Get transition animation
  Animation<U>? getTransition<U>(String key) {
    return _transitions[key] as Animation<U>?;
  }

  void disposeTransitions() {
    for (final controller in _transitionControllers.values) {
      controller.dispose();
    }
    _transitionControllers.clear();
    _transitions.clear();
  }
}

/// Animated value notifier for smooth value transitions
class AnimatedValueNotifier<T> extends ValueNotifier<T> {
  final Duration duration;
  final Curve curve;
  AnimationController? _controller;
  Animation<T>? _animation;

  AnimatedValueNotifier(
    super.value, {
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  /// Animate to a new value
  Future<void> animateTo(
    T newValue, {
    required TickerProvider vsync,
    Duration? customDuration,
    Curve? customCurve,
  }) async {
    if (value == newValue) return;

    _controller?.dispose();
    _controller = AnimationController(
      vsync: vsync,
      duration: customDuration ?? duration,
    );

    _animation = Tween<T>(begin: value, end: newValue).animate(
      CurvedAnimation(parent: _controller!, curve: customCurve ?? curve),
    );

    _animation!.addListener(() {
      value = _animation!.value;
    });

    await _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
