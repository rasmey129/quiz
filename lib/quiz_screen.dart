import 'package:flutter/material.dart';
import 'api_services.dart';
import 'end_screen.dart';

class QuizScreen extends StatefulWidget {
  final int numQuestions;
  final String? category;
  final String difficulty;
  final String type;

  QuizScreen({
    required this.numQuestions,
    required this.category,
    required this.difficulty,
    required this.type,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questionsFuture;
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = ApiService.fetchQuestions(
      widget.numQuestions,
      widget.category,
      widget.difficulty,
      widget.type,
    );
  }

  void _answerQuestion(bool isCorrect) {
    setState(() {
      if (isCorrect) _score++;
      _isAnswered = true;
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _isAnswered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading questions'));
          } else if (snapshot.hasData) {
            final questions = snapshot.data!;
            if (_currentIndex >= questions.length) {
              return SummaryScreen(score: _score, total: questions.length);
            }
            final question = questions[_currentIndex];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(question.text, style: TextStyle(fontSize: 20)),
                ...question.options.map((option) {
                  return ElevatedButton(
                    onPressed: _isAnswered
                        ? null
                        : () => _answerQuestion(option == question.correctAnswer),
                    child: Text(option),
                  );
                }),
                if (_isAnswered)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text('Next'),
                  ),
              ],
            );
          } else {
            return Center(child: Text('No questions found'));
          }
        },
      ),
    );
  }
}
