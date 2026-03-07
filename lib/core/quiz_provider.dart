import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/quiz/data/quiz_repository.dart';
import '../features/quiz/models/question.dart';

class QuizProvider with ChangeNotifier {
  final QuizRepository _repository = QuizRepository();
  final Random _random = Random();

  List<Question> _allQuestions = [];
  List<Question> _unseenQuestions = [];
  Set<String> _globallySeenQuestionIds = {};

  Question? _currentQuestion;
  int _score = 0;
  bool _isLoading = false;

  // State for the current question
  int? _selectedOptionIndex;
  bool _isAnswerChecked = false;
  bool? _isCorrect;

  QuizProvider() {
    _initQuiz();
  }

  bool get isLoading => _isLoading;
  Question? get currentQuestion => _currentQuestion;
  int get score => _score;
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool get isAnswerChecked => _isAnswerChecked;
  bool? get isCorrect => _isCorrect;
  int get totalQuestionsLoaded => _allQuestions.length;

  Future<void> _initQuiz() async {
    _isLoading = true;
    notifyListeners();

    // 1. Load All Questions from Assets
    _allQuestions = await _repository.getQuestions();

    // 2. Load Seen Question IDs from Persistent Storage
    final prefs = await SharedPreferences.getInstance();
    final seenList = prefs.getStringList('seen_quiz_questions') ?? [];
    _globallySeenQuestionIds = seenList.toSet();

    // 3. Filter Initial Pool
    _unseenQuestions = _allQuestions
        .where((q) => !_globallySeenQuestionIds.contains(q.id))
        .toList();

    // If everything was seen, reset to start over (or handle as desired)
    if (_unseenQuestions.isEmpty && _allQuestions.isNotEmpty) {
      await resetPersistentProgress();
      _unseenQuestions = List.from(_allQuestions);
    }

    _loadNextQuestion();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetPersistentProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('seen_quiz_questions');
    _globallySeenQuestionIds.clear();
    _unseenQuestions = List.from(_allQuestions);
    _loadNextQuestion();
  }

  void resetGame() {
    _score = 0;
    // Note: We don't reset persistent seen here, just the current session's score.
    // The user wants questions to NOT repeat ever until exhausted.
    _loadNextQuestion();
  }

  void _loadNextQuestion() async {
    if (_unseenQuestions.isEmpty) {
      // Re-fill from all questions if we ran out
      await resetPersistentProgress();
      _unseenQuestions = List.from(_allQuestions);
    }

    if (_unseenQuestions.isNotEmpty) {
      final randomIndex = _random.nextInt(_unseenQuestions.length);
      _currentQuestion = _unseenQuestions.removeAt(randomIndex);

      // Mark as seen immediately in memory and persistence
      if (_currentQuestion != null) {
        _globallySeenQuestionIds.add(_currentQuestion!.id);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
            'seen_quiz_questions', _globallySeenQuestionIds.toList());
      }
    } else {
      _currentQuestion = null;
    }

    _selectedOptionIndex = null;
    _isAnswerChecked = false;
    _isCorrect = null;
    notifyListeners();
  }

  void selectAnswer(int index) {
    if (_isAnswerChecked) {
      return;
    }

    _selectedOptionIndex = index;
    notifyListeners();
  }

  Future<void> checkAnswer() async {
    if (_selectedOptionIndex == null ||
        _isAnswerChecked ||
        _currentQuestion == null) {
      return;
    }

    _isAnswerChecked = true;
    _isCorrect = (_selectedOptionIndex == _currentQuestion!.correctOptionIndex);

    if (_isCorrect == true) {
      _score++;
    } else {
      _score = 0; // Reset score to zero on mistake as requested
    }

    notifyListeners();
  }

  void nextQuestion() {
    _loadNextQuestion();
  }
}
