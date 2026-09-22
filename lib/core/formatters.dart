/// Formats [amount] as rupees using the Indian digit grouping
/// (`₹12,450`, `₹1,23,456`).
///
/// Whole amounts are shown without decimals, amounts with paise keep two.
String formatRupees(double amount) {
  final bool isWhole = amount == amount.roundToDouble();
  final String plain = amount.abs().toStringAsFixed(isWhole ? 0 : 2);

  final int dot = plain.indexOf('.');
  final String whole = dot == -1 ? plain : plain.substring(0, dot);
  final String paise = dot == -1 ? '' : plain.substring(dot);
  final String sign = amount.isNegative ? '-' : '';

  return '$sign₹${_groupIndian(whole)}$paise';
}

/// `123456` -> `1,23,456` (last three digits, then groups of two).
String _groupIndian(String digits) {
  if (digits.length <= 3) {
    return digits;
  }

  final String lastThree = digits.substring(digits.length - 3);
  String rest = digits.substring(0, digits.length - 3);
  final List<String> groups = <String>[];

  while (rest.length > 2) {
    groups.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) {
    groups.insert(0, rest);
  }

  return '${groups.join(',')},$lastThree';
}
