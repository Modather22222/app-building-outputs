import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habit_grid/main.dart';
import 'package:habit_grid/screens/home_screen.dart' show startOfWeek;

void main() {
  testWidgets('app renders the weekly grid with seeded habits', (tester) async {
    final app = HabitGridApp();
    await tester.pumpWidget(app);

    expect(find.text('Habit Grid'), findsOneWidget);
    expect(find.textContaining('Drink water'), findsOneWidget);
    expect(find.textContaining('Move 30 minutes'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.textContaining('day streak'), findsNWidgets(3));
  });

  testWidgets('tapping a grid cell toggles that day', (tester) async {
    final app = HabitGridApp();
    await tester.pumpWidget(app);
    app.store.addHabit('Test habit', '✍️');
    await tester.pumpAndSettle();

    final habit = app.store.habits.firstWhere((h) => h.name == 'Test habit');
    final monday = startOfWeek(DateTime.now());
    expect(habit.isDone(monday), isFalse);

    await tester.tap(
      find.byKey(ValueKey('cell-${habit.id}-${monday.toIso8601String()}')),
    );
    await tester.pump();

    expect(habit.isDone(monday), isTrue);
    expect(find.textContaining('Test habit'), findsOneWidget);
  });
}
