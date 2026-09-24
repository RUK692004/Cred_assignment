import 'package:flutter/material.dart';

import '../models/credit_card.dart';

/// Demo dataset of the dashboard cards.
///
/// Phase 2 deliberately keeps the data static: the widgets below only receive
/// values, so swapping this list for an API or a database later touches no UI
/// code at all.
///
/// The figures and card details mirror the Phase 2 reference designs. Only the
/// Axis card carries an outstanding statement (as in the reference), which is
/// why the upper section reports a single card due.
const List<CreditCard> kCreditCards = <CreditCard>[
  CreditCard(
    bankName: 'SBI Card',
    artwork: BankArtwork.sbi,
    lastFourDigits: '0373',
    cardHolderName: 'DEEP GAURAV',
    backgroundColors: <Color>[Color(0xFF1348BC), Color(0xFF06256C)],
    accent: Color(0xFF8FBEFF),
    // The reference card shows its payment action like every other card.
    showPayNow: true,
  ),
  CreditCard(
    bankName: 'IDFC FIRST Bank',
    artwork: BankArtwork.idfcFirst,
    lastFourDigits: '0925',
    cardHolderName: 'DEEP GAURAV',
    backgroundColors: <Color>[Color(0xFF2E2E33), Color(0xFF151517)],
    accent: Color(0xFFE2231A),
  ),
  CreditCard(
    bankName: 'HDFC Bank',
    artwork: BankArtwork.hdfc,
    lastFourDigits: '5501',
    cardHolderName: 'DEEP GAURAV',
    backgroundColors: <Color>[Color(0xFF262A35), Color(0xFF101219)],
    accent: Color(0xFFE2231A),
  ),
  CreditCard(
    bankName: 'YES BANK',
    artwork: BankArtwork.yesBank,
    lastFourDigits: '7722',
    cardHolderName: 'DEEP GAURAV',
    backgroundColors: <Color>[Color(0xFF1A7BDC), Color(0xFF0A3C97)],
    accent: Color(0xFFBFDBFF),
  ),
  CreditCard(
    bankName: 'AXIS BANK',
    artwork: BankArtwork.axis,
    lastFourDigits: '1234',
    cardHolderName: 'SNEHA IYER',
    backgroundColors: <Color>[Color(0xFFA81C5F), Color(0xFF65092F)],
    accent: Color(0xFFFFC3DD),
    dueAmount: 50000,
    dueDate: 'DUE ON 18 SEP',
  ),
];

/// Sum of the outstanding amounts of [cards].
///
/// This is the number the upper section shows as the statement due, so the
/// header can never drift away from the card list.
double totalDueOf(List<CreditCard> cards) {
  double total = 0;
  for (final CreditCard card in cards) {
    total += card.dueAmount ?? 0;
  }
  return total;
}

/// How many cards in [cards] currently carry an outstanding statement.
int cardsWithDueCount(List<CreditCard> cards) =>
    cards.where((CreditCard card) => card.dueAmount != null).length;