/// A single outstanding bill shown in the lower card area.
///
/// The model is intentionally tiny: Phase 1 renders one hardcoded bill, while
/// Phase 2 replaces the single card with a stack of bills coming from a data
/// source - the card widget does not have to change.
class Bill {
  const Bill({
    required this.title,
    required this.provider,
    required this.amount,
    required this.dueText,
  });

  /// Short label of the bill, e.g. `Electricity`.
  final String title;

  /// Name of the billing company.
  final String provider;

  /// Amount outstanding, in rupees.
  final double amount;

  /// Human readable due date, e.g. `Due in 4 days`.
  final String dueText;
}
