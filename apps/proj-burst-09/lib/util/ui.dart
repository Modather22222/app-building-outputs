import 'package:flutter/material.dart';

const List<String> _weekdayNames = [
  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
];

const List<String> _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

String formatDay(DateTime d) =>
    '${_weekdayNames[d.weekday - 1]}, ${_monthNames[d.month - 1]} ${d.day}';

String formatWeight(double kg) => '${kg.toStringAsFixed(1)} kg';

Color deltaColor(double delta, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  if (delta == 0) {
    return dark ? Colors.grey.shade400 : Colors.grey.shade700;
  }
  return delta < 0
      ? (dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
      : (dark ? const Color(0xFFE57373) : const Color(0xFFC62828));
}
