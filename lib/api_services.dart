import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Fetch categories from the API
  static Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['trivia_categories'];
    } else {
      throw Exception('Failed to fetch categories');
    }
  }

  // Clean HTML entities in text
  static String _cleanText(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', "&")
        .replaceAll('&lt;', "<")
        .replaceAll('&gt;', ">");
  }

  // Fetch questions from the API
  static Future<List<Question>> fetchQuestions(
    int numQuestions,
    String? category,
    String difficulty,
    String type,
  ) async {
    final url = 'https://opentdb.com/api.php?amount=$numQuestions'
        '${category != null ? '&category=$category' : ''}'
        '&difficulty=$difficulty'
        '&type=$type';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'];
      return data.map<Question>((json) => Question.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch questions');
    }
  }
}

class Question {
  final String text; // Question text
  final List<String> options; // Answer options
  final String correctAnswer; // Correct answer

  Question({
    required this.text,
    required this.options,
    required this.correctAnswer,
  });

  // Factory constructor to create a Question from JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    final incorrect = List<String>.from(json['incorrect_answers'])
        .map((answer) => ApiService._cleanText(answer))
        .toList();
    final correctAnswer = ApiService._cleanText(json['correct_answer']);
    final options = List<String>.from(incorrect)..add(correctAnswer);
    options.shuffle();

    return Question(
      text: ApiService._cleanText(json['question']),
      options: options,
      correctAnswer: correctAnswer,
    );
  }
}
