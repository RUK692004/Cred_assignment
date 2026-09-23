import 'package:cred/app/theme.dart';
import 'package:cred/core/formatters.dart';
import 'package:cred/data/credit_cards.dart';
import 'package:cred/models/credit_card.dart';
import 'package:cred/screens/home/widgets/bank_card.dart';
import 'package:cred/screens/home/widgets/credit_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Width a card is laid out with in isolation.
const double _cardWidth = 340;

Future<void> pumpCard(
  WidgetTester tester,
  CreditCard card, {
  VoidCallback? onPayNow,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: _cardWidth,
            child: CreditCardWidget(card: card, onPayNow: onPayNow),
          ),
        ),
      ),
    ),
  );
}

/// The InkWells that make up a card (the "Pay now" pill).
Iterable<InkWell> inkWells(WidgetTester tester) =>
    tester.widgetList<InkWell>(find.byType(InkWell));

void main() {
  group('CreditCardWidget', () {
    for (final CreditCard card in kCreditCards) {
      testWidgets('renders ${card.bankName} from its data', (
        WidgetTester tester,
      ) async {
        await pumpCard(tester, card);

        expect(find.byType(BankCardPattern), findsOneWidget);
        expect(find.byType(BankLogo), findsOneWidget);
        expect(find.byType(CardChip), findsOneWidget);
        expect(find.text(card.maskedNumber), findsOneWidget);
        expect(find.text(card.cardHolderName), findsOneWidget);

        if (card.dueAmount != null) {
          expect(
            find.text(formatRupeesWithPaise(card.dueAmount!)),
            findsOneWidget,
          );
        } else {
          expect(find.byType(CardDueInformation), findsNothing);
        }

        if (card.dueDate != null) {
          expect(find.text(card.dueDate!), findsOneWidget);
        }

        expect(
          find.byType(PayNowButton),
          card.showPayNow ? findsOneWidget : findsNothing,
        );
      });
    }

    testWidgets('keeps the credit-card aspect ratio', (
      WidgetTester tester,
    ) async {
      await pumpCard(tester, kCreditCards.first);

      final Size size = tester.getSize(find.byType(CreditCardWidget));
      expect(size.width / size.height, closeTo(AppSizes.cardAspectRatio, 0.01));
    });

    testWidgets('reports the tapped card through onPayNow', (
      WidgetTester tester,
    ) async {
      final CreditCard card = kCreditCards[1];
      CreditCard? tapped;

      await pumpCard(tester, card, onPayNow: () => tapped = card);
      await tester.tap(find.byType(PayNowButton));
      await tester.pumpAndSettle();

      expect(tapped, card);
    });

    testWidgets('attaches no swipe, drag, scale or long-press gesture', (
      WidgetTester tester,
    ) async {
      await pumpCard(
        tester,
        kCreditCards.last,
        onPayNow: () {},
      );

      expect(find.byType(Dismissible), findsNothing);
      expect(find.byType(GestureDetector), findsWidgets);

      for (final GestureDetector detector
          in tester.widgetList<GestureDetector>(find.byType(GestureDetector))) {
        expect(detector.onHorizontalDragUpdate, isNull);
        expect(detector.onVerticalDragUpdate, isNull);
        expect(detector.onPanUpdate, isNull);
        expect(detector.onScaleUpdate, isNull);
      }

      for (final InkWell inkWell in inkWells(tester)) {
        expect(inkWell.onLongPress, isNull);
      }
    });

    testWidgets('renders without overflow at any card width', (
      WidgetTester tester,
    ) async {
      for (final double width in <double>[260, 320, 440, 640]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: CreditCardWidget(card: kCreditCards.last),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'width $width');
        expect(
          find.text(kCreditCards.last.maskedNumber),
          findsOneWidget,
          reason: 'width $width',
        );
      }
    });

    testWidgets('describes the card for screen readers', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      final CreditCard card = kCreditCards.first;
      await pumpCard(tester, card);

      // The card is announced as one unit, including the masked digits.
      expect(
        find.bySemanticsLabel(
          RegExp('${card.bankName} card ending ${card.lastFourDigits}'),
        ),
        findsWidgets,
      );

      // Handles have to be released inside the test body.
      handle.dispose();
    });
  });
}