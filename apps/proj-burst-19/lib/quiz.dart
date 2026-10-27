import 'dart:math';

import 'package:flutter/foundation.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.emoji,
    required this.options,
    required this.correctAnswer,
  });

  final String prompt;
  final String emoji;
  final List<String> options;
  final String correctAnswer;
}

class QuizController extends ChangeNotifier {
  QuizController({this.questionCount = 8, Random? random})
      : _random = random ?? Random() {
    _startRound();
  }

  final int questionCount;
  final Random _random;

  late List<QuizQuestion> questions;
  int currentIndex = 0;
  int score = 0;
  String? selectedAnswer;

  bool get isFinished => currentIndex >= questions.length;
  bool get isAnswered => selectedAnswer != null;

  QuizQuestion get currentQuestion =>
      isFinished ? questions.last : questions[currentIndex];

  void selectAnswer(String option) {
    if (isAnswered || isFinished) return;
    selectedAnswer = option;
    if (option == currentQuestion.correctAnswer) score++;
    notifyListeners();
  }

  void nextQuestion() {
    if (!isAnswered || isFinished) return;
    currentIndex++;
    selectedAnswer = null;
    notifyListeners();
  }

  void restart() {
    _startRound();
    notifyListeners();
  }

  void _startRound() {
    questions = List.generate(
      questionCount,
      (_) =>
          _random.nextBool() ? _massQuestion() : _temperatureQuestion(),
    );
    currentIndex = 0;
    score = 0;
    selectedAnswer = null;
  }

  static const List<double> _massValues = [
    0.2,
    0.5,
    1,
    2,
    2.5,
    3,
    5,
    7.5,
    10,
    12.5,
    15,
    20,
    25,
    30,
    45,
    60,
    80,
    100,
  ];

  static const List<double> _celsiusValues = [
    -18,
    -10,
    -5,
    0,
    5,
    10,
    15,
    20,
    25,
    30,
    35,
    37,
    40,
  ];

  static const List<double> _fahrenheitValues = [
    -20,
    0,
    10,
    32,
    45,
    68,
    72,
    77,
    85,
    90,
    98.6,
    100,
    104,
  ];

  static const List<String> _extensionEmoji = ['⚖️', '🏋️', '🧱', '📦'];
  static const List<String> _tempEmoji = ['🌡️', '☀️', '❄️', '🔥'];

  T _pick<T>(List<T> values) => values[_random.nextInt(values.length)];

  QuizQuestion _massQuestion() {
    final fromKg = _random.nextBool();
    final value = _pick(_massValues);
    final converted = fromKg ? value * 2.20462 : value / 2.20462;
    final correct = _fmt(converted);
    return QuizQuestion(
      prompt:
          'What is ${_fmt(value)} ${fromKg ? 'kg' : 'lb'} in ${fromKg ? 'lb' : 'kg'}?',
      emoji: _pick(_extensionEmoji),
      options: _buildOptions(correct, converted),
      correctAnswer: correct,
    );
  }

  QuizQuestion _temperatureQuestion() {
    final toFahrenheit = _random.nextBool();
    final value = _pick(toFahrenheit ? _celsiusValues : _fahrenheitValues);
    final converted =
        toFahrenheit ? value * 9 / 5 + 32 : (value - 32) * 5 / 9;
    final correct = _fmt(converted);
    return QuizQuestion(
      prompt:
          'What is ${_fmt(value)} °${toFahrenheit ? 'C' : 'F'} in °${toFahrenheit ? 'F' : 'C'}?',
      emoji: _pick(_tempEmoji),
      options: _buildOptions(correct, converted),
      correctAnswer: correct,
    );
  }

  List<String> _buildOptions(String correct, double correctValue) {
    final options = <String>{correct};
    var guard = 0;
    while (options.length < 4 && guard < 200) {
      guard++;
      options.add(_fmt(_distractor(correctValue)));
    }
    final shuffled = options.toList()..shuffle(_random);
    return shuffled;
  }

  double _distractor(double correct) {
    final magnitude = max(correct.abs(), 1.0);
    final sign = _random.nextBool() ? 1.0 : -1.0;
    switch (_random.nextInt(4)) {
      case 0:
        return correct + sign * magnitude * (_random.nextDouble() * 0.35 + 0.05);
      case 1:
        return correct * 2 + sign * magnitude * _random.nextDouble() * 0.1;
      case 2:
        return correct * 0.5 + sign * magnitude * _random.nextDouble() * 0.1;
      default:
        return correct + sign * magnitude * (_random.nextDouble() * 0.15 + 0.15);
    }
  }

  String _fmt(double value) {
    final rounded = (value * 100).roundToDouble() / 100;
    if (rounded == 0) return '0';
    var text = rounded.toStringAsFixed(2);
    text = text.replaceAll(RegExp(r'0+$'), '');
    if (text.endsWith('.')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }
}
