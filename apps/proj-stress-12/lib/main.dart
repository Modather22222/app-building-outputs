import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'state/bmi_history.dart';

void main() {
  runApp(const BmiCoachApp());
}

class BmiCoachApp extends StatefulWidget {
  const BmiCoachApp({super.key});

  @override
  State<BmiCoachApp> createState() => _BmiCoachAppState();
}

class _BmiCoachAppState extends State<BmiCoachApp> {
  final BmiHistory _history = BmiHistory();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(history: _history),
    );
  }
}
