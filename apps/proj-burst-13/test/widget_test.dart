import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alarm_pad/main.dart';

void main() {
  testWidgets('renders the PIN pad lock screen', (tester) async {
    await tester.pumpWidget(const AlarmPadApp());

    expect(find.byKey(const ValueKey('pin_dots')), findsOneWidget);
    expect(find.byKey(const ValueKey('digit_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('digit_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('delete')), findsOneWidget);
    expect(find.text('Alarm ringing'), findsOneWidget);
  });
}
