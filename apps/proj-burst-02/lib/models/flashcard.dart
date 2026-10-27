import 'package:flutter/foundation.dart';

@immutable
class Flashcard {
  const Flashcard({
    required this.question,
    required this.answer,
    this.correctCount = 0,
    this.wrongCount = 0,
  });

  final String question;
  final String answer;
  final int correctCount;
  final int wrongCount;

  int get timesSeen => correctCount + wrongCount;

  Flashcard withGrade(bool correct) {
    return Flashcard(
      question: question,
      answer: answer,
      correctCount: correctCount + (correct ? 1 : 0),
      wrongCount: wrongCount + (correct ? 0 : 1),
    );
  }

  Flashcard resetTally() {
    return Flashcard(question: question, answer: answer);
  }
}
