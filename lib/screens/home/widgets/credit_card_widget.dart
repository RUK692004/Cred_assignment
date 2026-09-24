import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/formatters.dart';
import '../../../models/credit_card.dart';
import 'bank_card.dart';

/// Height the internal metrics of a card are designed for.
///
/// Everything inside the card is multiplied by the ratio between the real card
/// height and this value, so the same layout keeps its proportions from a small
/// phone up to the widest tablet column.
const double _designCardHeight = 260;

/// Reusable bank credit card.
///
/// A card is assembled from small, focused parts - the painted
/// [BankCardPattern], the [BankLogo], a [CardChip], the [CardNumber], the
/// [CardHolderName], the optional [CardDueInformation] and the [PayNowButton] -
/// so every bank in [BankArtwork] renders from a single [CreditCard] value.
///
/// The widget owns the card face only: where a card sits inside the deck is
/// decided by the card stack that hosts it, so no gesture, rotation or
/// stacking behaviour is attached here.
class CreditCardWidget extends StatelessWidget {
  const CreditCardWidget({super.key, required this.card, this.onPayNow});

  final CreditCard card;

  /// Invoked by the "Pay now" pill; `null` keeps it visible but inert.
  final VoidCallback? onPayNow;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: AppSizes.cardAspectRatio,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double scale =
              (constraints.maxHeight / _designCardHeight).clamp(0.78, 1.35).toDouble();

          return Semantics(
            container: true,
            label: '${card.bankName} card ending ${card.lastFourDigits}',
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 26,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(child: BankCardPattern(card: card)),
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20 * scale,
                          vertical: 15 * scale,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _header(scale),
                            const Spacer(),
                            CardChip(size: 30 * scale),
                            SizedBox(height: 9 * scale),
                            CardNumber(card: card, scale: scale),
                            const Spacer(),
                            _footer(scale),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Bank logo on the left, payment action on the right.
  Widget _header(double scale) {
    return Row(
      children: <Widget>[
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: BankLogo(card: card, scale: scale),
          ),
        ),
        if (card.showPayNow) PayNowButton(onPressed: onPayNow, scale: scale),
      ],
    );
  }

  /// Card holder name on the left, outstanding amount on the right.
  Widget _footer(double scale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(child: CardHolderName(card: card, scale: scale)),
        if (card.hasDueInformation)
          CardDueInformation(card: card, scale: scale),
      ],
    );
  }
}

/// Golden EMV chip drawn on the card face.
class CardChip extends StatelessWidget {
  const CardChip({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.78),
      painter: const _ChipPainter(),
    );
  }
}

class _ChipPainter extends CustomPainter {
  const _ChipPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect body = RRect.fromRectAndRadius(
      rect.deflate(size.height * 0.03),
      Radius.circular(size.height * 0.24),
    );

    canvas.drawRRect(
      body,
      Paint()..shader = AppGradients.chip.createShader(rect),
    );

    final Paint line = Paint()
      ..color = AppColors.chipLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.055;

    canvas.save();
    canvas.clipRRect(body);
    canvas.drawLine(
      Offset(rect.left, rect.top + size.height * 0.3),
      Offset(rect.right, rect.top + size.height * 0.3),
      line,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top + size.height * 0.7),
      Offset(rect.right, rect.top + size.height * 0.7),
      line,
    );
    canvas.drawLine(
      Offset(rect.left + size.width / 3, rect.top),
      Offset(rect.left + size.width / 3, rect.bottom),
      line,
    );
    canvas.drawLine(
      Offset(rect.left + size.width / 3 * 2, rect.top),
      Offset(rect.left + size.width / 3 * 2, rect.bottom),
      line,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChipPainter oldDelegate) => false;
}

/// Masked card number, e.g. `•••• •••• •••• 0373`.
///
/// Everything but the last four digits is dimmed, which is how a real card is
/// masked in a banking app.
class CardNumber extends StatelessWidget {
  const CardNumber({super.key, required this.card, this.scale = 1});

  final CreditCard card;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = AppTextStyles.cardNumber.copyWith(
      fontSize: AppTextStyles.cardNumber.fontSize! * scale,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: CreditCard.maskedPrefix,
              style: style.copyWith(
                color: card.foreground.withValues(alpha: 0.55),
              ),
            ),
            TextSpan(
              text: ' ${card.lastFourDigits}',
              style: style.copyWith(color: card.foreground),
            ),
          ],
        ),
        maxLines: 1,
      ),
    );
  }
}

/// Card holder name printed at the bottom-left of the card.
class CardHolderName extends StatelessWidget {
  const CardHolderName({super.key, required this.card, this.scale = 1});

  final CreditCard card;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      card.cardHolderName.toUpperCase(),
      style: AppTextStyles.cardHolder.copyWith(
        fontSize: AppTextStyles.cardHolder.fontSize! * scale,
        color: card.foreground.withValues(alpha: 0.85),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Outstanding amount and due date of a card.
///
/// Cards without anything due simply do not render this block.
class CardDueInformation extends StatelessWidget {
  const CardDueInformation({super.key, required this.card, this.scale = 1});

  final CreditCard card;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double? amount = card.dueAmount;
    final String? dueDate = card.dueDate;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (amount != null)
          Text(
            formatRupeesWithPaise(amount),
            style: AppTextStyles.cardDueAmount.copyWith(
              fontSize: AppTextStyles.cardDueAmount.fontSize! * scale,
              color: card.foreground,
            ),
            maxLines: 1,
          ),
        if (dueDate != null) ...<Widget>[
          if (amount != null) SizedBox(height: 3 * scale),
          Text(
            dueDate,
            style: AppTextStyles.cardDueDate.copyWith(
              fontSize: AppTextStyles.cardDueDate.fontSize! * scale,
              color: card.foreground.withValues(alpha: 0.72),
            ),
            maxLines: 1,
          ),
        ],
      ],
    );
  }
}

/// White pill that starts the payment of a single card.
class PayNowButton extends StatelessWidget {
  const PayNowButton({
    super.key,
    this.onPressed,
    this.label = 'Pay now',
    this.scale = 1,
  });

  final VoidCallback? onPressed;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.payNowSurface,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14 * scale,
            vertical: 8 * scale,
          ),
          child: Text(
            label,
            style: AppTextStyles.payNow.copyWith(
              fontSize: AppTextStyles.payNow.fontSize! * scale,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
