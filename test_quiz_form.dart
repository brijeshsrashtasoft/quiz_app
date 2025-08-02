import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/features/quiz_creation/presentation/widgets/quiz_metadata_form.dart';

void main() {
  runApp(const TestFormApp());
}

class TestFormApp extends StatelessWidget {
  const TestFormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Quiz Form Test',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Quiz Form Test'),
          ),
          body: const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: QuizMetadataForm(),
            ),
          ),
        ),
      ),
    );
  }
}