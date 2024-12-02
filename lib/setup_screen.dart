import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'api_services.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _numQuestions = 5;
  String? _selectedCategory;
  String _selectedDifficulty = 'easy';
  String _selectedType = 'multiple';
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() async {
    _categories = await ApiService.fetchCategories();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Setup')),
      body: _categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Number of Questions'),
                  DropdownButton<int>(
                    value: _numQuestions,
                    onChanged: (value) => setState(() => _numQuestions = value!),
                    items: [5, 10, 15].map((num) {
                      return DropdownMenuItem(value: num, child: Text('$num'));
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text('Category'),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    items: _categories.map<DropdownMenuItem<String>>((cat) {
                      return DropdownMenuItem(
                        value: cat['id'].toString(),
                        child: Text(cat['name']),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text('Difficulty'),
                  DropdownButton<String>(
                    value: _selectedDifficulty,
                    onChanged: (value) => setState(() => _selectedDifficulty = value!),
                    items: ['easy', 'medium', 'hard'].map((level) {
                      return DropdownMenuItem(value: level, child: Text(level));
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text('Question Type'),
                  DropdownButton<String>(
                    value: _selectedType,
                    onChanged: (value) => setState(() => _selectedType = value!),
                    items: ['multiple', 'boolean'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(
                              numQuestions: _numQuestions,
                              category: _selectedCategory,
                              difficulty: _selectedDifficulty,
                              type: _selectedType,
                            ),
                          ),
                        );
                      },
                      child: Text('Start Quiz'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
