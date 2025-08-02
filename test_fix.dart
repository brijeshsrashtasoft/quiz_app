import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/features/quiz_creation/presentation/pages/quiz_creation_page.dart';
import 'lib/shared/providers/firebase_providers.dart';

/// Quick test to verify quiz creation page body renders
void main() {
  runApp(
    ProviderScope(
      overrides: [
        // Override user ID provider to avoid Firebase dependency
        currentUserIdProvider.overrideWith((ref) => 'test_user_123'),
      ],
      child: MaterialApp(
        title: 'Quiz Body Test',
        home: const QuizCreationPage(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
