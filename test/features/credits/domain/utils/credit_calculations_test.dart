import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/utils/annuity_calculator.dart';
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

    test('returns 0 for zero or negative principal', () {
      expect(
        calculateAnnuityMonthlyPayment(
          principal: 0,
          annualInterestRate: 10,
          termMonths: 12,
        ),
        0.0,
      );
      expect(
        calculateAnnuityMonthlyPayment(
          principal: -1000,
          annualInterestRate: 10,
          termMonths: 12,
        ),
        0.0,
      );
    });

    test('таблично: платеж растет при увеличении ставки', () {
      const double principal = 250000;
      const int termMonths = 24;
      final List<double> rates = <double>[0, 5, 10, 20, 40];

      double? previousPayment;
      for (final double rate in rates) {
        final double payment = calculateAnnuityMonthlyPayment(
          principal: principal,
          annualInterestRate: rate,
          termMonths: termMonths,
        );
        if (previousPayment != null) {
          expect(payment, greaterThanOrEqualTo(previousPayment));
        }
        previousPayment = payment;
      }
    });

    test(
      'таблично: при одинаковой ставке меньший срок дает больший платеж',
      () {
        const double principal = 250000;
        const double rate = 12;
        final List<int> terms = <int>[60, 36, 24, 12, 6];

        double? previousPayment;
        for (final int term in terms) {
          final double payment = calculateAnnuityMonthlyPayment(
            principal: principal,
            annualInterestRate: rate,
            termMonths: term,
          );
          if (previousPayment != null) {
            expect(payment, greaterThan(previousPayment));
          }
          previousPayment = payment;
        }
      },
    );

    test('инвариант: суммарные выплаты не меньше тела кредита', () {
      final List<({double principal, double rate, int term})> cases =
          <({double principal, double rate, int term})>[
            (principal: 50000, rate: 0, term: 10),
            (principal: 100000, rate: 7.5, term: 18),
            (principal: 300000, rate: 12, term: 24),
            (principal: 750000, rate: 21, term: 36),
          ];

      for (final ({double principal, double rate, int term}) c in cases) {
        final double payment = calculateAnnuityMonthlyPayment(
          principal: c.principal,
          annualInterestRate: c.rate,
          termMonths: c.term,
        );
        expect(payment * c.term, greaterThanOrEqualTo(c.principal));
      }
    });

    test('согласован с AnnuityCalculator для месячного платежа', () {
      final List<({double principal, double rate, int term})> cases =
          <({double principal, double rate, int term})>[
            (principal: 120000, rate: 0, term: 12),
            (principal: 250000, rate: 7.5, term: 24),
            (principal: 500000, rate: 12, term: 36),
          ];

      for (final ({double principal, double rate, int term}) c in cases) {
        final double fromDomain = calculateAnnuityMonthlyPayment(
          principal: c.principal,
          annualInterestRate: c.rate,
          termMonths: c.term,
        );
        final double fromCore = AnnuityCalculator.calculateMonthlyPayment(
          principal: c.principal,
          annualInterestRatePercent: c.rate,
          termMonths: c.term,
        );
        final List<AnnuityPaymentItem> schedule =
            AnnuityCalculator.generateSchedule(
              principal: Money.fromDouble(
                c.principal,
                currency: 'RUB',
                scale: 2,
              ),
              annualInterestRatePercent: c.rate,
              termMonths: c.term,
              firstPaymentDate: DateTime(2026, 3, 15),
            );

        expect(fromDomain, closeTo(fromCore, 1e-9));
        expect(schedule, isNotEmpty);
        expect(schedule.first.totalAmount.toDouble(), closeTo(fromCore, 0.01));
      }
    });
  });
}
