import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/formatters.dart';
import 'pay_bill_button.dart';
import 'summary_pill.dart';

/// Minimum height of the summary block.
///
/// Reserving the space keeps the lower card section from jumping around when
/// the user switches tabs.
const double _summaryBlockHeight = 168;

/// Content rendered underneath the [SummaryPill], swapped with a short fade
/// and slide whenever the selected tab changes.
class SummaryContent extends StatelessWidget {
  const SummaryContent({
    super.key,
    required this.selectedTab,
    required this.statementDue,
    required this.cardCount,
    required this.recentSpends,
    required this.onPayBill,
  });

  /// Index of the selected tab, see [kTotalDueTab] / [kRecentSpendsTab].
  final int selectedTab;

  /// Total amount currently due across [cardCount] cards.
  final double statementDue;

  final int cardCount;

  /// Placeholder amount of the "Recent Spends" tab.
  final double recentSpends;

  final VoidCallback onPayBill;

  @override
  Widget build(BuildContext context) {
    final double scale = appScale(context);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: _summaryBlockHeight * scale),
      child: AnimatedSwitcher(
        duration: AppDurations.content,
        switchInCurve: AppDurations.curve,
        switchOutCurve: AppDurations.curve,
        transitionBuilder: _fadeThrough,
        child: selectedTab == kRecentSpendsTab
            ? RecentSpendsPlaceholder(
                key: const ValueKey<int>(kRecentSpendsTab),
                amount: recentSpends,
              )
            : Column(
                key: const ValueKey<int>(kTotalDueTab),
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  StatementDue(amount: statementDue, cardCount: cardCount),
                  SizedBox(height: 22 * scale),
                  PayBillButton(onPressed: onPayBill),
                ],
              ),
      ),
    );
  }

  /// Fade with a small upward slide, kept subtle on purpose.
  static Widget _fadeThrough(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

/// The primary Phase 1 state: the amount the user has to pay right now.
class StatementDue extends StatelessWidget {
  const StatementDue({super.key, required this.amount, this.cardCount = 1});

  final double amount;
  final int cardCount;

  @override
  Widget build(BuildContext context) {
    final double scale = appScale(context);
    final String label =
        'Statement due for $cardCount card${cardCount == 1 ? '' : 's'}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: AppTextStyles.eyebrow,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12 * scale),
        _HeroAmount(amount: amount),
      ],
    );
  }
}

/// Placeholder state of the "Recent Spends" tab.
///
/// Phase 1 only proves that the pill switches content; the real spend
/// breakdown arrives in a later phase.
class RecentSpendsPlaceholder extends StatelessWidget {
  const RecentSpendsPlaceholder({super.key, required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final double scale = appScale(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text(
          'RECENT SPENDS',
          style: AppTextStyles.eyebrow,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12 * scale),
        _HeroAmount(amount: amount),
        SizedBox(height: 10 * scale),
        const Text('Total spent recently', style: AppTextStyles.caption),
      ],
    );
  }
}

/// Hero number shared by both tabs so the two states line up exactly.
class _HeroAmount extends StatelessWidget {
  const _HeroAmount({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final double scale = appScale(context);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        formatRupees(amount),
        maxLines: 1,
        style: AppTextStyles.heroAmount.copyWith(
          fontSize: AppTextStyles.heroAmount.fontSize! * scale,
        ),
      ),
    );
  }
}
