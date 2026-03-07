import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuizRepository {
  Future<List<Question>> getQuestions() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/quiz_questions.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      // Return empty list if file doesn't exist yet or has errors
      return [];
    }
  }
}
