const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _weekdayShort = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

String monthLabel(DateTime date) => '${_monthNames[date.month - 1]} ${date.year}';

String weekdayLabel(DateTime date) => _weekdayShort[date.weekday - 1];

String dayLabel(DateTime date, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  if (day == today) return 'Today';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return '${weekdayLabel(date)}, ${_monthNames[date.month - 1].substring(0, 3)} ${date.day}';
}

String formatMoney(double value) => '\$${value.toStringAsFixed(2)}';
