import 'package:flutter/material.dart';

import 'picker_screen.dart';

void main() {
  runApp(const ColorMatchApp());
}

class ColorMatchApp extends StatelessWidget {
  const ColorMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Match',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4C6FE7),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF4C6FE7),
      ),
      themeMode: ThemeMode.system,
      home: const PickerScreen(),
    );
  }
}
