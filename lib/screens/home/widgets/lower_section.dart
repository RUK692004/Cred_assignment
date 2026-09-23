import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../models/credit_card.dart';
import 'credit_card_widget.dart';

/// Lower part of the home screen: the bank credit cards.
///
/// Phase 2 replaced the single Phase 1 bill card with a plain vertical list of
/// cards. There is deliberately no deck behaviour here: the cards neither
/// overlap nor rotate nor react to horizontal gestures - they simply scroll,
/// which keeps the list ready for the Phase 3 animations.
class LowerSection extends StatelessWidget {
  const LowerSection({super.key, required this.cards, this.onPayNow});

  /// Cards to render, in display order.
  final List<CreditCard> cards;

  /// Called with the card whose "Pay now" pill was tapped.
  final ValueChanged<CreditCard>? onPayNow;

  @override
  Widget build(BuildContext context) {
    final double scale = appScale(context);

    return Stack(
      children: <Widget>[
        // Warm halo kept from Phase 1, now sitting behind the scrolling list.
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.cardGlow),
            ),
          ),
        ),
        ListView.separated(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm * scale,
            AppSpacing.screen,
            AppSpacing.xl * scale,
          ),
          itemCount: cards.length,
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(height: AppSpacing.lg * scale),
          itemBuilder: (BuildContext context, int index) {
            final CreditCard card = cards[index];
            return CreditCardWidget(
              key: ValueKey<String>(card.id),
              card: card,
              onPayNow: onPayNow == null ? null : () => onPayNow!(card),
            );
          },
        ),
      ],
    );
  }
}

