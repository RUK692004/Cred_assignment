import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/formatters.dart';
import '../../../models/bill.dart';

/// Card showing a single bill, built from a [Bill] model so the UI never
/// hardcodes bill data.
///
/// Phase 2 superseded it on the home screen - the lower section now renders the
/// bank credit cards - but the widget is untouched and still tested, so it can
/// be reused for a bills view later.
class BillCard extends StatelessWidget {
  const BillCard({super.key, required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final double scale = appScale(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardHairline),
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
            const Positioned.fill(child: _CardDecoration()),
            Padding(
              padding: EdgeInsets.all(22 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              bill.title,
                              style: AppTextStyles.cardTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6 * scale),
                            Text(
                              bill.provider,
                              style: AppTextStyles.cardProvider,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16 * scale),
                      Text(
                        formatRupees(bill.amount),
                        style: AppTextStyles.cardAmount,
                        maxLines: 1,
                      ),
                    ],
                  ),
                  const Spacer(),
                  _DueChip(text: bill.dueText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small translucent tag, e.g. `DUE IN 4 DAYS`.
class _DueChip extends StatelessWidget {
  const _DueChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardChip,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          text.toUpperCase(),
          style: AppTextStyles.cardChip,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Soft geometric watermarks that give the card the layered look of the
/// reference artwork. Purely decorative, so taps pass straight through.
class _CardDecoration extends StatelessWidget {
  const _CardDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          const Positioned(
            top: -72,
            right: -64,
            child: _Blob(size: 220, color: AppColors.cardDecoration),
          ),
          const Positioned(
            bottom: -56,
            right: 36,
            child: _Blob(size: 136, color: AppColors.cardDecorationSoft),
          ),
          Positioned(
            bottom: -96,
            left: -64,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  color: AppColors.cardDecorationSoft,
                  borderRadius: BorderRadius.circular(48),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
