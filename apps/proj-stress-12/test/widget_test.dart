import 'package:bmi_coach/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home screen renders and calculates a BMI', (WidgetTester tester) async {
    await tester.pumpWidget(const BmiCoachApp());

    expect(find.text('BMI Coach'), findsOneWidget);
    expect(find.text('Calculate BMI'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('height-field')), '175');
    await tester.enterText(find.byKey(const Key('weight-field')), '70');
    await tester.tap(find.text('Calculate BMI'));
    await tester.pump();

    expect(find.text('22.9'), findsOneWidget);
    expect(find.text('Healthy'), findsOneWidget);
  });
}
