import 'dart:async';
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
  String? _selectedAnswer;
  Timer? _timer;
  int _timeLeft = 15;
  bool _isTimerInitialized = false;

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

  void _startTimer(Question currentQuestion) {
    if (_isTimerInitialized) return;
    
    _isTimerInitialized = true;
    _timeLeft = 15;
    _timer?.cancel();
    
    setState(() {
      _timeLeft = 15; // Reset the timer
    });

    // Start a new timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        // Time's up
        timer.cancel();
        if (!_isAnswered) {
          _answerQuestion('', currentQuestion); // Call the answer function with no input
        }
      }
    });
  }

  void _answerQuestion(String answer, Question currentQuestion) {
    if (_isAnswered) return;

    _timer?.cancel();
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      if (answer == currentQuestion.correctAnswer) {
        _score++;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          answer == currentQuestion.correctAnswer
              ? 'Correct!'
              : answer.isEmpty
                  ? 'Time\'s up! The correct answer was: ${currentQuestion.correctAnswer}'
                  : 'Incorrect! The correct answer was: ${currentQuestion.correctAnswer}',
        ),
        backgroundColor: answer == currentQuestion.correctAnswer ? Colors.green : Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _isAnswered = false;
      _selectedAnswer = null;
      _isTimerInitialized = false;  // Reset timer initialization flag
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading questions'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No questions available'));
          }

          final questions = snapshot.data!;

          if (_currentIndex >= questions.length) {
            return SummaryScreen(score: _score, total: questions.length);
          }

          final question = questions[_currentIndex];

          // Start timer after frame is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isAnswered && !_isTimerInitialized) {
              _startTimer(question);
            }
          });

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / questions.length,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Question ${_currentIndex + 1} of ${questions.length}'),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 5 ? Colors.red[100] : Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Time: $_timeLeft s',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _timeLeft <= 5 ? Colors.red : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  question.text,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ...question.options.map((option) {
                  final bool isSelected = _selectedAnswer == option;
                  final bool isCorrect = question.correctAnswer == option;

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      onPressed: _isAnswered ? null : () => _answerQuestion(option, question),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAnswered
                            ? isCorrect
                                ? Colors.green[100]
                                : isSelected
                                    ? Colors.red[100]
                                    : null
                            : null,
                      ),
                      child: Text(option),
                    ),
                  );
                }),
                if (_isAnswered) ...[
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(_currentIndex < questions.length - 1 ? 'Next Question' : 'Finish Quiz'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}