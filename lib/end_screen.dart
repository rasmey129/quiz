import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final int score;
  final int total;

  const SummaryScreen({
    Key? key,
    required this.score,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Quiz Completed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Your Score:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '$score / $total',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Return to setup screen
              },
              child: Text('Return to Setup'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to setup
              },
              child: Text('Retake Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
