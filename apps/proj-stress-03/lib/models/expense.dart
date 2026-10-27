import 'package:flutter/material.dart';

enum Category {
  food('Food', Icons.restaurant_rounded),
  transport('Transport', Icons.directions_bus_rounded),
  shopping('Shopping', Icons.shopping_bag_rounded),
  bills('Bills', Icons.receipt_long_rounded),
  fun('Fun', Icons.celebration_rounded),
  other('Other', Icons.category_rounded);

  const Category(this.label, this.icon);

  final String label;
  final IconData icon;
}

class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  final String id;
  final String title;
  final double amount;
  final Category category;
  final DateTime date;
}
