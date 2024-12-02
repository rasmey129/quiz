import 'dart:convert';
import 'package:http/http.dart' as http;

class Question {
  final String text;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
  // Cast incorrect answers to List<String>
  final incorrect = List<String>.from(json['incorrect_answers']);
  
  // Cast options to List<String> and shuffle
  final options = List<String>.from(incorrect)..add(json['correct_answer']);
  options.shuffle();

  return Question(
    text: json['question'],
    options: options,
    correctAnswer: json['correct_answer'],
  );
  }
}

class ApiService {
  static Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['trivia_categories'];
    } else {
      throw Exception('Failed to fetch categories');
    }
  }

  static Future<List<Question>> fetchQuestions(
      int numQuestions, String? category, String difficulty, String type) async {
    final url =
        'https://opentdb.com/api.php?amount=$numQuestions&category=$category&difficulty=$difficulty&type=$type';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'];
      return data.map<Question>((json) => Question.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch questions');
    }
  }
}
