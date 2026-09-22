import 'package:cred/app/app.dart';
import 'package:cred/screens/home/widgets/bill_card.dart';
import 'package:cred/screens/home/widgets/lower_section.dart';
import 'package:cred/screens/home/widgets/pay_bill_button.dart';
import 'package:cred/screens/home/widgets/summary_pill.dart';
import 'package:cred/screens/home/widgets/upper_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('shows the Total Due state by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      expect(find.byType(SummaryPill), findsOneWidget);
      expect(find.text('TOTAL DUE'), findsOneWidget);
      expect(find.text('RECENT SPENDS'), findsOneWidget);
      expect(find.text('STATEMENT DUE FOR 1 CARD'), findsOneWidget);
      expect(find.text('₹12,450'), findsOneWidget);
      expect(find.widgetWithText(PayBillButton, 'Pay Bill'), findsOneWidget);
    });

    testWidgets('shows a single bill card in the lower section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      expect(find.byType(LowerSection), findsOneWidget);
      expect(find.byType(BillCard), findsOneWidget);
      expect(find.text('Electricity'), findsOneWidget);
      expect(find.text('Kerala State Electricity Board'), findsOneWidget);
      expect(find.text('₹2,450'), findsOneWidget);
      expect(find.text('DUE IN 4 DAYS'), findsOneWidget);
    });

    testWidgets('keeps the upper section static and out of any scrollable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      expect(
        find.descendant(
          of: find.byType(UpperSection),
          matching: find.byType(Scrollable),
        ),
        findsNothing,
      );
      expect(find.byType(Scrollable), findsNothing);
    });

    testWidgets('switches to the Recent Spends placeholder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      await tester.tap(find.text('RECENT SPENDS'));
      await tester.pumpAndSettle();

      // "RECENT SPENDS" is now shown both in the pill and as the state label.
      expect(find.text('RECENT SPENDS'), findsNWidgets(2));
      expect(find.text('₹4,280'), findsOneWidget);
      expect(find.text('Total spent recently'), findsOneWidget);
      expect(find.text('₹12,450'), findsNothing);
      expect(find.byType(PayBillButton), findsNothing);
    });

    testWidgets('switches back to Total Due', (WidgetTester tester) async {
      await tester.pumpWidget(const CredApp());

      await tester.tap(find.text('RECENT SPENDS'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TOTAL DUE'));
      await tester.pumpAndSettle();

      expect(find.text('₹12,450'), findsOneWidget);
      expect(find.byType(PayBillButton), findsOneWidget);
    });

    testWidgets('Pay Bill is tappable but performs no payment', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      await tester.tap(find.byType(PayBillButton));
      await tester.pumpAndSettle();

      // Phase 1 stays on the same screen: no navigation, no payment.
      expect(find.byType(UpperSection), findsOneWidget);
      expect(find.byType(BillCard), findsOneWidget);
      expect(find.byType(PayBillButton), findsOneWidget);
    });
  });
}
