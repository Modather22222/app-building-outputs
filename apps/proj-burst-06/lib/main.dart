import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'state/habit_store.dart';

void main() {
  runApp(HabitGridApp());
}

class HabitGridApp extends StatelessWidget {
  HabitGridApp({super.key, HabitStore? store}) : store = store ?? HabitStore();

  final HabitStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Grid',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.dark),
      home: HomeScreen(store: store),
    );
  }
}
