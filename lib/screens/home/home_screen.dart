import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/bill.dart';
import 'widgets/lower_section.dart';
import 'widgets/summary_pill.dart';
import 'widgets/upper_section.dart';

/// Maximum width of the content column.
///
/// Phones are narrower than this, so it only comes into play on tablets and
/// desktop, where the screen keeps its phone-like proportions.
const double _maxContentWidth = 480;

/// Phase 1 placeholder values. A real data source replaces them in a later
/// phase - the widgets below only receive the values.
const double _statementDueAmount = 12450;
const double _recentSpendsAmount = 4280;
const int _cardsInStatement = 1;

/// Home screen.
///
/// Composed of two independent sections:
///  * [UpperSection]: the static summary header (never scrolls).
///  * [LowerSection]: the card area, which Phase 2 turns into an animated
///    stack of cards.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// The only piece of state Phase 1 needs: which summary tab is selected.
  int _selectedTab = kTotalDueTab;

  /// The single bill shown in the lower section for Phase 1.
  static const Bill _bill = Bill(
    title: 'Electricity',
    provider: 'Kerala State Electricity Board',
    amount: 2450,
    dueText: 'Due in 4 days',
  );

  void _handleTabSelected(int index) {
    if (index == _selectedTab) {
      return;
    }
    setState(() => _selectedTab = index);
  }

  /// Placeholder action: Phase 1 intentionally pays nothing.
  void _handlePayBill() {
    // The payment flow lands in a later phase.
  }

  @override
  Widget build(BuildContext context) {
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
                    statementDue: _statementDueAmount,
                    cardCount: _cardsInStatement,
                    recentSpends: _recentSpendsAmount,
                    onPayBill: _handlePayBill,
                  ),
                  const Expanded(child: LowerSection(bill: _bill)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
