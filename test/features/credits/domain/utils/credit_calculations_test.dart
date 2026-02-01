import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/credits/domain/utils/credit_calculations.dart';

void main() {
  group('calculateAnnuityMonthlyPayment', () {
    test('calculates correctly for standard input', () {
      final double payment = calculateAnnuityMonthlyPayment(
        principal: 100000,
        annualInterestRate: 10,
        termMonths: 10,
      );
      // Expected: ~10464.04
      expect(payment, closeTo(10464.04, 0.01));
    });

    test('calculates correctly for zero interest', () {
      final double payment = calculateAnnuityMonthlyPayment(
        principal: 100000,
        annualInterestRate: 0,
        termMonths: 10,
      );
      expect(payment, 10000.0);
    });

     test('calculates correctly for 1 month term', () {
      // 12000 principal, 12% rate (1% monthly), 1 month.
      // Payment should be 12000 + 1% = 12120.
      final double payment = calculateAnnuityMonthlyPayment(
        principal: 12000,
        annualInterestRate: 12,
        termMonths: 1,
      );
      expect(payment, closeTo(12120.0, 0.01));
    });

    test('returns 0 for zero or negative term', () {
      expect(
        calculateAnnuityMonthlyPayment(
          principal: 100000,
          annualInterestRate: 10,
          termMonths: 0,
        ),
        0.0,
      );
    });
  });
}
