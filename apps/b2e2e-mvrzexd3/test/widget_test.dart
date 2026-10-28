import 'package:b2_verification/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke test: converter renders and updates live',
      (WidgetTester tester) async {
    await tester.pumpWidget(const B2VerificationApp());

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Kilometers → Miles'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '10');
    await tester.pump();

    expect(find.text('10 km'), findsOneWidget);
    expect(find.text('6.2137 miles'), findsOneWidget);
  });
}
