import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:color_match/main.dart';

void main() {
  testWidgets('picker screen renders with hex field, sliders and palette',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ColorMatchApp());

    expect(find.text('Color Match'), findsOneWidget);
    expect(find.text('#4C6FE7'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(3));
    expect(find.text('Favorites (5)'), findsOneWidget);
  });
}
