import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weight_log/main.dart';
import 'package:weight_log/widgets/trend_chart.dart';

void main() {
  testWidgets('renders app bar, trend chart and add action', (tester) async {
    await tester.pumpWidget(const WeightLogApp());

    expect(find.text('Weight Log'), findsOneWidget);
    expect(find.byType(TrendChart), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
}
