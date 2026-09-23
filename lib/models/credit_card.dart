import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

/// A single credit card shown in the lower section of the dashboard.
///
/// The model carries everything [CreditCardWidget] needs to paint a card, so
/// adding a bank is a pure data change - no widget is written per bank.
///
/// Phase 2 renders the cards statically. [backgroundAsset] and [logoAsset] are
/// already part of the model: when a bank's artwork cannot be reproduced
/// faithfully with Flutter painting, dropping a local asset into `assets/` and
/// pointing the field at it is enough, because the widget falls back to the
/// painted artwork whenever the field is `null`.
@immutable
class CreditCard {
  const CreditCard({
    required this.bankName,
    required this.artwork,
    required this.lastFourDigits,
    required this.cardHolderName,
    required this.backgroundColors,
    this.foreground = const Color(0xFFFFFFFF),
    this.accent = const Color(0xFFFFFFFF),
    this.logoAsset,
    this.backgroundAsset,
    this.dueAmount,
    this.dueDate,
    this.showPayNow = true,
  });

  /// The blurred part of a printed card number.
  static const String maskedPrefix = '\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022';

  /// Name of the issuing bank, e.g. `SBI Card`.
  final String bankName;

  /// Which bank artwork the card uses for its logo and its background pattern.
  final BankArtwork artwork;

  /// Last four digits of the card number, kept readable.
  final String lastFourDigits;

  /// Name embossed on the card.
  final String cardHolderName;

  /// Gradient of the card face, top-left to bottom-right.
  final List<Color> backgroundColors;

  /// Colour of the text, logo and chip highlights on the card face.
  final Color foreground;

  /// Brand accent of the bank, used by the logo block and the background
  /// pattern (e.g. the red IDFC FIRST block).
  final Color accent;

  /// Optional local logo asset; the painted [artwork] is used when `null`.
  final String? logoAsset;

  /// Optional local card-face asset; the painted [artwork] is used when `null`.
  final String? backgroundAsset;

  /// Outstanding amount; `null` when the card has nothing due.
  final double? dueAmount;

  /// Due date line printed on the card, e.g. `DUE ON 18 SEP`.
  final String? dueDate;

  /// Whether the card shows its white "Pay now" pill.
  final bool showPayNow;

  /// Printed card number with everything but the last four digits masked.
  String get maskedNumber => '$maskedPrefix $lastFourDigits';

  /// Stable identity of the card, handy for list keys and tests.
  String get id => '${artwork.name}-$lastFourDigits';

  /// Whether the card has an amount and/or a due date to show.
  bool get hasDueInformation => dueAmount != null || dueDate != null;
}

/// Artwork families painted by the card widgets.
///
/// Each value maps to a logo and a background pattern in `bank_card.dart`.
/// A new bank means a new value plus its artwork - the card widget itself stays
/// untouched.
enum BankArtwork { sbi, idfcFirst, hdfc, yesBank, axis }