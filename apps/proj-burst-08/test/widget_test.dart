import 'package:counter_stack/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app builds and shows the counter list', (WidgetTester tester) async {
    await tester.pumpWidget(const CounterStackApp());

    expect(find.text('Counter Stack'), findsOneWidget);
    expect(find.text('Cups of coffee'), findsOneWidget);
    expect(find.byIcon(Icons.restart_alt), findsOneWidget);
  });
}
