import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple isolated test for quiz creation UI
void main() {
  runApp(const IsolatedQuizApp());
}

class IsolatedQuizApp extends StatelessWidget {
  const IsolatedQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Isolated Quiz Test',
        home: const TestQuizCreationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class TestQuizCreationScreen extends StatefulWidget {
  const TestQuizCreationScreen({super.key});

  @override
  State<TestQuizCreationScreen> createState() => _TestQuizCreationScreenState();
}

class _TestQuizCreationScreenState extends State<TestQuizCreationScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Creation Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Simple stepper
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSimpleStep(0, 'Details', _currentStep >= 0),
                  _buildSimpleStep(1, 'Questions', _currentStep >= 1),
                  _buildSimpleStep(2, 'Settings', _currentStep >= 2),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: _buildSimpleStepContent(),
              ),
            ),
            // Navigation
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Previous'),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: _currentStep < 2 
                        ? () => setState(() => _currentStep++) 
                        : () => print('Save & Preview'),
                    child: Text(_currentStep < 2 ? 'Next' : 'Save & Preview'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStep(int index, String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.deepPurple : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSimpleStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildDetailsForm();
      case 1:
        return _buildQuestionsContent();
      case 2:
        return _buildSettingsContent();
      default:
        return const Center(child: Text('Invalid step'));
    }
  }

  Widget _buildDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiz Information',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Quiz Title',
            hintText: 'Enter an engaging title for your quiz',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Describe what your quiz is about',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: 'General Knowledge',
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: [
            'General Knowledge',
            'Science',
            'History',
            'Geography',
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {},
        ),
      ],
    );
  }

  Widget _buildQuestionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Questions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => print('Add Question'),
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No questions yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start building your quiz by adding questions',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiz Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Make quiz public'),
                  subtitle: const Text('Allow anyone to play this quiz'),
                  value: true,
                  onChanged: (bool value) {},
                ),
                SwitchListTile(
                  title: const Text('Enable leaderboard'),
                  subtitle: const Text('Show player rankings after each game'),
                  value: true,
                  onChanged: (bool value) {},
                ),
                SwitchListTile(
                  title: const Text('Randomize questions'),
                  subtitle: const Text('Questions appear in random order'),
                  value: false,
                  onChanged: (bool value) {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}