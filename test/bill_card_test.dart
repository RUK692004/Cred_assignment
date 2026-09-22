import 'package:cred/models/bill.dart';
import 'package:cred/screens/home/widgets/bill_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpCard(WidgetTester tester, Bill bill) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 340, height: 220, child: BillCard(bill: bill)),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the values of the Bill model', (
    WidgetTester tester,
  ) async {
    const Bill bill = Bill(
      title: 'Electricity',
      provider: 'Kerala State Electricity Board',
      amount: 2450,
      dueText: 'Due in 4 days',
    );

    await pumpCard(tester, bill);

    expect(find.text('Electricity'), findsOneWidget);
    expect(find.text('Kerala State Electricity Board'), findsOneWidget);
    expect(find.text('₹2,450'), findsOneWidget);
    expect(find.text('DUE IN 4 DAYS'), findsOneWidget);
  });

  testWidgets('is reusable with any bill data', (WidgetTester tester) async {
    const Bill bill = Bill(
      title: 'Broadband',
      provider: 'JioFiber',
      amount: 999,
      dueText: 'Due today',
    );

    await pumpCard(tester, bill);

    expect(find.text('Broadband'), findsOneWidget);
    expect(find.text('JioFiber'), findsOneWidget);
    expect(find.text('₹999'), findsOneWidget);
    expect(find.text('DUE TODAY'), findsOneWidget);
  });

  testWidgets('attaches no gesture handling in Phase 1', (
    WidgetTester tester,
  ) async {
    const Bill bill = Bill(
      title: 'Electricity',
      provider: 'Kerala State Electricity Board',
      amount: 2450,
      dueText: 'Due in 4 days',
    );

    await pumpCard(tester, bill);

    expect(
      find.descendant(
        of: find.byType(BillCard),
        matching: find.byType(GestureDetector),
      ),
      findsNothing,
    );
  });
}
