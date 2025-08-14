/// Base widget utilities and abstractions for the application
/// This barrel file exports all base widget functionality
library;

// Base widget abstractions
export 'base_widget.dart'
    hide ScreenSize; // ScreenSize exported from responsive_builder.dart

// Animation management
export 'animation_manager.dart';
export 'animated_state_manager.dart';

// Responsive design
export 'responsive_builder.dart';

// Widget composition patterns
export 'widget_composition.dart';

// Performance monitoring
export 'performance_monitor.dart';
