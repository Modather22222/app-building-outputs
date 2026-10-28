const List<String> _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _months = [
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

String pad2(int n) => n.toString().padLeft(2, '0');

String clockText(DateTime t, {required bool use24h}) {
  final h = use24h ? t.hour : (t.hour % 12 == 0 ? 12 : t.hour % 12);
  return '${pad2(h)}:${pad2(t.minute)}:${pad2(t.second)}';
}

String meridiem(DateTime t) => t.hour < 12 ? 'AM' : 'PM';

String longDate(DateTime t) =>
    '${_weekdays[t.weekday - 1]}, ${_months[t.month - 1]} ${t.day}, ${t.year}';

String stopwatchText(Duration d) {
  final h = d.inHours;
  final base = '${pad2(d.inMinutes.remainder(60))}:'
      '${pad2(d.inSeconds.remainder(60))}.'
      '${pad2(d.inMilliseconds.remainder(1000) ~/ 10)}';
  return h > 0 ? '$h:$base' : base;
}

String countdownText(Duration d) {
  final h = d.inHours;
  final base = '${pad2(d.inMinutes.remainder(60))}:${pad2(d.inSeconds.remainder(60))}';
  return h > 0 ? '$h:$base' : base;
}

String offsetLabel(Duration offset) {
  final sign = offset < Duration.zero ? '-' : '+';
  final h = offset.abs().inHours;
  final m = offset.abs().inMinutes.remainder(60);
  return 'UTC$sign$h${m == 0 ? '' : ':${pad2(m)}'}';
}
