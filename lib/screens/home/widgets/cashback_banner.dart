import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/formatters.dart';

/// Promotional banner closing the upper section.
///
/// A light rounded card with a small icon, the offer sentence in the brand
/// colour and a chevron hinting at a detail page. Tapping it is a placeholder
/// action: Phase 2 only ships the visual.
class CashbackBanner extends StatelessWidget {
  const CashbackBanner({super.key, this.cashbackAmount = 50, this.onTap});

  /// Cashback offered on a full bill payment, in rupees.
  final double cashbackAmount;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double scale = appScale(context);
    final TextStyle style = TextStyle(
      fontSize: AppTextStyles.cashback.fontSize! * scale,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cashbackSurface,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.cashbackBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.controlShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md * scale,
              vertical: 10 * scale,
            ),
            child: Row(
              children: <Widget>[
                _BannerIcon(size: AppSizes.bannerIcon * scale),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        const TextSpan(text: 'get '),
                        TextSpan(
                          text: formatRupees(cashbackAmount),
                          style: AppTextStyles.cashbackAmount,
                        ),
                        const TextSpan(
                          text: ' cashback on full bill payments',
                        ),
                      ],
                    ),
                    style: style,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: AppSpacing.sm * scale),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20 * scale,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small rounded icon tile that leads the banner.
class _BannerIcon extends StatelessWidget {
  const _BannerIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cashbackIconSurface,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        Icons.currency_rupee_rounded,
        size: size * 0.62,
        color: AppColors.accent,
      ),
    );
  }
}
