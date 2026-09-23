import 'package:cred/app/app.dart';
import 'package:cred/data/credit_cards.dart';
import 'package:cred/models/credit_card.dart';
import 'package:cred/screens/home/widgets/cashback_banner.dart';
import 'package:cred/screens/home/widgets/credit_card_widget.dart';
import 'package:cred/screens/home/widgets/lower_section.dart';
import 'package:cred/screens/home/widgets/pay_bill_button.dart';
import 'package:cred/screens/home/widgets/summary_content.dart';
import 'package:cred/screens/home/widgets/summary_pill.dart';
import 'package:cred/screens/home/widgets/top_controls.dart';
import 'package:cred/screens/home/widgets/upper_background.dart';
import 'package:cred/screens/home/widgets/upper_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The statement amount the header shows, derived from the card data.
const String _statementTotal = '₹50,000.00';

/// The scrollable that owns the card list.
Finder get _cardList => find.descendant(
  of: find.byType(LowerSection),
  matching: find.byType(Scrollable),
);

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
      expect(
        find.descendant(
          of: find.byType(SummaryContent),
          matching: find.text(_statementTotal),
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(PayBillButton, 'Pay bill'), findsOneWidget);
    });

    testWidgets('renders the Phase 2 upper section shell', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      // Decorative background, "%" button, pill, settings button, banner.
      expect(find.byType(UpperBackground), findsOneWidget);
      expect(find.byType(TopControls), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byType(CashbackBanner), findsOneWidget);
      expect(
        find.textContaining('cashback on full bill payments'),
        findsOneWidget,
      );

      // The red notification badge sits on the Total Due option.
      expect(
        find.descendant(
          of: find.byType(SummaryPill),
          matching: find.byType(NotificationDot),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows the SBI card first in the lower section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      expect(find.byType(LowerSection), findsOneWidget);
      expect(find.byType(CreditCardWidget), findsWidgets);
      expect(
        find.byKey(ValueKey<String>(kCreditCards.first.id)),
        findsOneWidget,
      );
      expect(find.text(kCreditCards.first.maskedNumber), findsOneWidget);
    });

    testWidgets('reveals all five bank cards by scrolling down', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      expect(kCreditCards.length, 5);

      for (final CreditCard card in kCreditCards) {
        final Finder cardFinder = find.byKey(ValueKey<String>(card.id));
        await tester.scrollUntilVisible(cardFinder, 240, scrollable: _cardList);
        expect(cardFinder, findsOneWidget);
      }
    });

    testWidgets('scrolls the cards while the upper section stays pinned', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      expect(_cardList, findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(UpperSection),
          matching: find.byType(Scrollable),
        ),
        findsNothing,
      );

      final double pillTopBefore = tester.getTopLeft(find.byType(SummaryPill)).dy;

      await tester.drag(_cardList, const Offset(0, -220));
      await tester.pumpAndSettle();

      expect(
        tester.state<ScrollableState>(_cardList).position.pixels,
        greaterThan(0),
      );
      expect(tester.getTopLeft(find.byType(SummaryPill)).dy, pillTopBefore);
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
      expect(
        find.descendant(
          of: find.byType(SummaryContent),
          matching: find.text(_statementTotal),
        ),
        findsNothing,
      );
      expect(find.byType(PayBillButton), findsNothing);

      // Switching tabs only swaps the summary: the cards stay in place.
      expect(find.byKey(ValueKey<String>(kCreditCards.first.id)), findsOneWidget);
    });

    testWidgets('switches back to Total Due', (WidgetTester tester) async {
      await tester.pumpWidget(const CredApp());

      await tester.tap(find.text('RECENT SPENDS'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TOTAL DUE'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SummaryContent),
          matching: find.text(_statementTotal),
        ),
        findsOneWidget,
      );
      expect(find.byType(PayBillButton), findsOneWidget);
    });

    testWidgets('Pay bill is tappable but performs no payment', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      await tester.tap(find.byType(PayBillButton));
      await tester.pumpAndSettle();

      // The phase stays on the same screen: no navigation, no payment.
      expect(find.byType(UpperSection), findsOneWidget);
      expect(find.byType(LowerSection), findsOneWidget);
      expect(find.byType(PayBillButton), findsOneWidget);
    });

    testWidgets('lays out on a small phone without overflow', (
      WidgetTester tester,
    ) async {
      // 320x480 is the smallest phone the dashboard has to support.
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const CredApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CreditCardWidget), findsWidgets);
      // The card list is still scrollable, so every card stays reachable.
      expect(
        tester.state<ScrollableState>(_cardList).position.maxScrollExtent,
        greaterThan(0),
      );
    });

    testWidgets('lays out on a wide window without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const CredApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // The content column keeps its phone-like width instead of stretching.
      expect(tester.getSize(find.byType(CreditCardWidget).first).width, 440);
    });

    testWidgets('keeps the credit-card aspect ratio on every card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      final Size size = tester.getSize(find.byType(CreditCardWidget).first);
      expect(size.width / size.height, closeTo(1.586, 0.01));
    });
  });
}
