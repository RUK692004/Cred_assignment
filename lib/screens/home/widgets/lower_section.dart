import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../models/credit_card.dart';
import 'stacked_card_list.dart';

/// Lower part of the home screen: the bank credit cards.
///
/// The cards sit in [StackedCardList], which layers them like a physical hand
/// of cards and scrolls through them. This section only owns the space the hand
/// lives in - the area below the statement and the warm halo behind the cards -
/// so the upper section is never part of a card interaction.
class LowerSection extends StatelessWidget {
  const LowerSection({super.key, required this.cards, this.onPayNow});

  /// Cards to stack, the front card first.
  final List<CreditCard> cards;

  /// Called with the card whose "Pay now" pill was tapped.
  final ValueChanged<CreditCard>? onPayNow;

  @override
  Widget build(BuildContext context) {
    final double scale = appScale(context);

    return Stack(
      children: <Widget>[
        // Warm halo kept from Phase 1, now sitting behind the stacked cards.
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.cardGlow),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm * scale,
            AppSpacing.screen,
            AppSpacing.xl * scale,
          ),
          child: StackedCardList(cards: cards, onPayNow: onPayNow),
        ),
      ],
    );
  }
}

