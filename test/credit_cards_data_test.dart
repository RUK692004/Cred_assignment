import 'package:cred/data/credit_cards.dart';
import 'package:cred/models/credit_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kCreditCards', () {
    test('lists the five reference banks in display order', () {
      expect(
        kCreditCards.map((CreditCard card) => card.bankName).toList(),
        <String>[
          'SBI Card',
          'IDFC FIRST Bank',
          'HDFC Bank',
          'YES BANK',
          'AXIS BANK',
        ],
      );
    });

    test('carries the card details of the reference designs', () {
      expect(
        kCreditCards.map((CreditCard card) => card.lastFourDigits).toList(),
        <String>['0373', '0925', '5501', '7722', '1234'],
      );

      for (final CreditCard card in kCreditCards) {
        expect(card.cardHolderName, isNotEmpty);
        expect(card.backgroundColors.length, greaterThanOrEqualTo(2));
      }

      expect(kCreditCards[1].cardHolderName, 'DEEP GAURAV');
      expect(kCreditCards.last.cardHolderName, 'SNEHA IYER');
    });

    test('gives every card a stable, unique identity', () {
      final Set<String> ids = kCreditCards
          .map((CreditCard card) => card.id)
          .toSet();

      expect(ids.length, kCreditCards.length);
    });

    test('masks the card number and keeps the last four digits', () {
      expect(
        kCreditCards.first.maskedNumber,
        '\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 0373',
      );
      expect(kCreditCards.first.maskedNumber, endsWith('0373'));
    });

    test('feeds the header with the outstanding statement', () {
      // Only the Axis card carries a statement amount in the reference, which
      // is why the header reports a single card due.
      expect(cardsWithDueCount(kCreditCards), 1);
      expect(totalDueOf(kCreditCards), 50000);

      final CreditCard axis = kCreditCards.last;
      expect(axis.dueAmount, 50000);
      expect(axis.dueDate, 'DUE ON 18 SEP');
      expect(axis.hasDueInformation, isTrue);
    });

    test('reports no due information for an empty list', () {
      expect(totalDueOf(const <CreditCard>[]), 0);
      expect(cardsWithDueCount(const <CreditCard>[]), 0);
    });
  });
}