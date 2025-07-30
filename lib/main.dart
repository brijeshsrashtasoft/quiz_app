import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/firebase/firebase_core_config.dart';
import 'core/utils/logger.dart';
import 'core/navigation/navigation.dart';
import 'core/navigation/deep_link_service.dart';
import 'shared/theme/app_theme.dart';
import 'core/error_handling/global_error_handler.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error handling
  final globalErrorHandler = GlobalErrorHandler.instance;
  globalErrorHandler.initialize();

  // Run app in error-protected zone
  await globalErrorHandler.runInErrorZone(() async {
    try {
      // Initialize Firebase
      await FirebaseCoreConfig.initialize();
      AppLogger.info(
        'Application started successfully with Firebase initialized',
      );

      // Initialize deep link service
      await DeepLinkService.instance.initialize();
      AppLogger.info('Deep link service initialized successfully');

      // Run app with Riverpod
      runApp(const ProviderScope(child: QuizApp()));
    } catch (e, stackTrace) {
      AppLogger.fatal('Failed to initialize application', e, stackTrace);

      // Report initialization error through global handler
      globalErrorHandler.reportError(
        e,
        stackTrace,
        context: 'Application Initialization',
      );

      // Run app without Firebase in case of initialization failure
      runApp(const ProviderScope(child: QuizApp()));
    }
  });
}

class QuizApp extends ConsumerWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
  @override
  void initState() {
    super.initState();

    // Listen to deep link stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupDeepLinkListener();
    });
  }

  void _setupDeepLinkListener() {
    ref.listen<AsyncValue<DeepLinkData>>(deepLinkStreamProvider, (
      previous,
      next,
    ) {
      next.whenData((deepLinkData) {
        debugPrint('DeepLinkHandler: Received deep link: $deepLinkData');

        // Handle deep link navigation with context
        if (mounted) {
          DeepLinkService.instance.handleDeepLinkWithContext(
            context,
            deepLinkData,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
