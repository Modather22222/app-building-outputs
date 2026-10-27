import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() {
  runApp(const CounterStackApp());
}

class CounterStackApp extends StatelessWidget {
  const CounterStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter Stack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
