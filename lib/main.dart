import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/firebase/firebase_core_config.dart';
import 'core/utils/logger.dart';
import 'core/navigation/navigation.dart';
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
    );
  }
}
