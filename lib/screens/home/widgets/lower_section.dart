import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../models/bill.dart';
import 'bill_card.dart';

/// Card height relative to the available width, taken from the proportions of
/// the reference design.
const double _cardHeightRatio = 0.72;

/// Lower part of the home screen.
///
/// Phase 1 shows exactly one static [BillCard] and implements no gesture at
/// all. Phase 2 swaps the body for an animated stack of cards - the upper
/// section stays untouched.
class LowerSection extends StatelessWidget {
  const LowerSection({super.key, required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final double scale = appScale(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double verticalPadding = (AppSpacing.md + AppSpacing.lg) * scale;
        final double availableHeight = math.max(
          constraints.maxHeight - verticalPadding,
          0,
        );
        final double cardHeight = math.min(
          constraints.maxWidth * _cardHeightRatio,
          availableHeight,
        );

        return Stack(
          children: <Widget>[
            // Warm halo behind the card, mirroring the reference artwork.
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppGradients.cardGlow),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.md * scale,
                  AppSpacing.screen,
                  AppSpacing.lg * scale,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: cardHeight,
                  child: BillCard(bill: bill),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
