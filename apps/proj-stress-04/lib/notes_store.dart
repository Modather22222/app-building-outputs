import 'package:flutter/material.dart';

class Note {
  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.colorIndex = -1,
    this.pinned = false,
  });

  final int id;
  String title;
  String body;
  DateTime updatedAt;
  int colorIndex;
  bool pinned;

  Note copyWith({
    String? title,
    String? body,
    DateTime? updatedAt,
    int? colorIndex,
    bool? pinned,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
      colorIndex: colorIndex ?? this.colorIndex,
      pinned: pinned ?? this.pinned,
    );
  }
}

/// Palette shown to the user; index -1 means "no label".
const noteColors = <Color>[
  Color(0xFFFFF59D),
  Color(0xFFA5D6A7),
  Color(0xFF90CAF9),
  Color(0xFFFFAB91),
  Color(0xFFCE93D8),
  Color(0xFFB0BEC5),
];

class NotesStore extends ChangeNotifier {
  NotesStore() {
    _notes
      ..add(Note(
        id: _nextId++,
        title: 'Groceries',
        body: 'Milk, eggs, coffee beans, spinach',
        updatedAt: DateTime(2026, 10, 26, 9, 30),
        colorIndex: 0,
      ))
      ..add(Note(
        id: _nextId++,
        title: 'Ideas',
        body: 'Weekend project: build a tiny Flutter game',
        updatedAt: DateTime(2026, 10, 25, 18, 5),
        colorIndex: 1,
      ))
      ..add(Note(
        id: _nextId++,
        title: 'Quotes',
        body: 'Simplicity is the soul of efficiency.',
        updatedAt: DateTime(2026, 10, 24, 12, 0),
      ));
  }

  final List<Note> _notes = [];
  int _nextId = 1;
  String query = '';

  int get count => _notes.length;

  List<Note> get notes {
    final q = query.trim().toLowerCase();
    final result = _notes.where((n) {
      if (q.isEmpty) return true;
      return n.title.toLowerCase().contains(q) ||
          n.body.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
    return List.unmodifiable(result);
  }

  Note noteById(int id) => _notes.firstWhere((n) => n.id == id);

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void add({required String title, required String body, int colorIndex = -1}) {
    _notes.add(Note(
      id: _nextId++,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      colorIndex: colorIndex,
    ));
    notifyListeners();
  }

  void update(
    int id, {
    required String title,
    required String body,
    required int colorIndex,
    required bool pinned,
  }) {
    _notes.firstWhere((n) => n.id == id)
      ..title = title
      ..body = body
      ..colorIndex = colorIndex
      ..pinned = pinned
      ..updatedAt = DateTime.now();
    notifyListeners();
  }

  void togglePin(int id) {
    final note = _notes.firstWhere((n) => n.id == id);
    note.pinned = !note.pinned;
    note.updatedAt = DateTime.now();
    notifyListeners();
  }

  void cycleColor(int id) {
    final note = _notes.firstWhere((n) => n.id == id);
    note.colorIndex =
        note.colorIndex < 0 ? 0 : (note.colorIndex + 1) % noteColors.length;
    note.updatedAt = DateTime.now();
    notifyListeners();
  }

  void delete(int id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
