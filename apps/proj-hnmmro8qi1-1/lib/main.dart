import 'package:flutter/material.dart';

import 'note_store.dart';
import 'notes_page.dart';

void main() {
  runApp(const QuickNoteApp());
}

class QuickNoteApp extends StatefulWidget {
  const QuickNoteApp({super.key});

  @override
  State<QuickNoteApp> createState() => _QuickNoteAppState();
}

class _QuickNoteAppState extends State<QuickNoteApp> {
  final NoteStore _store = NoteStore();

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: NotesPage(store: _store),
    );
  }
}
