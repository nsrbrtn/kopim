import 'package:kopim/core/utils/annuity_calculator.dart';

/// Calculates the monthly annuity payment.
///
/// [principal] - The total loan amount (initial debt).
/// [annualInterestRate] - The annual interest rate in percent (e.g., 12.5 for 12.5%).
/// [termMonths] - The loan term in months.
///
/// Returns the monthly payment amount.
double calculateAnnuityMonthlyPayment({
  required double principal,
  required double annualInterestRate,
  required int termMonths,
}) {
  return AnnuityCalculator.calculateMonthlyPayment(
    principal: principal,
    annualInterestRatePercent: annualInterestRate,
    termMonths: termMonths,
  );
}
