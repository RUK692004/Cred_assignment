import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import 'summary_content.dart';
import 'summary_pill.dart';

/// Static header of the home screen: the sliding pill plus the summary of the
/// selected tab.
///
/// The widget is deliberately independent from the card area below so that
/// Phase 2 can introduce a scrolling / animated card stack underneath without
/// rewriting this part of the screen.
class UpperSection extends StatelessWidget {
  const UpperSection({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.statementDue,
    required this.cardCount,
    required this.recentSpends,
    required this.onPayBill,
  });

  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final double statementDue;
  final int cardCount;
  final double recentSpends;
  final VoidCallback onPayBill;

  @override
  Widget build(BuildContext context) {
    final double scale = appScale(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        8 * scale,
        AppSpacing.screen,
        4 * scale,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SummaryPill(selectedIndex: selectedTab, onSelected: onTabSelected),
          SizedBox(height: 30 * scale),
          SummaryContent(
            selectedTab: selectedTab,
            statementDue: statementDue,
            cardCount: cardCount,
            recentSpends: recentSpends,
            onPayBill: onPayBill,
          ),
        ],
      ),
    );
  }
}
