import 'package:flutter_test/flutter_test.dart';

import 'package:expense_log/main.dart';
import 'package:expense_log/state/expense_store.dart';

void main() {
  testWidgets('renders the expense list home screen', (tester) async {
    await tester.pumpWidget(ExpenseLogApp(store: ExpenseStore()));
    await tester.pumpAndSettle();

    expect(find.text('Expense Log'), findsOneWidget);
    expect(find.text('Add expense'), findsOneWidget);
  });
}
