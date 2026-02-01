import 'dart:math' as math;

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
  if (termMonths <= 0) return 0.0;
  if (principal <= 0) return 0.0;
  
  if (annualInterestRate <= 0) {
    return principal / termMonths;
  }

  final double monthlyRate = annualInterestRate / 12 / 100;
  
  // Formula: P * (i * (1+i)^n) / ((1+i)^n - 1)
  final double ratePower = math.pow(1 + monthlyRate, termMonths).toDouble();
  
  final double payment = principal * (monthlyRate * ratePower) / (ratePower - 1);
  
  return payment;
}
