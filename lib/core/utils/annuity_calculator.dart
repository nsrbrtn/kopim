import 'dart:math';
import 'package:kopim/core/money/money.dart';

class AnnuityPaymentItem {
  const AnnuityPaymentItem({
    required this.date,
    required this.principalAmount,
    required this.interestAmount,
    required this.totalAmount,
    required this.remainingBalance,
  });

  final DateTime date;
  final Money principalAmount;
  final Money interestAmount;
  final Money totalAmount;
  final Money remainingBalance;
}

class AnnuityCalculator {
  /// Generates an annuity schedule.
  static List<AnnuityPaymentItem> generateSchedule({
    required Money principal,
    required double annualInterestRatePercent,
    required int termMonths,
    required DateTime firstPaymentDate,
  }) {
    if (termMonths <= 0 || principal.minor <= BigInt.zero) {
      return <AnnuityPaymentItem>[];
    }

    final double monthlyRate = annualInterestRatePercent / 12 / 100;
    final double principalDouble = principal.toDouble();
    double monthlyPaymentDouble;

    // PMT Formula: P * r * (1+r)^n / ((1+r)^n - 1)
    if (monthlyRate == 0) {
      monthlyPaymentDouble = principalDouble / termMonths;
    } else {
      monthlyPaymentDouble = principalDouble *
          monthlyRate /
          (1 - pow(1 + monthlyRate, -termMonths));
    }

    // Round PMT to currency scale (e.g. pennies)
    final Money monthlyPayment = Money.fromDouble(
      monthlyPaymentDouble,
      currency: principal.currency,
      scale: principal.scale,
    );
    final BigInt fixedTotalPaymentMinor = monthlyPayment.minor;

    BigInt balanceMinor = principal.minor;
    final List<AnnuityPaymentItem> items = <AnnuityPaymentItem>[];
    final int targetDay = firstPaymentDate.day;
    DateTime nextDate = firstPaymentDate;

    for (int i = 1; i <= termMonths; i++) {
      // Calculate Interest for this period: Balance * MonthlyRate
      final double interestDouble =
          (balanceMinor.toDouble() / pow(10, principal.scale)) * monthlyRate;
      final Money interestMoney = Money.fromDouble(
        interestDouble,
        currency: principal.currency,
        scale: principal.scale,
      );
      final BigInt interestAmountMinor = interestMoney.minor;

      BigInt totalAmountMinor = fixedTotalPaymentMinor;

      // Last Payment Adjustment
      if (i == termMonths) {
        totalAmountMinor = balanceMinor + interestAmountMinor;
      }

      BigInt principalAmountMinor = totalAmountMinor - interestAmountMinor;

      // Adjust if principal exceeds balance (possible with rounding or negative amortization)
      if (principalAmountMinor > balanceMinor) {
        principalAmountMinor = balanceMinor;
        totalAmountMinor = principalAmountMinor + interestAmountMinor;
      }

      balanceMinor -= principalAmountMinor;

      items.add(AnnuityPaymentItem(
        date: nextDate,
        principalAmount: Money(
          minor: principalAmountMinor,
          currency: principal.currency,
          scale: principal.scale,
        ),
        interestAmount: Money(
          minor: interestAmountMinor,
          currency: principal.currency,
          scale: principal.scale,
        ),
        totalAmount: Money(
          minor: totalAmountMinor,
          currency: principal.currency,
          scale: principal.scale,
        ),
        remainingBalance: Money(
          minor: balanceMinor,
          currency: principal.currency,
          scale: principal.scale,
        ),
      ));

      // Calculate next date
      nextDate = _addMonthKeepingDay(firstPaymentDate, i, targetDay);
    }

    return items;
  }

  static DateTime _addMonthKeepingDay(
    DateTime start,
    int monthsToAdd,
    int targetDay,
  ) {
    int year = start.year;
    int month = start.month + monthsToAdd;

    // Normalize year/month
    while (month > 12) {
      month -= 12;
      year++;
    }

    // Determine max days in that month
    final int maxDays = _daysInMonth(year, month);
    final int day = min(targetDay, maxDays);

    return DateTime(year, month, day);
  }

  static int _daysInMonth(int year, int month) {
    if (month == 2) {
      final bool isLeap =
          (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeap ? 29 : 28;
    }
    const List<int> days = <int>[
      0,
      31,
      -1,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ];
    return days[month];
  }
}
