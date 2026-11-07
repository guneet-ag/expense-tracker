import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('App starts and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseApp());
    await tester.pump();
    expect(find.text('Expense Tracker'), findsOneWidget);
  });
}