/// A single outstanding bill shown in the lower card area.
///
/// Phase 2 no longer mounts a bill on the home screen: the lower section shows
/// the bank credit cards from `models/credit_card.dart` instead. The Phase 1
/// model and its card widget are kept because they still work and are still
/// covered by tests, so they can be reused for a future bills view.
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
