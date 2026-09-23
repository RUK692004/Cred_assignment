import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import 'cashback_banner.dart';
import 'summary_content.dart';
import 'top_controls.dart';
import 'upper_background.dart';

/// Viewport height below which the promotional banner is dropped.
///
/// On a very short viewport (a phone held in landscape, a small desktop window)
/// the card list would otherwise be squeezed into a few pixels. The statement
/// itself always stays visible.
const double _minBannerViewport = 520;

/// Static header of the home screen.
///
/// Phase 2 keeps the Phase 1 structure - a top control row, the sliding pill
/// and the statement summary - and adds the decorative [UpperBackground] plus
/// the cashback [CashbackBanner]. The section is deliberately independent from
/// the card area below, so only the lower list scrolls.
class UpperSection extends StatelessWidget {
  const UpperSection({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.statementDue,
    required this.cardCount,
    required this.recentSpends,
    required this.onPayBill,
    required this.onRewards,
    required this.onSettings,
    required this.onCashback,
    this.cashbackAmount = 50,
  });

  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final double statementDue;
  final int cardCount;
  final double recentSpends;
  final VoidCallback onPayBill;

  /// Tapped the circular "%" button.
  final VoidCallback onRewards;

  /// Tapped the settings button.
  final VoidCallback onSettings;

  /// Tapped the cashback banner.
  final VoidCallback onCashback;

  /// Cashback amount advertised by the banner, in rupees.
  final double cashbackAmount;

  @override
  Widget build(BuildContext context) {
    final double scale = appScale(context);
    final bool showBanner =
        MediaQuery.sizeOf(context).height >= _minBannerViewport;

    return Stack(
      children: <Widget>[
        const Positioned.fill(child: UpperBackground()),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen,
            6 * scale,
            AppSpacing.screen,
            4 * scale,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TopControls(
                selectedTab: selectedTab,
                onTabSelected: onTabSelected,
                onRewards: onRewards,
                onSettings: onSettings,
              ),
              SizedBox(height: 26 * scale),
              SummaryContent(
                selectedTab: selectedTab,
                statementDue: statementDue,
                cardCount: cardCount,
                recentSpends: recentSpends,
                onPayBill: onPayBill,
              ),
              if (showBanner) ...<Widget>[
                SizedBox(height: 16 * scale),
                CashbackBanner(cashbackAmount: cashbackAmount, onTap: onCashback),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

