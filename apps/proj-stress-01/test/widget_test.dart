import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unit_converter/main.dart';

void main() {
  testWidgets('app renders with the three conversion tabs', (tester) async {
    await tester.pumpWidget(const UnitConverterApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Unit Converter'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Length'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);

    // The default Length tab converts the prefilled value of 1 Millimeter
    // to Centimeter.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('0.1'), findsOneWidget);
  });
}
