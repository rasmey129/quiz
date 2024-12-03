import 'package:flutter/material.dart';
import 'api_services.dart';
import 'quiz_screen.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() async {
    try {
      final categories = await ApiService.fetchCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Setup')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Number of Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownButton<int>(
                    isExpanded: true,
                    value: _numQuestions,
                    onChanged: (value) => setState(() => _numQuestions = value!),
                    items: [5, 10, 15, 20].map((num) {
                      return DropdownMenuItem(value: num, child: Text('$num Questions'));
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    hint: Text('Any Category'),
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('Any Category'),
                      ),
                      ..._categories.map<DropdownMenuItem<String>>((cat) {
                        return DropdownMenuItem(
                          value: cat['id'].toString(),
                          child: Text(cat['name']),
                        );
                      }).toList(),
                    ],
                  ),
                  SizedBox(height: 20),

                  Text('Difficulty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedDifficulty,
                    onChanged: (value) => setState(() => _selectedDifficulty = value!),
                    items: ['easy', 'medium', 'hard'].map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(level[0].toUpperCase() + level.substring(1)),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  Text('Question Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedType,
                    onChanged: (value) => setState(() => _selectedType = value!),
                    items: [
                      DropdownMenuItem(value: 'multiple', child: Text('Multiple Choice')),
                      DropdownMenuItem(value: 'boolean', child: Text('True/False')),
                    ],
                  ),
                  SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
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
                      child: Text('Start Quiz', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}