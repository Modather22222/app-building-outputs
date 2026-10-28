import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:p7_1_verification/main.dart';

void main() {
  testWidgets('stopwatch smoke test', (tester) async {
    await tester.pumpWidget(const P71VerificationApp());

    expect(find.byKey(const ValueKey('stopwatch-display')), findsOneWidget);
    expect(find.text('00:00.00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });
}
