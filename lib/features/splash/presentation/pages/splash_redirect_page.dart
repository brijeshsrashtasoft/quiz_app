import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/route_constants.dart';
import '../../../../core/utils/logger.dart';

/// Quick splash redirect page that immediately navigates based on auth state
class SplashRedirectPage extends ConsumerStatefulWidget {
  const SplashRedirectPage({super.key});

  @override
  ConsumerState<SplashRedirectPage> createState() => _SplashRedirectPageState();
}

class _SplashRedirectPageState extends ConsumerState<SplashRedirectPage> {
  @override
  void initState() {
    super.initState();
    // Navigate immediately after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNavigation();
    });
  }

  Future<void> _handleNavigation() async {
    try {
      AppLogger.info('SplashRedirectPage: Starting navigation check');

      // For test mode, immediately go to home without waiting for auth
      if (mounted) {
        AppLogger.info('SplashRedirectPage: Navigating to home (test mode)');
        context.go(RouteConstants.home);
      }
    } catch (e) {
      AppLogger.error('SplashRedirectPage navigation error', e);
      // On any error, go to home
      if (mounted) {
        context.go(RouteConstants.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
