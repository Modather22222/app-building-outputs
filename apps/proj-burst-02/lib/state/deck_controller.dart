import 'package:flutter/foundation.dart';

import '../models/flashcard.dart';

class DeckController extends ChangeNotifier {
  DeckController({List<Flashcard>? cards})
      : _cards = List.of(cards ?? defaultDeck);

  static const List<Flashcard> defaultDeck = [
    Flashcard(question: 'Capital of France?', answer: 'Paris'),
    Flashcard(
      question: 'What is the chemical formula for water?',
      answer: 'H2O',
    ),
    Flashcard(question: 'How many continents are there?', answer: '7'),
    Flashcard(
      question: 'Which planet is known as the Red Planet?',
      answer: 'Mars',
    ),
    Flashcard(question: 'Who painted the Mona Lisa?', answer: 'Leonardo da Vinci'),
    Flashcard(
      question: 'In what year did humans first land on the Moon?',
      answer: '1969',
    ),
    Flashcard(
      question: 'What is the largest ocean on Earth?',
      answer: 'Pacific Ocean',
    ),
    Flashcard(
      question: 'How many sides does a hexagon have?',
      answer: '6',
    ),
  ];

  final List<Flashcard> _cards;
  int _index = 0;
  bool _revealed = false;
  bool _finished = false;

  List<Flashcard> get cards => List.unmodifiable(_cards);
  int get totalCards => _cards.length;
  int get index => _index;
  Flashcard get currentCard => _cards[_index];
  bool get isRevealed => _revealed;
  bool get isFinished => _finished;
  int get totalCorrect => _cards.fold(0, (sum, card) => sum + card.correctCount);
  int get totalWrong => _cards.fold(0, (sum, card) => sum + card.wrongCount);

  void toggleReveal() {
    _revealed = !_revealed;
    notifyListeners();
  }

  void grade(bool correct) {
    if (_finished) return;
    _cards[_index] = _cards[_index].withGrade(correct);
    if (_index + 1 < _cards.length) {
      _index++;
    } else {
      _finished = true;
    }
    _revealed = false;
    notifyListeners();
  }

  void restartDeck() {
    _index = 0;
    _revealed = false;
    _finished = false;
    notifyListeners();
  }

  void reset() {
    for (var i = 0; i < _cards.length; i++) {
      _cards[i] = _cards[i].resetTally();
    }
    _index = 0;
    _revealed = false;
    _finished = false;
    notifyListeners();
  }
}
