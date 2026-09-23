import 'package:cred/core/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatRupees', () {
    test('groups whole amounts using the Indian numbering system', () {
      expect(formatRupees(500), '₹500');
      expect(formatRupees(2450), '₹2,450');
      expect(formatRupees(12450), '₹12,450');
      expect(formatRupees(123456), '₹1,23,456');
      expect(formatRupees(12345678), '₹1,23,45,678');
    });

    test('keeps paise when the amount is not whole', () {
      expect(formatRupees(12450.5), '₹12,450.50');
    });

    test('handles zero and negative amounts', () {
      expect(formatRupees(0), '₹0');
      expect(formatRupees(-2450), '-₹2,450');
    });
  });

  group('formatRupeesWithPaise', () {
    test('always keeps the two paise digits', () {
      expect(formatRupeesWithPaise(50000), '₹50,000.00');
      expect(formatRupeesWithPaise(0), '₹0.00');
      expect(formatRupeesWithPaise(999), '₹999.00');
    });

    test('groups the same way as formatRupees', () {
      expect(formatRupeesWithPaise(1234567.5), '₹12,34,567.50');
      expect(formatRupeesWithPaise(-50000), '-₹50,000.00');
    });
  });
}
