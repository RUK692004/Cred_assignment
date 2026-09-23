import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/credit_cards.dart';
import '../../models/credit_card.dart';
import 'widgets/lower_section.dart';
import 'widgets/summary_pill.dart';
import 'widgets/upper_section.dart';

/// Maximum width of the content column.
///
/// Phones are narrower than this, so it only comes into play on tablets and
/// desktop, where the screen keeps its phone-like proportions.
const double _maxContentWidth = 480;

/// Phase 2 placeholder value for the "Recent Spends" tab.
const double _recentSpendsAmount = 4280;

/// Home screen of the credit-card dashboard.
///
/// The screen keeps the Phase 1 split:
///  * [UpperSection] holds the statement header. It stays pinned to the top.
///  * [LowerSection] holds the bank cards. Phase 2 renders them as a plain
///    vertical list, so scrolling reveals the cards one after another.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// The only piece of state the screen owns: which summary tab is selected.
  int _selectedTab = kTotalDueTab;

  void _handleTabSelected(int index) {
    if (index == _selectedTab) {
      return;
    }
    setState(() => _selectedTab = index);
  }

  // Placeholder actions. Phase 2 only proves that the controls react; no
  // payment, navigation or network work happens yet.
  void _handlePayBill() {}

  void _handlePayNow(CreditCard card) {}

  void _handleRewards() {}

  void _handleSettings() {}

  void _handleCashback() {}

  @override
  Widget build(BuildContext context) {
    // Both figures are derived from the card data, so the header can never
    // disagree with the list underneath it.
    final double statementDue = totalDueOf(kCreditCards);
    final int cardsWithDue = cardsWithDueCount(kCreditCards);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.screen),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Column(
                children: <Widget>[
                  UpperSection(
                    selectedTab: _selectedTab,
                    onTabSelected: _handleTabSelected,
                    statementDue: statementDue,
                    cardCount: cardsWithDue,
                    recentSpends: _recentSpendsAmount,
                    onPayBill: _handlePayBill,
                    onRewards: _handleRewards,
                    onSettings: _handleSettings,
                    onCashback: _handleCashback,
                  ),
                  Expanded(
                    child: LowerSection(
                      cards: kCreditCards,
                      onPayNow: _handlePayNow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
