import 'package:flutter/material.dart';
import 'dart:math';

@immutable
class CardModel {
  final int id;
  final String symbol;

  const CardModel({required this.id, required this.symbol});
}

@immutable
class Tile {
  final CardModel card;
  final bool faceUp;
  final bool matched;

  const Tile({required this.card, this.faceUp = false, this.matched = false});

  Tile copyWith({bool? faceUp, bool? matched}) => Tile(
        card: card,
        faceUp: faceUp ?? this.faceUp,
        matched: matched ?? this.matched,
      );
}

class GameState extends ChangeNotifier {
  static const _symbols = [
    '🍇', '🍉', '🍋', '🍓', '🍒', '🥝', '🍍', '🥑',
  ];

  static const int pairs = 8;

  List<Tile> tiles = [];
  int moves = 0;
  int matchedPairs = 0;
  bool _locked = false;
  int? firstFlipped;

  Duration elapsed = Duration.zero;
  bool _running = false;

  Duration? bestTime;
  int? bestMoves;

  bool get locked => _locked;
  bool get isComplete => matchedPairs == pairs;
  bool get running => _running;

  void newGame({void Function()? onTick}) {
    final cards = [
      for (var i = 0; i < pairs; i++) ...[
        CardModel(id: i, symbol: _symbols[i]),
        CardModel(id: i, symbol: _symbols[i]),
      ],
    ];
    cards.shuffle(Random());
    tiles = [for (final c in cards) Tile(card: c)];
    moves = 0;
    matchedPairs = 0;
    elapsed = Duration.zero;
    firstFlipped = null;
    _locked = false;
    _running = true;
    notifyListeners();
  }

  void tick() {
    if (_running && !isComplete) {
      elapsed += const Duration(seconds: 1);
      notifyListeners();
    }
  }

  void flip(int index) {
    if (_locked) return;
    if (tiles[index].faceUp || tiles[index].matched) return;

    tiles[index] = tiles[index].copyWith(faceUp: true);
    notifyListeners();

    final first = firstFlipped;
    if (first == null) {
      firstFlipped = index;
      return;
    }

    moves++;
    if (tiles[first].card.id == tiles[index].card.id) {
      tiles[first] = tiles[first].copyWith(matched: true);
      tiles[index] = tiles[index].copyWith(matched: true);
      firstFlipped = null;
      if (++matchedPairs == pairs) {
        _running = false;
        if (bestTime == null || elapsed < bestTime!) {
          bestTime = elapsed;
          bestMoves = moves;
        }
      }
      notifyListeners();
    } else {
      _locked = true;
      final a = first, b = index;
      firstFlipped = null;
      Future.delayed(const Duration(milliseconds: 700), () {
        tiles[a] = tiles[a].copyWith(faceUp: false);
        tiles[b] = tiles[b].copyWith(faceUp: false);
        _locked = false;
        notifyListeners();
      });
      notifyListeners();
    }
  }
}
