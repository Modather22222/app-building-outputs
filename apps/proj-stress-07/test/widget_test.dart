import 'package:flutter_test/flutter_test.dart';

import 'package:water_reminder/main.dart';

void main() {
  testWidgets('app builds, shows goal ring, and logs a drink',
      (tester) async {
    await tester.pumpWidget(const WaterReminderApp());

    expect(find.text('Water Reminder'), findsOneWidget);
    expect(find.text('0 / 2000 ml'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);

    await tester.tap(find.text('+250 ml'));
    await tester.pump();

    expect(find.text('250 / 2000 ml'), findsOneWidget);
    expect(find.text('13%'), findsOneWidget);
    expect(find.text('250 ml'), findsOneWidget);
  });
}
