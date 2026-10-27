import 'package:flutter/material.dart';

import 'state/expense_store.dart';
import 'ui/home_screen.dart';

void main() {
  runApp(ExpenseLogApp(store: ExpenseStore()));
}

class ExpenseLogApp extends StatelessWidget {
  const ExpenseLogApp({super.key, required this.store});

  final ExpenseStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Log',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: HomeScreen(store: store),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00695C),
        brightness: brightness,
      ),
    );
  }
}
