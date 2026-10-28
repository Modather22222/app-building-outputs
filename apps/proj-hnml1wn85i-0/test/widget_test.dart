import 'package:clock_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('clock app boots and shows the clock tab', (tester) async {
    await tester.pumpWidget(const ClockApp());
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byKey(const ValueKey('digital-clock')), findsOneWidget);

    await tester.tap(find.text('Stopwatch'));
    await tester.pump();

    expect(find.byKey(const ValueKey('stopwatch-time')), findsOneWidget);
  });
}
