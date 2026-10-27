import 'package:flutter/material.dart';

import 'screens/study_screen.dart';
import 'state/deck_controller.dart';

void main() {
  runApp(const FlashcardsApp());
}

class FlashcardsApp extends StatefulWidget {
  const FlashcardsApp({super.key});

  @override
  State<FlashcardsApp> createState() => _FlashcardsAppState();
}

class _FlashcardsAppState extends State<FlashcardsApp> {
  final DeckController _controller = DeckController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: StudyScreen(controller: _controller),
    );
  }
}
