import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase/firebase_core_config.dart';
import '../utils/logger.dart';

/// SharedPreferences provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  try {
    AppLogger.info('Initializing SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    AppLogger.info('SharedPreferences initialization completed successfully');
    return prefs;
  } catch (e, stackTrace) {
    AppLogger.error('SharedPreferences initialization failed', e, stackTrace);
    throw Exception('Failed to initialize SharedPreferences: ${e.toString()}');
  }
});

/// Firebase initialization provider
final firebaseInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    AppLogger.info('Initializing Firebase...');
    await FirebaseCoreConfig.initialize();
    AppLogger.info('Firebase initialization completed successfully');
    return true;
  } catch (e, stackTrace) {
    AppLogger.error('Firebase initialization failed', e, stackTrace);
    throw Exception('Failed to initialize Firebase: ${e.toString()}');
  }
});

/// App initialization provider - coordinates all startup tasks
final appInitializationProvider = FutureProvider<AppInitializationState>((
  ref,
) async {
  try {
    AppLogger.info('Starting app initialization...');

    // Initialize Firebase first
    final firebaseInitialized = await ref.read(
      firebaseInitializationProvider.future,
    );

    if (!firebaseInitialized) {
      throw Exception('Firebase initialization failed');
    }

    // Additional initialization tasks can be added here
    // - Remote config setup
    // - Analytics initialization
    // - Crash reporting setup
    // - Feature flags loading

    AppLogger.info('App initialization completed successfully');

    return const AppInitializationState.completed();
  } catch (e, stackTrace) {
    AppLogger.error('App initialization failed', e, stackTrace);
    return AppInitializationState.error(
      'Failed to initialize app: ${e.toString()}',
    );
  }
});

/// App lifecycle provider for managing app state
final appLifecycleProvider =
    StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>((ref) {
      return AppLifecycleNotifier();
    });

/// App lifecycle notifier
class AppLifecycleNotifier extends StateNotifier<AppLifecycleState> {
  AppLifecycleNotifier() : super(AppLifecycleState.inactive);

  void onAppResumed() {
    AppLogger.info('App resumed');
    state = AppLifecycleState.resumed;
  }

  void onAppPaused() {
    AppLogger.info('App paused');
    state = AppLifecycleState.paused;
  }

  void onAppInactive() {
    AppLogger.info('App inactive');
    state = AppLifecycleState.inactive;
  }

  void onAppDetached() {
    AppLogger.info('App detached');
    state = AppLifecycleState.detached;
  }

  void onAppHidden() {
    AppLogger.info('App hidden');
    state = AppLifecycleState.hidden;
  }
}

/// App initialization state
sealed class AppInitializationState {
  const AppInitializationState();

  const factory AppInitializationState.loading() = _LoadingState;
  const factory AppInitializationState.completed() = _CompletedState;
  const factory AppInitializationState.error(String message) = _ErrorState;
}

class _LoadingState extends AppInitializationState {
  const _LoadingState();
}

class _CompletedState extends AppInitializationState {
  const _CompletedState();
}

class _ErrorState extends AppInitializationState {
  final String message;
  const _ErrorState(this.message);
}

/// App lifecycle state
enum AppLifecycleState { resumed, paused, inactive, detached, hidden }

/// Global error handler provider
final globalErrorHandlerProvider = Provider<GlobalErrorHandler>((ref) {
  return GlobalErrorHandler();
});

/// Global error handler
class GlobalErrorHandler {
  void handleError(Object error, StackTrace stackTrace, String context) {
    AppLogger.error('Global error in $context', error, stackTrace);

    // Here you could add:
    // - Crash reporting (Firebase Crashlytics)
    // - User notifications
    // - Analytics tracking
    // - Error recovery logic
  }

  void handleAuthError(Object error, StackTrace stackTrace) {
    handleError(error, stackTrace, 'Authentication');

    // Additional auth-specific error handling
    // - Force logout on certain errors
    // - Show auth-specific error messages
    // - Navigate to login screen
  }

  void handleNetworkError(Object error, StackTrace stackTrace) {
    handleError(error, stackTrace, 'Network');

    // Network-specific error handling
    // - Show offline indicator
    // - Queue failed requests
    // - Implement retry logic
  }

  void handleFirestoreError(Object error, StackTrace stackTrace) {
    handleError(error, stackTrace, 'Firestore');

    // Firestore-specific error handling
    // - Handle permission errors
    // - Manage offline state
    // - Implement data sync
  }
}

/// Connection status provider
final connectionStatusProvider =
    StateNotifierProvider<ConnectionStatusNotifier, ConnectionStatus>((ref) {
      return ConnectionStatusNotifier();
    });

/// Connection status notifier
class ConnectionStatusNotifier extends StateNotifier<ConnectionStatus> {
  ConnectionStatusNotifier() : super(ConnectionStatus.online) {
    _checkInitialConnection();
  }

  void _checkInitialConnection() {
    // Initial connection check
    // You could implement actual network checking here
    state = ConnectionStatus.online;
  }

  void setOnline() {
    if (state != ConnectionStatus.online) {
      AppLogger.info('Connection restored');
      state = ConnectionStatus.online;
    }
  }

  void setOffline() {
    if (state != ConnectionStatus.offline) {
      AppLogger.warning('Connection lost');
      state = ConnectionStatus.offline;
    }
  }

  void setConnecting() {
    AppLogger.info('Connecting...');
    state = ConnectionStatus.connecting;
  }
}

/// Connection status
enum ConnectionStatus { online, offline, connecting }

/// Extensions for state checking
extension AppInitializationStateX on AppInitializationState {
  bool get isLoading => this is _LoadingState;
  bool get isCompleted => this is _CompletedState;
  bool get hasError => this is _ErrorState;

  String? get errorMessage => switch (this) {
    _ErrorState(message: final message) => message,
    _ => null,
  };
}

extension ConnectionStatusX on ConnectionStatus {
  bool get isOnline => this == ConnectionStatus.online;
  bool get isOffline => this == ConnectionStatus.offline;
  bool get isConnecting => this == ConnectionStatus.connecting;

  String get displayName => switch (this) {
    ConnectionStatus.online => 'Online',
    ConnectionStatus.offline => 'Offline',
    ConnectionStatus.connecting => 'Connecting...',
  };
}

extension AppLifecycleStateX on AppLifecycleState {
  bool get isActive => this == AppLifecycleState.resumed;
  bool get isInactive => this == AppLifecycleState.inactive;
  bool get isPaused => this == AppLifecycleState.paused;
  bool get isDetached => this == AppLifecycleState.detached;
  bool get isHidden => this == AppLifecycleState.hidden;
}
