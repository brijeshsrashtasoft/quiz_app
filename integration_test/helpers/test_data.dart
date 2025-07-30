import 'dart:math';

/// Test data generator for E2E testing
class TestDataGenerator {
  static final Random _random = Random();

  /// Generate a random quiz for testing
  static TestQuiz generateQuiz({
    int? questionCount,
    String? title,
    String? description,
  }) {
    final count = questionCount ?? _random.nextInt(5) + 3;
    
    return TestQuiz(
      id: _generateId(),
      title: title ?? 'Test Quiz ${_random.nextInt(1000)}',
      description: description ?? 'Generated test quiz for E2E testing',
      questions: List.generate(count, (index) => generateQuestion(index + 1)),
      createdAt: DateTime.now(),
      isPublic: _random.nextBool(),
      timeLimit: _random.nextInt(180) + 30,
    );
  }

  /// Generate a random question
  static TestQuestion generateQuestion(int questionNumber) {
    return TestQuestion(
      id: _generateId(),
      type: QuestionType.multipleChoice,
      text: 'Question $questionNumber: What is ${_random.nextInt(100)} + ${_random.nextInt(100)}?',
      options: _generateMultipleChoiceOptions(),
      correctAnswer: 0,
      timeLimit: 30,
      points: _random.nextInt(1000) + 100,
    );
  }

  /// Generate multiple choice options
  static List<String> _generateMultipleChoiceOptions() {
    final correctAnswer = _random.nextInt(200);
    final options = <String>[correctAnswer.toString()];
    
    for (int i = 0; i < 3; i++) {
      int wrongAnswer;
      do {
        wrongAnswer = _random.nextInt(200);
      } while (wrongAnswer == correctAnswer || 
               options.contains(wrongAnswer.toString()));
      
      options.add(wrongAnswer.toString());
    }
    
    return options;
  }

  /// Generate a test user
  static TestUser generateUser({
    String? name,
    String? email,
    String? id,
  }) {
    return TestUser(
      id: id ?? _generateId(),
      name: name ?? 'TestUser${_random.nextInt(10000)}',
      email: email ?? 'testuser${_random.nextInt(10000)}@example.com',
      createdAt: DateTime.now(),
    );
  }

  /// Generate a unique ID
  static String _generateId() {
    return 'test_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';
  }
}

// Test data models
class TestQuiz {
  final String id;
  final String title;
  final String description;
  final List<TestQuestion> questions;
  final DateTime createdAt;
  final bool isPublic;
  final int timeLimit;

  TestQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.createdAt,
    required this.isPublic,
    required this.timeLimit,
  });
}

class TestQuestion {
  final String id;
  final QuestionType type;
  final String text;
  final List<String> options;
  final int? correctAnswer;
  final int timeLimit;
  final int points;

  TestQuestion({
    required this.id,
    required this.type,
    required this.text,
    required this.options,
    this.correctAnswer,
    required this.timeLimit,
    required this.points,
  });
}

class TestUser {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  TestUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });
}

// Enums
enum QuestionType { multipleChoice, trueFalse, typeAnswer }
