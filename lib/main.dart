import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/firebase/firebase_core_config.dart';
import 'core/firebase/firebase_service_wrapper.dart';
import 'core/utils/logger.dart';
import 'core/utils/startup_performance.dart';
import 'core/navigation/navigation.dart';
import 'shared/theme/app_theme.dart';
import 'core/error_handling/global_error_handler.dart';

void main() async {
  // Mark app start time for performance monitoring
  StartupPerformance.markAppStart();

  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services asynchronously after app starts
  await _initializeServicesAsync();

  // Initialize global error handling first (lightweight)
  final globalErrorHandler = GlobalErrorHandler.instance;
  globalErrorHandler.initialize();

  // Run app immediately with async initialization
  runApp(const ProviderScope(child: QuizApp()));
}

/// Initialize services asynchronously without blocking app startup
Future<void> _initializeServicesAsync() async {
  try {
    final initStartTime = DateTime.now();

    // Initialize Firebase asynchronously with timeout
    await FirebaseCoreConfig.initialize().timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        AppLogger.warning('Firebase initialization timed out after 2 seconds');
        throw TimeoutException(
          'Firebase initialization timeout',
          const Duration(seconds: 2),
        );
      },
    );

    final initDuration = DateTime.now().difference(initStartTime);
    StartupPerformance.markFirebaseInit();

    AppLogger.info(
      'Firebase initialized successfully in ${initDuration.inMilliseconds}ms',
    );

    // Deep link service will be initialized on-demand by DeepLinkHandler
  } catch (e, stackTrace) {
    AppLogger.error('Service initialization failed', e, stackTrace);
    // Don't crash the app - services can retry later
    // App continues to work without Firebase services

    // Log Firebase status for debugging
    try {
      final FirebaseServiceWrapper serviceWrapper =
          FirebaseServiceWrapper.instance;
      AppLogger.info(serviceWrapper.getFirebaseStatus());
    } catch (statusError) {
      AppLogger.warning('Could not get Firebase status', statusError);
    }
  }
}

class QuizApp extends ConsumerStatefulWidget {
  const QuizApp({super.key});

  @override
  ConsumerState<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends ConsumerState<QuizApp> {
  @override
  void initState() {
    super.initState();
    // Mark first frame after app widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StartupPerformance.markFirstFrame();

      // Log performance summary after a brief delay to capture complete metrics
      Future.delayed(const Duration(milliseconds: 500), () {
        StartupPerformance.logSummary();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Quiz App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return DeepLinkHandler(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

/// Widget that handles deep links throughout the app lifecycle
class DeepLinkHandler extends ConsumerStatefulWidget {
  final Widget child;

  const DeepLinkHandler({super.key, required this.child});

  @override
  ConsumerState<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends ConsumerState<DeepLinkHandler> {
  bool _deepLinkInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize deep link service lazily after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDeepLinkService();
    });
  }

  Future<void> _initializeDeepLinkService() async {
    if (_deepLinkInitialized) return;

    try {
      await DeepLinkService.instance.initialize();
      _deepLinkInitialized = true;
      AppLogger.info('Deep link service initialized');
    } catch (e) {
      AppLogger.warning('Deep link initialization failed', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to deep link stream only if initialized
    if (_deepLinkInitialized) {
      ref.listen<AsyncValue<DeepLinkData>>(deepLinkStreamProvider, (
        previous,
        next,
      ) {
        next.whenData((deepLinkData) {
          debugPrint('DeepLinkHandler: Received deep link: $deepLinkData');

          // Handle deep link navigation immediately
          if (mounted) {
            DeepLinkService.instance.handleDeepLinkWithContext(
              context,
              deepLinkData,
            );
          }
        });
      });
    }

    return widget.child;
  }
}
