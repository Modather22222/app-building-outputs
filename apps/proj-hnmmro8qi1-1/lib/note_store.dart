import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'note.dart';

/// In-memory note library (ChangeNotifier) that auto-saves to local storage.
class NoteStore extends ChangeNotifier {
  NoteStore({SharedPreferences? prefs}) : _prefsOverride = prefs;

  static const String _storageKey = 'quicknote.notes.v1';

  final SharedPreferences? _prefsOverride;
  final List<Note> _notes = <Note>[];
  bool _loaded = false;

  bool get loaded => _loaded;

  /// Notes sorted with the most recently updated first.
  List<Note> get notes {
    final sorted = List<Note>.of(_notes)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  /// Loads persisted notes once at startup; failures fall back to an empty
  /// library so the app always renders.
  Future<void> load() async {
    try {
      final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              _notes.add(Note.fromJson(Map<String, Object?>.from(item)));
            }
          }
        }
      }
    } catch (_) {
      // Corrupt or unavailable storage: start empty instead of crashing.
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  /// Inserts or updates [note] and persists immediately (auto-save).
  void upsert(Note note) {
    note.updatedAt = DateTime.now();
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    } else {
      _notes.add(note);
    }
    _persist();
  }

  /// Removes the note with [id]; returns it (for undo) or null if missing.
  Note? delete(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index < 0) return null;
    final removed = _notes.removeAt(index);
    _persist();
    return removed;
  }

  /// Puts a previously deleted note back into the library.
  void restore(Note note) {
    _notes.add(note);
    _persist();
  }

  Future<void> _persist() async {
    notifyListeners();
    try {
      final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
      final raw = jsonEncode(_notes.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (_) {
      // Storage is best-effort; the in-memory library still works.
    }
  }
}
